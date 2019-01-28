#!/usr/bin/env bash
set -eu
source /usr/local/crosware/etc/profile
crosware install git binutils
source /usr/local/crosware/etc/profile
cd
git clone https://github.com/richfelker/musl-cross-make.git
cd musl-cross-make
curl -kLO https://raw.githubusercontent.com/ryanwoodsmall/musl-misc/master/musl-cross-make-confs/Makefile.arch_indep
( date ; time ( make -f Makefile.arch_indep ; echo $? ) ; date ) >/tmp/musl-cross-make.out 2>&1
