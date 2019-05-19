FROM alpine

ENV siabuser  shellinabox
ENV siabshell /bin/ash
ENV siabport  4200
ENV siabname  ${siabuser}
ENV siabtop   /opt/${siabname}
ENV siabhome  /home/${siabuser}
ENV siabver   2.20
ENV siaburl   https://github.com/${siabname}/${siabname}/archive/v${siabver}.tar.gz
ENV siabdir   ${siabname}-${siabver}
ENV siabfile  ${siabdir}.tar.gz
ENV siabinst  ${siabtop}/${siabdir}
ENV siabcss   ${siabinst}/css
ENV siabcert  ${siabtop}/cert
ENV sudoersd  /etc/sudoers.d
ENV siabep    /entrypoint.sh

ADD ${siaburl} /tmp/${siabfile}

RUN sleep 1 \
    && apk update \
    && apk upgrade \
    && apk add sudo \
    && apk add autoconf automake gcc libtool make musl-dev openssl openssl-dev zlib-dev \
    && mkdir -p ${siabtop} \
    && adduser -h ${siabhome} -s ${siabshell} -D ${siabuser} \
    && mkdir -p ${sudoersd} \
    && echo "${siabuser} ALL=(ALL:ALL) NOPASSWD: ALL" > ${sudoersd}/${siabuser} \
    && cd /tmp \
    && tar -zxf ${siabfile} \
    && cd ${siabdir} \
    && autoreconf -fiv \
    && env CONFIG_SHELL=/bin/ash ./configure --prefix=${siabinst} --disable-pam --disable-utmp --disable-runtime-loading LIBS='-lcrypto -lssl -lz' \
    && make \
    && make install \
    && mkdir ${siabcss} \
    && mkdir ${siabcert} \
    && chown ${siabuser}:${siabuser} ${siabcert} \
    && chmod 770 ${siabcert} \
    && cp ${siabname}/*.css ${siabcss} \
    && cd ${siabtop} \
    && ln -s ${siabdir} current \
    && rm -rf /tmp/${siabdir} /tmp/${siabfile} \
    && apk del autoconf automake gcc libtool make musl-dev openssl-dev zlib-dev \
    && chown -R ${siabuser}:${siabuser} ${siabtop} \
    && echo "#!/bin/sh" > ${siabep} \
    && echo "${siabtop}/current/bin/shellinaboxd \\" >> ${siabep} \
    && echo "  --user-css='Normal:+${siabcss}/white-on-black.css,Reverse:-${siabcss}/black-on-white.css' \\" >> ${siabep} \
    && echo "  --port=${siabport} \\" >> ${siabep} \
    && echo "  --service='/:${siabuser}:${siabuser}:${siabhome}:${siabshell} -l' \\" >> ${siabep} \
    && echo "  --user=${siabuser} \\" >> ${siabep} \
    && echo "  --cert=${siabcert} \\" >> ${siabep} \
    && echo "  --verbose \\" >> ${siabep} \
    && echo "    2>&1 | tee -a /tmp/${siabname}.out" >> ${siabep} \
    && chmod 755 ${siabep}

USER ${siabuser}

EXPOSE ${siabport}

CMD [ "/entrypoint.sh" ]
