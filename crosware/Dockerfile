#
# bootstrap crosware container
# - "tested" on x86_64/aarch64/arm32v{6,7}/i386...

# can build x86 by (or arm32v6 on arm64v8)
# - build x86_64
# - running container with "setarch linux32 bash -il" (or just "linux32 bash -il")
# - build busybox/toybox/bash/curl and replace binaries in /usr/bin
# - or, i386 centos 6:
#     sed '/CMD.*bash/s/"bash"/"setarch","linux32","bash"/g' Dockerfile \
#     | sed '/crosware \(bootstrap\|install\)/s#\./bin/#setarch linux32 ./bin/#g' \
#     | sed 's#yum clean all#echo i386 > /etc/yum/vars/basearch ; yum clean all#g' \
#     | sed 's#centos:latest#i386/centos:6#g' \
#     | docker build --tag centos32 -
#
# XXX - build a downloads/ mirror? share as a volume? hmm...
# XXX - need (read-only?) git client that doesn't require java
# XXX - downloads statictoolchain twice, but at least tests our bash/curl/userspace?
# XXX - set "-Os" in CFLAGS/CXXFLAGS on centos:7 builder
# XXX - move curl mbedtls to bearssl (done, keep testing)
#       https://bellard.org/qemacs/qemacs-0.3.3.tar.gz - works with mbedtls, not with bearssl?
# XXX - mbedtls 2.16.10 breaks downloading https://download.samba.org/pub/rsync/src/rsync-3.2.3.tar.gz
# XXX - libressl/3.2.5 and wolfssl/4.7.0 can't download... https://svnkit.com/org.tmatesoft.svn_1.10.3.standalone.nojna.zip
# XXX - ssl/tls juggling is killing me. wish openssl didn't require perl
# XXX - symlink /etc/profile to /etc/bash.bashrc (done, needs testing)
# XXX - package install/cleanup needs to be moved to a script in croware:scripts/
#

# start from the musl busybox container
FROM busybox:musl as BUSYBOX

# and we need a couple things from alpine as well
FROM alpine:latest as ALPINE

