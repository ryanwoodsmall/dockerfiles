#
# work in progress crosware bootstrap container
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
    && /usr/local/crosware/bin/crosware bootstrap \
    && /usr/local/crosware/bin/crosware install busybox toybox sbase ubase \
    && mkdir -p /stow \
    && cp /usr/local/crosware/software/busybox/current/bin/busybox /stow/ \
    && cp /usr/local/crosware/software/toybox/current/bin/toybox /stow/ \
    && cp /usr/local/crosware/software/sbase/current/bin/sbase-box /stow/ \
    && cp /usr/local/crosware/software/ubase/current/bin/ubase-box /stow/

# XXX - "git clean -fdx" in /usr/local/crosware so there's a clean checkout

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
    && /usr/bin/busybox ln -s /usr/bin/ /sbin \
    && /usr/bin/busybox ln -s /usr/bin/ /usr/sbin \
    && mkdir -p /home /root /tmp /var/spool/mail /var/www \
    && chmod 755 /home \
    && chmod 700 /root \
    && chmod 1777 /tmp \
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

# XXX - /etc/shells
# XXX - /etc/profile (bashrc, bash_profile, profile.d/, etc.)

CMD ["sh"]
