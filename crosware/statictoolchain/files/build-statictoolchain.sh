#!/usr/bin/env bash

#
# XXX - does this belong with the crosware project? or musl-misc? or here?
#

set -eu

export TS="$(date '+%Y%m%d%H%M')"

st="$(date)"

logfile="/tmp/musl-cross-make.out"
echo "logging to ${logfile}"

source /etc/profile
source /usr/local/crosware/etc/profile

echo "installing prerequisites"
crosware install ccache
source /usr/local/crosware/etc/profile
( time ( crosware install git binutils ) ) >${logfile} 2>&1
source /usr/local/crosware/etc/profile

cd ${cwtop}/tmp/
pwd

echo "cloning musl-cross-make"
export GIT_SSL_NO_VERIFY=1
git clone https://github.com/richfelker/musl-cross-make.git >>${logfile} 2>&1

cd musl-cross-make

echo "getting Makefile.arch_indep"
curl -fkLO https://raw.githubusercontent.com/ryanwoodsmall/musl-misc/master/musl-cross-make-confs/Makefile.arch_indep

echo "building compiler"
( date ; time ( make -f Makefile.arch_indep ; echo $? ) ; date ) >>${logfile} 2>&1

et="$(date)"
echo "started: ${st}"
echo "finished: ${et}"