# bootstrap, build some stuff for the container, then clean up
FROM debian:bullseye as BUILDER
RUN set -eu \
    && apt update \
    && apt install -y bash binutils bzip2 curl file git \
    && mkdir -p /usr/local \
    && cd /usr/local \
    && rm -rf crosware \
    && git clone https://github.com/ryanwoodsmall/crosware.git \
    && cd crosware \
    && git gc --aggressive \
    && env CW_GIT_CMD=git CW_USE_JAVA=false CW_USE_JGIT=false ./bin/crosware bootstrap \
    && ./bin/crosware install bootstrapmake busybox toybox bash dropbear cacertificates rlwrap less elvis neatvi tinyscheme mbedtls bearssl bim mujs curlmbedtls sbase ubase 9base x509cert plan9port9p u9fs px5g htermutils shellish alpinemuslutils cryanc jo jq ag pv entr otools outils tini rsyncminimal \
    && rm -rf /stow \
    && mkdir -p /stow \
    && cp ./software/busybox/current/bin/busybox /stow/ \
    && cp ./software/toybox/current/bin/toybox /stow/ \
    && cp ./software/bash/current/bin/bash /stow/ \
    && cp ./software/curlmbedtls/current/bin/curl-mbedtls /stow/curl \
    && find /stow/ -type f | xargs ./software/toybox/current/bin/toybox file | grep 'ELF.*stripped' | cut -f1 -d: | xargs ./software/statictoolchain/current/bin/strip --strip-all \
    && ./software/toybox/current/bin/toybox file /stow/* \
    && rm -rf /usr/local/tmp/* \
    && ./bin/crosware list-installed | egrep -v '^(cacertificates|dropbear|elvis|less|neatvi|rlwrap|tinyscheme|mbedtls|bearssl|(bootstrap|)make|bim|git|mujs|(s|u|9)base|x509cert|plan9port9p|u9fs|px5g|shellish|alpinemuslutils|htermutils|cryanc|gawk|sed|busybox|toybox|bash|patch|jo|jq|ag|pv|entr|byacc|flex|m4|pkgconfig|slibtool|lshsftpserver|configgit|gettexttiny|zlib|xz|otools|outils|tini|rsyncminimal) : ' | cut -f1 -d: | xargs ./bin/crosware uninstall \
    && for d in builds downloads ; do cd $d ; git clean -fdx ; cd - ; done \
    && find software/ -type f -exec file {} + | awk -F: '/\/bin\/.*:.*ELF/{print $1}' | xargs strip --strip-all \
    && ln -sf /usr/bin/bash ./software/bash/current/bin/bash \
    && ln -sf /usr/bin/busybox ./software/busybox/current/bin/busybox \
    && ln -sf /usr/bin/toybox ./software/toybox/current/bin/toybox \
    && git ls-files | xargs realpath | sort -u > ./tmp/git_ls-files.out

# get the busybox binary and install it as usual under /bin/ and as /bin/sh
FROM scratch
COPY --from=BUILDER /stow/busybox /bin/
COPY --from=BUILDER /stow/busybox /bin/sh
# get /etc user/group passwd/shadow files
COPY --from=BUSYBOX /etc/group /etc/
COPY --from=BUSYBOX /etc/passwd /etc/
COPY --from=BUSYBOX /etc/shadow /etc/
# get /etc services/protocols from alpine
COPY --from=ALPINE /etc/protocols /etc/
COPY --from=ALPINE /etc/services /etc/
# shuffle /bin -> /usr/bin and create symlinks and required directories
RUN /bin/busybox mkdir -p /usr/bin \
    && /bin/busybox cp /bin/busybox /usr/bin/ \
    && /usr/bin/busybox --list | while read -r a ; do /usr/bin/busybox ln -s busybox /usr/bin/${a} ; done \
    && /usr/bin/busybox rm -f /bin/busybox /bin/sh \
    && /usr/bin/busybox rmdir /bin/ \
    && /usr/bin/busybox ln -s /usr/bin/ /bin \
    && /usr/bin/busybox ln -s /usr/bin/ /sbin
# dirs, perms, etc.
RUN mkdir -p /home /root /tmp /var/spool/mail /var/www /etc/profile.d /usr/local/tmp /usr/local/bin /usr/local/sbin /usr/sbin /var/tmp /var/lib /run \
    && chmod 755 /home \
    && chmod 700 /root \
    && chmod 1777 /tmp /usr/local/tmp /var/tmp \
    && chmod 600 /etc/shadow \
    && ln -s /run /var/ \
    && rm -f /usr/bin/bash
# toybox - lspci, lsusb work well with /etc/{pci,usb}.ids, microcom is a little more stable than busybox ime
COPY --from=BUILDER /stow/toybox /usr/bin/
RUN for p in toybox ; do for a in $(${p}) ; do test -e /usr/bin/${a} || ln -s ${p} /usr/bin/${a} ; done ; done \
    && for p in lsusb lspci microcom ; do rm -f /usr/bin/${p} ; ln -sf toybox /usr/bin/${p} ; done
# bash
COPY --from=BUILDER /stow/bash /usr/bin/
RUN rm -f /usr/bin/sh \
    && ln -s bash /usr/bin/sh
# files/directories to be copied with no setup
COPY --from=BUILDER /stow/curl /usr/bin/
# crosware and permissions
COPY --from=BUILDER /usr/local/crosware /usr/local/crosware
# dropbear
RUN ln -s /usr/local/crosware/software/dropbear/current/bin/dropbearmulti /usr/bin/ \
    && for d in $(/usr/bin/dropbearmulti 2>&1 | tr ' ' '\n' | grep "^'.*'" | tr -d "'" | sort) ; do ln -s dropbearmulti /usr/bin/${d} ; done \
    && mkdir -p /usr/local/crosware/software/dropbear/etc
# elvis
RUN rm -f /usr/bin/vi \
    && ln -s /usr/local/crosware/software/elvis/current/bin/elvis /usr/bin/vi
# final setup stuff
RUN sed -i 's#/bin/sh#/bin/bash#g' /etc/passwd \
    && echo '/bin/sh' > /etc/shells \
    && echo '/bin/ash' >> /etc/shells \
    && echo '/bin/bash' >> /etc/shells \
    && cat /etc/shells > /etc/shells.default \
    && echo 'set bell-style none' > /etc/inputrc \
    && echo 'set meta-flag on' >> /etc/inputrc \
    && echo 'set input-meta on' >> /etc/inputrc \
    && echo 'set convert-meta off' >> /etc/inputrc \
    && echo 'set output-meta on' >> /etc/inputrc \
    && echo 'set mark-symlinked-directories on' >> /etc/inputrc \
    && echo 'test -e /etc/profile.d && for scriptlet in /etc/profile.d/*.sh ; do . ${scriptlet} ; done ; unset scriptlet' > /etc/profile \
    && ln -sf /etc/profile /etc/bash.bashrc \
    && echo 'export PATH=${PATH}:/usr/local/crosware/bin' > /etc/profile.d/crosware.sh \
    && echo 'export PS1="\u@crosware-$(uname -m) \W \$ "' >> /etc/profile.d/crosware.sh \
    && echo 'export CW_GIT_CMD=git' >> /etc/profile.d/crosware.sh \
    && echo 'export CW_USE_JAVA=false' >> /etc/profile.d/crosware.sh \
    && echo 'export CW_USE_JGIT=false' >> /etc/profile.d/crosware.sh \
    && echo 'export SHELL=/bin/bash' >> /etc/profile.d/crosware.sh \
    && echo 'export EDITOR=vi' >> /etc/profile.d/crosware.sh \
    && echo 'export XVINIT="source ${HOME}/.exrc"' >> /etc/profile.d/crosware.sh \
    && echo 'test -e /usr/local/crosware/etc/profile && . /usr/local/crosware/etc/profile' >> /etc/profile.d/crosware.sh \
    && echo 'export PATH=${HOME}/bin:${PATH}' >> /etc/profile.d/crosware.sh \
    && sed -i 's/root::/root:*:/g' /etc/shadow \
    && export cwtop=/usr/local/crosware \
    && bash ${cwtop}/scripts/install-dotfiles.sh \
    && cat ~/.exrc > /etc/vi.exrc \
    && bash ${cwtop}/scripts/get-pci-usb-ids.sh \
    && ln -sf ${cwtop}/etc/{pci,usb}.ids /etc/ \
    && ${cwtop}/bin/crosware install statictoolchain \
    && rm -rf /usr/local/tmp/* \
    && chgrp -R wheel /usr/local/crosware \
    && chmod -R g+w /usr/local/crosware \
    && find /usr/local/crosware -type d -exec chmod 2775 {} \;

# XXX - random password, throw a base64 in here? "$(date | base64)"
#   && chpasswd <<<"root:${RANDOM}$(date '+%Y%m%d%H%M%S')${RANDOM}" \

WORKDIR "/usr/local/crosware"
CMD ["/usr/bin/bash","-il"]

# vim: set ft=sh:
