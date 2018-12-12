#!/bin/sh

if [ -e /oracle-xe-18c_configure.out ] ; then
  echo "/etc/init.d/oracle-xe-18c has already been run"
  exit 1
fi

if [ -z "${password}" ] ; then
  password="oracle"
fi

{ echo "${password}" ; echo "${password}" ; } | /etc/init.d/oracle-xe-18c configure 2>&1 | tee /oracle-xe-18c_configure.out
/etc/init.d/oracle-xe-18c stop
