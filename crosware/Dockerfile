#
# work in progress crosware bootstrap container
#
# should work ootb for x86_64/arm/aarch64
#
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
# XXX - ssl/tls certs???
# XXX - downloads statictoolchain twice, but at least tests our bash/curl/userspace?
#

# start from the musl busybox container
FROM busybox:musl as BUSYBOX

# build out some of our recipes
# XXX - busybox patch does *not* work for some bash patches
FROM centos:7 as BUILDER
RUN set -eu \
    && yum clean all \
    && yum -y install bash bzip2 curl git patch binutils file \
    && mkdir -p /usr/local \
    && cd /usr/local \
    && rm -rf crosware \
    && git clone https://github.com/ryanwoodsmall/crosware.git \
    && cd crosware \
    && env CW_GIT_CMD=git CW_USE_JAVA=false CW_USE_JGIT=false ./bin/crosware bootstrap \
    && ./bin/crosware install busybox toybox bash zlib dropbear cacertificates mbedtls rlwrap less elvis \
    && ./bin/crosware run-func cwfetch_curl cwextract_curl cwmakeinstall_curl_mbedtls cwlinkdir_curl cwclean_curl cwmarkinstall_curl \
    && rm -rf /stow \
    && mkdir -p /stow \
    && cp ./software/busybox/current/bin/busybox /stow/ \
    && cp ./software/toybox/current/bin/toybox /stow/ \
    && cp ./software/bash/current/bin/bash /stow/ \
    && cp ./software/curl/current/bin/curl-mbedtls /stow/curl \
    && find /stow/ -type f | xargs file | grep 'ELF.*stripped' | cut -f1 -d: | xargs strip --strip-all \
    && file /stow/* \
    && rm -rf /usr/local/tmp/* \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && ./bin/crosware list-installed | egrep -v '^(cacertificates|dropbear|elvis|less|rlwrap) : ' | cut -f1 -d: | xargs ./bin/crosware uninstall \
    && for d in builds downloads ; do pushd $d ; git clean -fdx ; popd ; done \
    && find software/ -type f -exec file {} + | awk -F: '/:.*ELF/{print $1}' | xargs strip --strip-all

# get the busybox binary and install it as usual under /bin/ and as /bin/sh
FROM scratch
COPY --from=BUILDER /stow/busybox /bin/
COPY --from=BUILDER /stow/busybox /bin/sh
# get /etc user/group passwd/shadow files
COPY --from=BUSYBOX /etc/group /etc/
COPY --from=BUSYBOX /etc/passwd /etc/
COPY --from=BUSYBOX /etc/shadow /etc/
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
# toybox
COPY --from=BUILDER /stow/toybox /usr/bin/
RUN for p in toybox ; do for a in $(${p}) ; do test -e /usr/bin/${a} || ln -s ${p} /usr/bin/${a} ; done ; done
# bash
COPY --from=BUILDER /stow/bash /usr/bin/
RUN rm -f /usr/bin/sh \
    && ln -s bash /usr/bin/sh
## xvi
#COPY --from=BUILDER /stow/xvi /usr/bin/
#RUN rm -f /usr/bin/vi \
#    && ln -s xvi /usr/bin/vi
# nvi
#COPY --from=BUILDER /stow/nvi /usr/bin/
#RUN rm -f /usr/bin/vi \
#    && ln -s nvi /usr/bin/vi
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
    && echo 'set bell-style none' > /etc/inputrc \
    && echo 'set meta-flag on' >> /etc/inputrc \
    && echo 'set input-meta on' >> /etc/inputrc \
    && echo 'set convert-meta off' >> /etc/inputrc \
    && echo 'set output-meta on' >> /etc/inputrc \
    && echo 'set mark-symlinked-directories on' >> /etc/inputrc \
    && echo 'test -e /etc/profile.d && for scriptlet in /etc/profile.d/*.sh ; do . ${scriptlet} ; done ; unset scriptlet' > /etc/profile \
    && echo 'export PATH=${PATH}:/usr/local/crosware/bin' > /etc/profile.d/crosware.sh \
    && echo 'export PS1="\u@crosware-$(uname -m) \W \$ "' >> /etc/profile.d/crosware.sh \
    && echo 'export CW_GIT_CMD=git' >> /etc/profile.d/crosware.sh \
    && echo 'export CW_USE_JAVA=false' >> /etc/profile.d/crosware.sh \
    && echo 'export CW_USE_JGIT=false' >> /etc/profile.d/crosware.sh \
    && echo 'export SHELL=/bin/bash' >> /etc/profile.d/crosware.sh \
    && echo 'export EDITOR=vi' >> /etc/profile.d/crosware.sh \
    && echo 'export XVINIT="source ${HOME}/.exrc"' >> /etc/profile.d/crosware.sh \
    && echo 'test -e /usr/local/crosware/etc/profile && . /usr/local/crosware/etc/profile' >> /etc/profile.d/crosware.sh \
    && echo '# XXX UGH' >> /etc/profile.d/crosware.sh \
    && echo '#export GIT_SSL_NO_VERIFY=1' >> /etc/profile.d/crosware.sh \
    && echo '# USER KNOWS BEST' >> /etc/profile.d/crosware.sh \
    && echo 'export PATH=${HOME}/bin:${PATH}' >> /etc/profile.d/crosware.sh \
    && sed -i 's/root::/root:*:/g' /etc/shadow \
    && for d in https://github.com/ryanwoodsmall/dotfiles/raw/master/dot_{elvis,ex,vile,vim}rc ; do curl -fkLs ${d} > ${HOME}/$(basename ${d} | sed 's/dot_/./g') ; done \
    && curl -fkLso /etc/vi.exrc https://github.com/ryanwoodsmall/dotfiles/raw/master/dot_exrc \
    && /usr/local/crosware/bin/crosware install statictoolchain \
    && rm -rf /usr/local/tmp/* \
    && chgrp -R wheel /usr/local/crosware \
    && chmod -R g+w /usr/local/crosware \
    && find /usr/local/crosware -type d -exec chmod 2775 {} \;

# XXX - random password, throw a base64 in here? "$(date | base64)"
#   && chpasswd <<<"root:${RANDOM}$(date '+%Y%m%d%H%M%S')${RANDOM}" \

WORKDIR "/usr/local/crosware"
CMD ["bash","-il"]

# vim: set ft=sh:
