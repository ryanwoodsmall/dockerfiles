FROM ryanwoodsmall/crosware

ENV BUSYBOX_HTTPD_PORT=80
ENV BUSYBOX_HTTPD_HOME=/data/http
ENV BUSYBOX_HTTPD_CONF=/etc/httpd.conf.DEFAULT

WORKDIR /tmp

RUN . /etc/profile \
    && crosware install tini \
    && cp ${cwsw}/tini/current/sbin/tini /usr/sbin/ \
    && mkdir -p ${BUSYBOX_HTTPD_HOME}/cgi-bin \
    && curl -kLo httpd_indexcgi.c 'https://git.busybox.net/busybox/plain/networking/httpd_indexcgi.c?h=1_30_stable' \
    && curl -kLo httpd_post_upload.cgi 'https://git.busybox.net/busybox/plain/networking/httpd_post_upload.cgi?h=1_30_stable' \
    && curl -kLo httpd_ssi.c 'https://git.busybox.net/busybox/plain/networking/httpd_ssi.c?h=1_30_stable' \
    && gcc httpd_indexcgi.c -o index.cgi -static \
    && gcc httpd_ssi.c -o httpd_ssi -static \
    && chmod 755 httpd_post_upload.cgi \
    && cp -a httpd_post_upload.cgi index.cgi httpd_ssi /usr/bin/ \
    && cp -a index.cgi ${BUSYBOX_HTTPD_HOME}/cgi-bin/ \
    && rm -f httpd_{indexcgi,post_upload,ssi}.c{,gi} httpd_ssi index.cgi \
    && echo "H:${BUSYBOX_HTTPD_HOME}" > ${BUSYBOX_HTTPD_CONF}

WORKDIR ${BUSYBOX_HTTPD_HOME}

ENTRYPOINT ["/usr/sbin/tini","-gwvv","--"]

CMD /usr/bin/env -i /usr/bin/httpd -f -vv -h ${BUSYBOX_HTTPD_HOME} -p ${BUSYBOX_HTTPD_PORT}

# vim: set ft=sh:
