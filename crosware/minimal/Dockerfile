#
# busybox:musl with crosware installed from .zip
#
# XXX - need another layer for this swap since busybox is in use
#   && cp -a /bin/busybox /bin/busybox.ORIG \
#   && curl -kLo /bin/busybox https://github.com/ryanwoodsmall/static-binaries/raw/master/${a}/busybox \
#   && toybox chmod 755 /bin/busybox \
#   && for i in $(busybox --list | grep -v '^bash$') ; do ( cd /bin/ ; ln -sf busybox $i ) ; done \
#

FROM ryanwoodsmall/crosware:latest AS CROSWARE

FROM busybox:musl

COPY --from=CROSWARE /usr/bin/bash /bin/

RUN cd /bin \
    && chmod 755 bash \
    && rm -f sh \
    && ln -sf bash sh

COPY --from=CROSWARE /usr/bin/busybox /bin/
COPY --from=CROSWARE /usr/bin/toybox /bin/

RUN cd /bin \
    && chmod 755 /bin/toybox \
    && for i in $(busybox --list | egrep -v '^(ba|)sh$') ; do ( cd /bin/ ; toybox rm $i ; toybox ln -sf busybox $i ) ; done

COPY --from=CROSWARE /usr/bin/curl /bin/

ENV cwtop=/usr/local/crosware

RUN ln -s /bin /usr/bin \
    && uname -m | grep -q ^aarch && a=aarch64 || true \
    && uname -m | grep -q ^arm && a=armhf || true \
    && uname -m | grep -q ^i && a=i686 || true \
    && uname -m | grep -q ^r && a=riscv64 || true \
    && uname -m | grep -q ^x86_64 && a=x86_64 || true \
    && echo ${a} \
    && chmod 755 /bin/bash /bin/curl /bin/toybox \
    && rm -f /bin/sh \
    && ln -sf /bin/bash /bin/sh \
    && for i in $(toybox) ; do ( cd /bin/ ; test -e $i || ln -s toybox $i ) ; done \
    && sed -i.ORIG s,/bin/sh,/bin/bash,g /etc/passwd \
    && mkdir -p ${cwtop}/tmp \
    && cd ${cwtop}/tmp \
    && curl -kLo update-crosware-from-zip.sh https://github.com/ryanwoodsmall/crosware/raw/master/scripts/update-crosware-from-zip.sh \
    && bash update-crosware-from-zip.sh \
    && rm -f update-crosware-from-zip.sh \
    && mkdir -p /etc/profile.d \
    && echo 'for i in /etc/profile.d/*.sh ; do . ${i} ; done' >> /etc/profile \
    && echo "export cwtop=${cwtop}" >> /etc/profile.d/crosware.sh \
    && echo 'export PATH="${PATH}:${cwtop}/bin"' >> /etc/profile.d/crosware.sh \
    && echo 'test -z "${BASH_VERSION}" && true || . "${cwtop}/etc/profile"' >> /etc/profile.d/crosware.sh \
    && echo 'export PS1="\u@crosware-$(uname -m) \W \$ "' >> /etc/profile.d/crosware.sh \
    && echo 'export PATH="${HOME}/bin:${PATH}"' >> /etc/profile.d/crosware.sh \
    && ${cwtop}/bin/crosware install cacertificates statictoolchain \
    && rm -f /usr/local/tmp/* ${cwtop}/downloads/*/*

WORKDIR ${cwtop}

CMD ["bash","-il"]
