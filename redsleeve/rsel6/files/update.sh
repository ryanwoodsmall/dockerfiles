#!/bin/bash

rrd="$(rpm -q redsleeve-release --qf '%{RELEASE}\n' | cut -f1 -d.)"

if [ ${rrd} -lt 20170804 ] ; then
  rpm -Uvh http://ftp.redsleeve.org/pub/el6/latest/base/base/arm/Packages/redsleeve-release-6-20170804.el6.armv5tel.rpm
fi
sed -i '/^enabled=0/ s/^\(enabled\)=0/\1=1/g' /etc/yum.repos.d/update.repo
yum clean all
yum list updates
yum -y update
