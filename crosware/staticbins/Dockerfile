FROM ryanwoodsmall/crosware AS bins

RUN tar -C / -cf /tmp/etc.tar $(find /etc/ -type f | egrep '(profile|bash|input|shells)')

FROM busybox:musl

RUN mkdir -p /usr/bin

COPY --from=bins /usr/bin/bash /usr/bin/bash
COPY --from=bins /usr/bin/busybox /usr/bin/busybox
COPY --from=bins /tmp/etc.tar /tmp/etc.tar

RUN /bin/busybox chmod 755 /usr/bin/* \
    && /bin/busybox ln -sf /usr/bin/bash /usr/bin/sh \
    && /bin/busybox ln -sf /usr/bin/bash /bin/bash \
    && /bin/busybox ln -sf /usr/bin/bash /bin/sh \
    && /usr/bin/busybox ln -sf /usr/bin/busybox /bin/busybox \
    && /usr/bin/busybox tar -C / -xf /tmp/etc.tar

RUN cd /usr/bin \
    && for a in $(/usr/bin/busybox --list) ; do test -e "/usr/bin/${a}" || /usr/bin/busybox ln -s /usr/bin/busybox "/usr/bin/${a}" ; done \
    && for a in $(/usr/bin/busybox --list) ; do /usr/bin/busybox rm -f "/bin/${a}" ; /usr/bin/busybox ln -s /usr/bin/busybox "/bin/${a}" ; done \
    && /usr/bin/busybox rm -rf /bin \
    && /usr/bin/busybox ln -sf /usr/bin /bin \
    && /usr/bin/busybox rm -rf /sbin \
    && /usr/bin/busybox ln -sf /usr/bin /sbin \
    && /usr/bin/busybox rm -rf /usr/sbin \
    && /usr/bin/busybox ln -sf /usr/bin /usr/sbin \
    && /usr/bin/busybox sed -i.ORIG 's,/bin/ash,/bin/bash,g' /etc/passwd \
    && /usr/bin/busybox sed -i 's,/bin/sh,/bin/bash,g' /etc/passwd

RUN /usr/bin/busybox wget -O - https://raw.githubusercontent.com/ryanwoodsmall/crosware/master/scripts/install-static-bins.sh | env cwtmp='/' bash \
    && echo 'export PATH="${PATH}:/static/bin"' >> /etc/profile.d/zz_local.sh \
    && source /etc/profile.d/zz_local.sh \
    && /static/bin/curl -kLs https://raw.githubusercontent.com/ryanwoodsmall/crosware/master/scripts/update-crosware-from-tar.sh | bash \
    && source /usr/local/crosware/scripts/reset-cwenv.sh \
    && /usr/local/crosware/bin/crosware reinstall statictoolchain \
    && rm -f /usr/local/tmp/*

WORKDIR "/usr/local/crosware"

CMD ["/usr/bin/bash","-il"]
