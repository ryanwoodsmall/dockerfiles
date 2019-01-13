#
# work in progress crosware bootstrap container
#
# XXX - build a downloads/ mirror? share as a volume? hmm...
# XXX - need (read-only?) git client that doesn't require java
#

# start from the musl busybox container
FROM busybox:musl as BUSYBOX

# build out some of our recipes
FROM centos:latest as BUILDER
RUN yum clean all \
    && yum -y install bash bzip2 curl git \
    && mkdir -p /usr/local \
    && cd /usr/local \
    && git clone https://github.com/ryanwoodsmall/crosware.git \
    && cd crosware \
    && ./bin/crosware bootstrap \
    && ./bin/crosware install busybox toybox bash curl \
    && mkdir -p /stow \
    && cp ./software/busybox/current/bin/busybox /stow/ \
    && cp ./software/toybox/current/bin/toybox /stow/ \
    && cp ./software/bash/current/bin/bash /stow/ \
    && cp ./software/curl/current/bin/curl-mbedtls /stow/curl \
    && rm -rf /usr/local/tmp/* \
    && git clean -fdx || true

# get the busybox binary and install it as usual under /bin/ and as /bin/sh
FROM scratch
COPY --from=BUILDER /stow/busybox /bin/
COPY --from=BUILDER /stow/busybox /bin/sh
# get /etc uesr/group passwd/shadow files
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
RUN mkdir -p /home /root /tmp /var/spool/mail /var/www /etc/profile.d /usr/local/tmp /usr/local/bin /usr/local/sbin /usr/sbin \
    && chmod 755 /home \
    && chmod 700 /root \
    && chmod 1777 /tmp /usr/local/tmp \
    && chmod 600 /etc/shadow \
    && rm -f /usr/bin/bash
# toybox
COPY --from=BUILDER /stow/toybox /usr/bin/
RUN for p in toybox ; do for a in $(${p}) ; do test -e /usr/bin/${a} || ln -s ${p} /usr/bin/${a} ; done ; done
# bash
COPY --from=BUILDER /stow/bash /usr/bin/
RUN rm -f /usr/bin/sh \
    && ln -s bash /usr/bin/sh
# files/directories to be copied with no setup
COPY --from=BUILDER /stow/curl /usr/bin/
# crosware and permissions
COPY --from=BUILDER /usr/local/crosware /usr/local/crosware
RUN chgrp -R wheel /usr/local/crosware \
    && chmod -R g+w /usr/local/crosware \
    && find /usr/local/crosware -type d -exec chmod 2775 {} \;
# final setup stuff
RUN sed -i 's#/bin/sh#/bin/bash#g' /etc/passwd \
    && echo '/bin/sh' > /etc/shells \
    && echo '/bin/ash' >> /etc/shells \
    && echo '/bin/bash' >> /etc/shells \
    && echo 'test -e /etc/profile.d && for scriptlet in /etc/profile.d/*.sh ; do . ${scriptlet} ; done ; unset scriptlet' > /etc/profile \
    && echo 'export PATH=${PATH}:/usr/local/crosware/bin' > /etc/profile.d/crosware.sh \
    && echo 'export PS1="\u@crosware \W \$ "' >> /etc/profile.d/crosware.sh \
    && echo 'export CW_GIT_CMD=git' >> /etc/profile.d/crosware.sh \
    && echo 'export CW_USE_JAVA=false' >> /etc/profile.d/crosware.sh \
    && echo 'export CW_USE_JGIT=false' >> /etc/profile.d/crosware.sh \
    && echo '# XXX UGH' >> /etc/profile.d/crosware.sh \
    && echo 'export GIT_SSL_NO_VERIFY=1' >> /etc/profile.d/crosware.sh \
    && echo 'test -e /usr/local/crosware/etc/profile && . /usr/local/crosware/etc/profile' >> /etc/profile.d/crosware.sh \
    && sed -i 's/root::/root:*:/g' /etc/shadow

# XXX - random password
#   && chpasswd <<<"root:${RANDOM}$(date '+%Y%m%d%H%M%S')${RANDOM}"

CMD ["bash","-il"]
