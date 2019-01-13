#
# work in progress crosware bootstrap container
#
# XXX - more recipes needed?
#   text browser with netbsdcurses?
#
# XXX - build a downloads/ mirror? share as a volume? hmm...
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
    && ./bin/crosware install busybox toybox sbase ubase bash curl dropbear coreutils stunnel socat \
    && mkdir -p /stow \
    && cp ./software/busybox/current/bin/busybox /stow/ \
    && cp ./software/toybox/current/bin/toybox /stow/ \
    && cp ./software/sbase/current/bin/sbase-box /stow/ \
    && cp ./software/ubase/current/bin/ubase-box /stow/ \
    && cp ./software/bash/current/bin/bash /stow/ \
    && cp ./software/curl/current/bin/curl-mbedtls /stow/curl \
    && cp ./software/dropbear/current/bin/dropbearmulti /stow/ \
    && cp ./software/coreutils/current/bin/coreutils /stow/ \
    && cp ./software/openssl/current/bin/openssl /stow/ \
    && cp ./software/stunnel/current/bin/stunnel /stow/ \
    && cp ./software/socat/current/bin/socat /stow/ \
    && cp ./software/sed/current/bin/gsed /stow/ \
    && cp ./software/gawk/current/bin/gawk /stow/ \
    && rm -rf /usr/local/tmp/* \
    && git clean -fdx || true

# XXX - "git clean -fdx" in /usr/local/crosware so there's a clean checkout
# XXX - COPY all of /usr/local/crosware below

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
# XXX - needed?
# - chown mail:mail /var/spool/mail
# - chown www-data:www-data /var/www
# move binaries into place
COPY --from=BUILDER /stow/toybox /usr/bin/
COPY --from=BUILDER /stow/sbase-box /usr/bin/
COPY --from=BUILDER /stow/ubase-box /usr/bin/
# toybox, sbase, ubase, etc.
RUN for p in toybox sbase-box ubase-box ; do for a in $(${p}) ; do test -e /usr/bin/${a} || ln -s ${p} /usr/bin/${a} ; done ; done
# bash
COPY --from=BUILDER /stow/bash /usr/bin/
RUN rm -f /usr/bin/sh \
    && ln -s bash /usr/bin/sh
# dropbear
COPY --from=BUILDER /stow/dropbearmulti /usr/bin/
RUN for a in $(dropbearmulti 2>&1 | tr ' ' '\n' | grep "^'.*'$" | tr -d "'" | sort) ; do test -e /usr/bin/${a} || ln -s dropbearmulti /usr/bin/${a} ; done
# coreutils
COPY --from=BUILDER /stow/coreutils /usr/bin/
RUN for a in $(coreutils --help 2>&1 | sed -n '/^Built-in programs:/,/^$/p' | grep -v ^Built-in) ; do test -e /usr/bin/${a} || ln -s coreutils /usr/bin/${a} ; done
## gawk
#COPY --from=BUILDER /stow/gawk /usr/bin/
#RUN rm -f /usr/bin/awk \
#    && ln -s gawk /usr/bin/awk
## sed
#COPY --from=BUILDER /stow/gsed /usr/bin/
#RUN rm -f /usr/bin/sed \
#    && ln -s gsed /usr/bin/sed
# files to be copied with no setup
COPY --from=BUILDER /stow/curl /usr/bin/
COPY --from=BUILDER /stow/openssl /usr/bin/
COPY --from=BUILDER /stow/stunnel /usr/bin/
COPY --from=BUILDER /stow/socat /usr/bin/
COPY --from=BUILDER /usr/local/crosware /usr/local/crosware
# final setup stuff
RUN sed -i 's#/bin/sh#/bin/bash#g' /etc/passwd \
    && echo '/bin/sh' > /etc/shells \
    && echo '/bin/ash' >> /etc/shells \
    && echo '/bin/bash' >> /etc/shells \
    && echo 'test -e /etc/profile.d && for scriptlet in /etc/profile.d/*.sh ; do . ${scriptlet} ; done ; unset scriptlet' > /etc/profile \
    && echo 'export CW_GIT_CMD=git' > /etc/profile.d/crosware.sh \
    && echo '# XXX UGH' >> /etc/profile.d/crosware.sh \
    && echo 'export GIT_SSL_NO_VERIFY=1' >> /etc/profile.d/crosware.sh \
    && echo 'export PATH=${PATH}:/usr/local/crosware/bin' >> /etc/profile.d/crosware.sh \
    && echo 'test -e /usr/local/crosware/etc/profile && . /usr/local/crosware/etc/profile' >> /etc/profile.d/crosware.sh
# XXX - /etc/profile (bashrc, bash_profile, profile.d/, etc.)

CMD ["bash","-il"]
