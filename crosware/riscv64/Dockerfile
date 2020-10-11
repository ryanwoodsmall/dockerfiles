#
# build a riscv64 crosware container
# this requires qemu user emulation
# on debian and ubuntu, install binfmt-support and qemu-user-static
# a little janky/big, doesn't clean up much after itself
#

FROM ubuntu:focal AS qemustatic

RUN apt-get update \
    && apt-get -y install qemu-user-static

FROM ryanwoodsmall/crosware

COPY --from=qemustatic /usr/bin/qemu-riscv64-static /usr/bin/

ADD https://github.com/ryanwoodsmall/static-binaries/raw/master/riscv64/bash    /usr/bin/riscv64-bash
ADD https://github.com/ryanwoodsmall/static-binaries/raw/master/riscv64/busybox /usr/bin/riscv64-busybox
ADD https://github.com/ryanwoodsmall/static-binaries/raw/master/riscv64/toybox  /usr/bin/riscv64-toybox
ADD https://github.com/ryanwoodsmall/static-binaries/raw/master/riscv64/curl    /usr/bin/riscv64-curl

RUN . /etc/profile \
    && ln -sf /usr/bin/qemu-riscv64-static /usr/bin/qemu-riscv64 \
    && chmod 755 /usr/bin/*riscv64* \
    && crosware list-installed | cut -f1 -d: | xargs crosware uninstall \
    && for p in bash busybox toybox curl ; do cp /usr/bin/${p} /usr/bin/$(uname -m)-${p} ; done \
    && for p in bash busybox toybox curl ; do cp /usr/bin/riscv64-${p} /usr/bin/${p} ; done \
    && unset AR AS CC CFLAGS CPP CXX CXXFLAGS LD LDFLAGS \
    && crosware install statictoolchain \
    && . /etc/profile \
    && crosware install bearssl bim cacertificates dropbear elvis less mujs neatvi rlwrap tinyscheme \
    && rm -f /usr/local/tmp/* /usr/local/crosware/downloads/*/*

# vim: set ft=sh:
