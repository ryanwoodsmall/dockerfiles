#!/bin/bash

set -eux

rpmarch="$(rpm --eval '%{_target_cpu}')"

yum -y install deltarpm
yum clean all
yum list updates
yum -y update
yum clean all
yum -y update
yum -y install \
  gcc \
  gcc-c++ \
  make \
  rpm-build \
  make \
  git \
  rpmdevtools \
  glibc-static \
  flex \
  bison \
  ruby \
  libevent-devel \
  ncurses-devel \
  ncurses-static \
  openssl-devel \
  openssl-static \
  which \
  autoconf \
  automake \
  readline-devel \
  valgrind

cat >~/.rpmmacros<<EOF
%debug_package %{nil}
EOF
if $(uname -m | grep -q ^arm) ; then
  echo '%__global_ldflags -Wl,-z,relro -Wl,-static %{_hardened_ldflags} -static' >> ~/.rpmmacros
fi

mkdir -p ~/rpmbuild/SPECS
mkdir -p ~/rpmbuild/SOURCES

mkdir -p ~/git
cd ~/git
for g in \
  https://github.com/ryanwoodsmall/busybox-misc.git \
  https://github.com/ryanwoodsmall/dropbear-misc.git \
  https://github.com/ryanwoodsmall/jo-misc.git \
  https://github.com/ryanwoodsmall/jq-misc.git \
  https://github.com/ryanwoodsmall/musl-misc.git \
  https://github.com/ryanwoodsmall/rc-misc.git \
  https://github.com/ryanwoodsmall/suckless-misc.git \
  https://github.com/ryanwoodsmall/tmux-misc.git \
  https://github.com/ryanwoodsmall/toybox-misc.git
do
  rm -rf $(basename ${g/%.git/})
  git clone ${g}
done

for s in $(find ${PWD}/ -name \*.spec)
do
  echo ${s}
  ln -sf ${s} ~/rpmbuild/SPECS/
done

rm -f ~/rpmbuild/SOURCES/*
for s in ~/rpmbuild/SPECS/*.spec ; do
  echo ${s}
  spectool -g -A -C ~/rpmbuild/SOURCES/ ${s}
done

rm -f ~/rpmbuild/RPMS/${rpmarch}/musl*.rpm
time rpmbuild -ba --clean ~/rpmbuild/SPECS/musl-static.spec
rpm -Uvh ~/rpmbuild/RPMS/${rpmarch}/musl-static*.${rpmarch}.rpm
source /etc/profile.d/musl-static.sh
rm -f ~/rpmbuild/SPECS/musl-static.spec

for s in ~/rpmbuild/SPECS/*{toybox,busybox}*.spec
do
  sed -i 's/HOSTCC=musl-gcc/HOSTCC="musl-gcc -static"/g' ${s}
done
for s in ~/rpmbuild/SOURCES/*_config_script.sh
do
  sed -i '/^make/s/$/ HOSTCC="musl-gcc -static"/g' ${s}
done

for s in ~/rpmbuild/SPECS/*.spec
do
  echo ${s}
  time rpmbuild -ba --clean ${s}
done
