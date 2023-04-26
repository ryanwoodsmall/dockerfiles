#
# build acme's micro_proxy and wrap with tls using socat
#
# links:
# - http://www.acme.com/software/micro_proxy/
# - http://www.dest-unreach.org/socat/
#
# default config is controlled through environment:
# - PORT : 8119
# - KEY  : /home/proxy/proxy.key
# - CERT : /home/proxy/proxy.crt
# - CA   : /home/proxy/ca.crt
#
# client certs are verified against the CA by default
# add "-E EXTRA=',verify=0'" to docker run to override (insecure!)
#
# run with something like...
# docker run -d --name micro_proxy-socat -p 8119:8119 --restart always -v key.pem:/home/proxy/proxy.key:ro -v cert.pem:/home/proxy/proxy.crt:ro -v ca.pem:/home/proxy/ca.crt:ro micro_proxy-socat
#
# XXX - include libressl openssl, libressl-nc?
# XXX - server: socat -d -d openssl-listen:8119,cert=${cwtop}/tmp/bearssl.crt,key=${cwtop}/tmp/bearssl.key,cafile=${cwtop}/tmp/ca.crt,fork,reuseaddr exec:micro_proxy
# XXX - client: socat -d -d tcp-listen:8120,fork,reuseaddr openssl-connect:$REMOTE_HOST:8119,cert=${cwtop}/tmp/bearssl.crt,key=${cwtop}/tmp/bearssl.key,cafile=${cwtop}/tmp/ca.crt
#

FROM ryanwoodsmall/crosware AS cw
RUN source /etc/profile \
    && echo 'export CFLAGS="${CFLAGS} -g0 -Os -Wl,-s"' >> $cwtop/etc/local.d/zz_local.sh \
    && echo 'export CXXFLAGS="${CXXFLAGS} -g0 -Os -Wl,-s"' >> $cwtop/etc/local.d/zz_local.sh \
    && time crosware update \
    && time crosware reinstall bearssl microproxy px5g socatlibressl tini x509cert \
    && source $cwtop/etc/profile \
    && mkdir -p /stow \
    && for p in brssl micro_proxy px5g socatlibressl tini x509cert ; do cp $(realpath $(which $p)) /stow/$p ; done \
    && strip --strip-all /stow/* || true

FROM busybox:musl
RUN rm -rf /sbin /usr/bin /usr/sbin \
    && mkdir -p /usr/bin /usr/local/bin \
    && ln -sf /usr/bin /sbin \
    && ln -sf /usr/bin /usr/sbin
COPY --from=cw /usr/bin/bash /usr/bin/bash
COPY --from=cw /usr/bin/busybox /usr/bin/busybox
COPY --from=cw /usr/bin/curl /usr/bin/curl
COPY --from=cw /usr/bin/toybox /usr/bin/toybox
COPY --from=cw /stow/brssl /usr/bin/brssl
COPY --from=cw /stow/micro_proxy /usr/bin/micro_proxy
COPY --from=cw /stow/px5g /usr/bin/px5g
COPY --from=cw /stow/socatlibressl /usr/bin/socat
COPY --from=cw /stow/tini /usr/bin/tini
COPY --from=cw /stow/x509cert /usr/bin/x509cert
RUN ( cd /bin ; for l in $(./busybox --list) ; do /usr/bin/busybox ln -sf busybox $l ; done ) \
    && /usr/bin/busybox ln -sf /usr/bin/bash /bin/bash \
    && /usr/bin/busybox ln -sf /usr/bin/bash /bin/sh \
    && /usr/bin/busybox ln -sf /usr/bin/busybox /bin/busybox \
    && ( cd /usr/bin ; for l in $(./busybox --list) ; do test -e $l || ln -s busybox $l ; done ) \
    && ( cd /usr/bin ; for l in $(./toybox) ; do test -e $l || ln -s toybox $l ; done ) \
    && ( cd /bin ; find . -type f -exec basename {} \; | while -read r b ; do if [ -e /usr/bin/$b ] ; then rm -f $b ; else mv $b /usr/bin/$b ; fi ; done )
RUN /usr/bin/busybox rm -rf /bin \
    && /usr/bin/busybox ln -sf /usr/bin /bin
RUN echo 'export PS1="\u@\h \W \$ "' >> /etc/profile \
    && addgroup -S proxy -g 1000 \
    && adduser -G proxy -s /bin/bash -D -H -h /home/proxy -g proxy -S -u 1000 proxy \
    && mkdir /home/proxy \
    && chown proxy:proxy /home/proxy
RUN export i=/init.sh \
    && echo -n > $i \
    && chmod 755 $i \
    && echo '#!/usr/bin/env bash' >> $i \
    && echo ': ${PORT:=8119}' >> $i \
    && echo ': ${KEY:=/home/proxy/proxy.key}' >> $i \
    && echo ': ${CERT:=/home/proxy/proxy.crt}' >> $i \
    && echo ': ${CA:=/home/proxy/ca.crt}' >> $i \
    && echo ': ${EXTRA:=""}' >> $i \
    && echo 'test -e $KEY || { echo generaating key in $KEY ; brssl skey -gen rsa:2048 -rawpem $KEY ; chmod 600 $KEY ; }' >> $i \
    && echo 'test -e $CERT || { echo generating cert in $CERT ; x509cert -a $(hostname) -d $((100*366*24*60*60)) $KEY CN=$(hostname) > $CERT ; }' >> $i \
    && echo 'test -e $CA || { echo appending $CERT to $CA ; cat $CERT >> $CA ; }' >> $i \
    && echo 'echo starting socat on port $PORT' >> $i \
    && echo 'exec socat -d -d openssl-listen:${PORT},cert=${CERT},key=${KEY},cafile=${CA},fork,reuseaddr${EXTRA} exec:micro_proxy' >> $i

EXPOSE 8119
USER "proxy"
WORKDIR "/home/proxy"
ENTRYPOINT ["/sbin/tini","-gwvv","--"]
#CMD ["/usr/bin/bash","-il"]
CMD ["/init.sh"]
