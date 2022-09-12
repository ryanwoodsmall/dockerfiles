#
# build a riscv64 crosware container
# this requires qemu user emulation
# on debian and ubuntu, install binfmt-support and qemu-user-static
# a little janky/big, doesn't clean up much after itself
# run with:
#   docker run -it --rm -v $(which qemu-riscv64-static):$(which qemu-riscv64-static) ryanwoodsmall/crosware:riscv64
#

FROM ubuntu:jammy AS ubuntu

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get -y install bzip2 git qemu-user-static \
    && mkdir -p /usr/local \
    && cd /usr/local \
    && git clone https://github.com/ryanwoodsmall/crosware.git \
    && ( cd crosware ; git gc --aggressive ) \
    && tar -C / -jcf /tmp/crosware.tar.bz2 /usr/local/crosware

FROM ryanwoodsmall/crosware

COPY --from=ubuntu /usr/bin/qemu-riscv64-static /usr/bin/
COPY --from=ubuntu /tmp/crosware.tar.bz2 /tmp/

ADD https://github.com/ryanwoodsmall/static-binaries/raw/master/riscv64/bash    /usr/bin/riscv64-bash
ADD https://github.com/ryanwoodsmall/static-binaries/raw/master/riscv64/busybox /usr/bin/riscv64-busybox
ADD https://github.com/ryanwoodsmall/static-binaries/raw/master/riscv64/toybox  /usr/bin/riscv64-toybox
ADD https://github.com/ryanwoodsmall/static-binaries/raw/master/riscv64/curl    /usr/bin/riscv64-curl

RUN cd / \
    && rm -rf /usr/local/crosware \
    && tar -C / -jxvf /tmp/crosware.tar.bz2 \
    && rm -f /tmp/crosware.tar.bz2 \
    && . /etc/profile \
    && cd ${cwtop} \
    && pwd \
    && which crosware \
    && barch="$(uname -m)" \
    && ln -sf /usr/bin/qemu-riscv64-static /usr/bin/qemu-riscv64 \
    && chmod 755 /usr/bin/*riscv64* \
    && crosware list-installed | cut -f1 -d: | xargs crosware uninstall \
    && for p in bash busybox toybox curl ; do cp /usr/bin/${p} /usr/bin/${barch}-${p} ; done \
    && for p in bash busybox toybox curl ; do cp /usr/bin/riscv64-${p} /usr/bin/${p} ; done \
    && for p in bash busybox toybox curl ; do rm -f /usr/bin/${barch}-${p} /usr/bin/riscv64-${p} ; done \
    && uname -m \
    && bash -c set | grep TYPE \
    && find /usr/bin/ -type f -exec file {} + | sort \
    && unset AR AS CC CFLAGS CPP CXX CXXFLAGS LD LDFLAGS \
    && crosware install statictoolchain \
    && . /etc/profile \
    && for r in bash bearssl bim busybox cacertificates curlmbedtls dropbear elvis less mbedtls mujs neatvi rlwrap tinyscheme toybox sbase ubase 9base x509cert plan9port9p u9fs px5g shellish alpinemuslutils htermutils cryanc ; do crosware check-installed ${r} || crosware install ${r} ; done \
    && cp ./software/curlmbedtls/current/bin/curl-mbedtls /usr/bin/curl \
    && cp ./software/bash/current/bin/bash /usr/bin/bash \
    && cp ./software/busybox/current/bin/busybox /usr/bin/busybox \
    && cp ./software/toybox/current/bin/toybox /usr/bin/toybox \
    && strip --strip-all /usr/bin/bash /usr/bin/busybox /usr/bin/curl /usr/bin/toybox \
    && bash ${cwtop}/scripts/install-dotfiles.sh \
    && cat ~/.exrc > /etc/vi.exrc \
    && rm -rf /usr/local/tmp/* /usr/local/crosware/downloads/*/*

# vim: set ft=sh:
