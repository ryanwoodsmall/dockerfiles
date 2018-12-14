#!/bin/bash

cof="/oracle-xe-18c_configure.out"
oconf="/etc/sysconfig/oracle-xe-18c.conf"
oinit="/etc/init.d/oracle-xe-18c"

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

source /sethostname.sh

sed -i.ORIG 's/SKIP_VALIDATIONS=false/SKIP_VALIDATIONS=true/g' "${oconf}"

# set maximum memory to 1/2 of total to force sga/pga setting
maxmem="$((($(free -g | awk '/^Mem:/{print $2}')/2)*(1024*1024)))"
sed -i.ORIG "/^MAXIMUM_MEMORY=/s/^MAXIMUM_MEMORY=.*/MAXIMUM_MEMORY=${maxmem}/g" "${oinit}"
# set pga/sga combined mem to 2GB-1MB to force split
sed -i 's/memory=.*/memory=2048/g' "${oinit}"

{ echo "${orapass}" ; echo "${orapass}" ; } \
| "${oinit}" configure 2>&1 \
| tee "${cof}"

"${oinit}" stop

touch "${cof}"
