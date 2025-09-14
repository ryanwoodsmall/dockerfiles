#
# busybox:musl with crosware installed from .zip
#

FROM ryanwoodsmall/crosware:latest AS crosware

FROM busybox:musl

RUN rm -rf /usr/bin && mkdir -p /usr/bin && test -d /usr/bin

COPY --from=crosware /usr/bin/bash /usr/bin/bash
COPY --from=crosware /usr/bin/busybox /usr/bin/busybox
COPY --from=crosware /usr/bin/curl /usr/bin/curl
COPY --from=crosware /usr/bin/toybox /usr/bin/toybox

COPY --from=crosware /etc/inputrc /etc/

RUN chmod 755 /usr/bin/* \
    && cd /usr/bin \
    && ln -sf /usr/bin/bash /usr/bin/sh \
    && for a in $(/usr/bin/busybox --list) ; do test -e /usr/bin/${a} || /usr/bin/busybox ln -sf /usr/bin/busybox /usr/bin/${a} ; done \
    && for a in $(/usr/bin/toybox) ; do test -e /usr/bin/${a} || /usr/bin/busybox ln -sf /usr/bin/toybox /usr/bin/${a} ; done

RUN cd /bin \
    && /usr/bin/busybox ln -sf /usr/bin/busybox /bin/busybox \
    && for a in $(/usr/bin/busybox --list) ; do /usr/bin/busybox ln -sf /usr/bin/busybox /bin/${a} ; done \
    && /usr/bin/busybox rm -f /bin/bash \
    && /usr/bin/busybox ln -sf /usr/bin/bash /bin/bash \
    && /usr/bin/busybox rm -f /bin/sh \
    && /usr/bin/busybox ln -sf /usr/bin/bash /bin/sh

RUN cd / \
    && /usr/bin/busybox rm -rf /bin /sbin /usr/sbin \
    && /usr/bin/busybox ln -sf /usr/bin /bin \
    && /usr/bin/busybox ln -sf /usr/bin /sbin \
    && /usr/bin/busybox ln -sf /usr/bin /usr/sbin

ENV cwtop=/usr/local/crosware

RUN cd / \
    && uname -m | grep -q ^aarch && a=aarch64 || true \
    && uname -m | grep -q ^arm && a=armhf || true \
    && uname -m | grep -q ^i && a=i686 || true \
    && uname -m | grep -q ^r && a=riscv64 || true \
    && uname -m | grep -q ^x86_64 && a=x86_64 || true \
    && echo ${a} \
    && sed -i.ORIG s,/bin/sh,/bin/bash,g /etc/passwd \
    && echo /bin/bash >> /etc/shells \
    && echo /usr/bin/bash >> /etc/shells \
    && echo /bin/ash >> /etc/shells \
    && echo /usr/bin/ash >> /etc/shells \
    && echo /bin/sh >> /etc/shells \
    && echo /usr/bin/sh >> /etc/shells \
    && mkdir -p /run \
    && ln -sf /run /var/ \
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
    && ${cwtop}/bin/crosware install cacertificates statictoolchain alpinemuslutils tini shellish dropbearminimal ccache \
    && bash ${cwtop}/scripts/install-dotfiles.sh \
    && cat ~/.exrc > /etc/vi.exrc \
    && rm -f /usr/local/tmp/* ${cwtop}/downloads/*/* \
    && test -e /usr/local/bin || mkdir -p /usr/local/bin

WORKDIR ${cwtop}

CMD ["bash","-il"]
