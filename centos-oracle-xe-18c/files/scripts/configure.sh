#!/bin/sh

cof="/oracle-xe-18c_configure.out"

if [ -e "${cof}" ] ; then
  echo "/etc/init.d/oracle-xe-18c has already been run"
  exit 1
fi

if [ -z "${orapass}" ] ; then
  orapass="oracle"
fi

if [ -z "${DBCA_TOTAL_MEMORY}" ] ; then
  export DBCA_TOTAL_MEMORY="4096"
fi

source /sethostname.sh

sed -i.ORIG 's/SKIP_VALIDATIONS=false/SKIP_VALIDATIONS=true/g' /etc/sysconfig/oracle-xe-18c.conf

{ echo "${orapass}" ; echo "${orapass}" ; } \
| /etc/init.d/oracle-xe-18c configure 2>&1 \
| tee "${cof}"

/etc/init.d/oracle-xe-18c stop

touch "${cof}"
