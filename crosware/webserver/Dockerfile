FROM ryanwoodsmall/crosware

ENV BUSYBOX_HTTPD_PORT=80
ENV BUSYBOX_HTTPD_HOME=/data/http
ENV BUSYBOX_HTTPD_CONF=/etc/httpd.conf

WORKDIR /tmp

RUN . /etc/profile \
    && s='/startup.sh' \
    && bbver=`crosware run-func cwver_busybox` \
    && crosware install tini \
    && cp ${cwsw}/tini/current/sbin/tini /usr/sbin/ \
    && mkdir -p ${BUSYBOX_HTTPD_HOME}/cgi-bin \
    && curl -kLo httpd_ssi.c 'https://git.busybox.net/busybox/plain/networking/httpd_ssi.c?h=1_30_stable' \
    && curl -kLo httpd_indexcgi.c 'https://git.busybox.net/busybox/plain/networking/httpd_indexcgi.c?h=1_30_stable' \
    && gcc httpd_ssi.c -o httpd_ssi \
    && gcc httpd_indexcgi.c -o index.cgi \
    && cp httpd_ssi index.cgi /usr/bin/ \
    && cp index.cgi ${BUSYBOX_HTTPD_HOME}/cgi-bin/ \
    && rm -f httpd_{ssi,indexcgi}.c httpd_ssi index.cgi \
    && echo '#!/usr/bin/env bash' > ${s} \
    && echo 'set -x' >> ${s} \
    && echo '#set' >> ${s} \
    && echo 'exec /usr/bin/httpd -f -vv -c ${BUSYBOX_HTTPD_CONF} -h ${BUSYBOX_HTTPD_HOME} -p ${BUSYBOX_HTTPD_PORT}' >> ${s} \
    && chmod 755 ${s} \
    && echo "H:${BUSYBOX_HTTPD_HOME}" > ${BUSYBOX_HTTPD_CONF}

# XXX - cgi-bin on a volume doesn't work on a :ro bind/base mount
#VOLUME ${BUSYBOX_HTTPD_HOME}
#VOLUME ${BUSYBOX_HTTPD_HOME}/cgi-bin

WORKDIR ${BUSYBOX_HTTPD_HOME}

ENTRYPOINT ["/usr/sbin/tini","-gwvv","--"]

CMD ["/usr/bin/bash","/startup.sh"]

# vim: set ft=sh:
