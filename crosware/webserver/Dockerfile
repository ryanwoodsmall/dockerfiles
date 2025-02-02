FROM ryanwoodsmall/crosware

ENV BUSYBOX_HTTPD_PORT=80
ENV BUSYBOX_HTTPD_HOME=/data/http
ENV BUSYBOX_HTTPD_CONF=/etc/httpd.conf.DEFAULT

WORKDIR /tmp

RUN . /etc/profile \
    && pushd ${cwtop} \
    && rm -rf recipes \
    && bash ${cwtop}/scripts/update-crosware-from-tar.sh \
    && crosware install tini \
    && cp ${cwsw}/tini/current/sbin/tini /usr/sbin/ \
    && rm -rf cgi-bin \
    && bash ${cwtop}/scripts/install-busybox-cgi-helpers.sh \
    && mkdir -p ${BUSYBOX_HTTPD_HOME}/cgi-bin \
    && ( cd cgi-bin ; tar -cf - . ) | ( cd ${BUSYBOX_HTTPD_HOME}/cgi-bin/ ; tar -xvf - ) \
    && popd \
    && echo "H:${BUSYBOX_HTTPD_HOME}" > ${BUSYBOX_HTTPD_CONF}

WORKDIR ${BUSYBOX_HTTPD_HOME}

ENTRYPOINT ["/usr/sbin/tini","-gwvv","--"]

CMD /usr/bin/env -i /usr/bin/httpd -f -vv -h ${BUSYBOX_HTTPD_HOME} -p ${BUSYBOX_HTTPD_PORT}

# vim: set ft=sh:
