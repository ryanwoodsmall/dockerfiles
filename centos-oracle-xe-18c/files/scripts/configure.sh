#!/bin/bash

# XXX - need "set -eu" in here
# XXX - need to "sysctl -p"?

cof="/oracle-xe-18c_configure.out"
oconf="/etc/sysconfig/oracle-xe-18c.conf"
oinit="/etc/init.d/oracle-xe-18c"
oprofd="/etc/profile.d/oracle-xe-18c.sh"

if [ -e "${cof}" ] ; then
  echo "/etc/init.d/oracle-xe-18c has already been run"
  exit 1
fi

if [ -z "${orapass}" ] ; then
  orapass="oracle"
fi

# XXX - this doesn't work?
if [ -z "${DBCA_TOTAL_MEMORY}" ] ; then
  export DBCA_TOTAL_MEMORY="2048"
fi

if ! $(grep -q '\[never\]' /sys/kernel/mm/transparent_hugepage/enabled) ; then
  echo "transparent hugepages may cause issues on xe"
  echo "if configuration fails, try disabling"
fi

source /sethostname.sh

sed -i.ORIG 's/SKIP_VALIDATIONS=false/SKIP_VALIDATIONS=true/g' "${oconf}"

sed -i.ORIG '/"sga_target"/a <initParam name="sga_max_size" value="1536" unit="MB"/>' /opt/oracle/product/18c/dbhomeXE/assistants/dbca/templates/XE_Database.dbc
sed -i '/"sga_target"/a <initParam name="use_large_pages" value="FALSE"/>' /opt/oracle/product/18c/dbhomeXE/assistants/dbca/templates/XE_Database.dbc

# set maximum memory to 1/2 of total to force sga/pga setting
maxmem="$((($(free -g | awk '/^Mem:/{print $2}')/2)*(1024*1024)))"
sed -i.ORIG "/^MAXIMUM_MEMORY=/s/^MAXIMUM_MEMORY=.*/MAXIMUM_MEMORY=${maxmem}/g" "${oinit}"
# set pga/sga combined mem to 2GB to force split
sed -i 's/memory=.*/memory=2048/g' "${oinit}"

{ echo "${orapass}" ; echo "${orapass}" ; } \
| "${oinit}" configure 2>&1 \
| tee "${cof}"

cat > "${oprofd}" << EOF
export ORACLE_SID="XE"
export ORAENV_ASK="NO"
. /opt/oracle/product/18c/dbhomeXE/bin/oraenv
export PATH
EOF

source "${oprofd}"

# listen on 0.0.0.0
sqlplus sys/${orapass} as sysdba <<<'exec dbms_xdb_config.setlistenerlocalaccess(false);'

# enable extended data types
# https://oracle-base.com/articles/12c/extended-data-types-12cR1
# https://docs.oracle.com/database/121/REFRN/GUID-D424D23B-0933-425F-BC69-9C0E6724693C.htm#REFRN10321
# https://docs.oracle.com/en/database/oracle/oracle-database/18/sqlrf/Data-Types.html#GUID-8EFA29E9-E8D8-40A6-A43E-954908C954A4
edtf="/tmp/extended-data-types.sql"
cat > "${edtf}" << EOF
PURGE DBA_RECYCLEBIN;
SHUTDOWN IMMEDIATE;
STARTUP UPGRADE;
ALTER SESSION SET CONTAINER=CDB\$ROOT;
ALTER SYSTEM SET max_string_size=extended SCOPE=SPFILE;
@?/rdbms/admin/utl32k.sql
ALTER PLUGGABLE DATABASE ALL OPEN UPGRADE;
EOF
sqlplus sys/${orapass} as sysdba < "${edtf}"

utl32kod="utl32k_cdb_pdbs_output"
cd "${ORACLE_HOME}/rdbms/admin"
mkdir -p "/tmp/${utl32kod}"
${ORACLE_HOME}/perl/bin/perl \
  ${ORACLE_HOME}/rdbms/admin/catcon.pl \
  -u SYS/${orapass} \
  -d ${ORACLE_HOME}/rdbms/admin \
  -l /tmp \
  -b ${utl32kod} \
    utl32k.sql

utlrpod="utlrp_cdb_pdbs_output"
cd "${ORACLE_HOME}/rdbms/admin"
mkdir -p "/tmp/${utlrpod}"
${ORACLE_HOME}/perl/bin/perl \
  ${ORACLE_HOME}/rdbms/admin/catcon.pl \
  -u SYS/${orapass} \
  -d ${ORACLE_HOME}/rdbms/admin \
  -l /tmp \
  -b ${utlrpod} \
    utlrp.sql

sqlplus sys/${orapass} as sysdba <<<'SHUTDOWN IMMEDIATE;'
sqlplus sys/${orapass} as sysdba <<<'STARTUP;'
#sqlplus sys/${orapass} as sysdba <<<'ALTER PLUGGABLE DATABASE ALL OPEN READ WRITE;'

"${oinit}" stop

touch "${cof}"
