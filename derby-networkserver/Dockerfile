FROM alpine:latest

ENV derbytop     /opt/derby
ENV derbydbdir   ${derbytop}/db
ENV derbystart   ${derbytop}/startderby.sh
ENV derbyversion 10.14.2.0
ENV derbydir     db-derby-${derbyversion}-bin
ENV derbyfile    ${derbydir}.tar.gz
ENV derbyurl     http://www-us.apache.org/dist/db/derby/db-derby-${derbyversion}/${derbyfile}
ENV derbysha256  980fb0534c38edf4a529a13fb4a12b53d32054827b57b6c5f0307d10f17d25a8
ENV derbyport    1527
ENV profdfile    /etc/profile.d/zz_local.sh

EXPOSE ${derbyport}

VOLUME ${derbydbdir}

RUN apk update \
    && apk upgrade \
    && apk add bash openjdk8 \
    && ln -sf /bin/bash /bin/sh \
    && sed -i.ORIG 's#/bin/ash#/bin/bash#g' /etc/passwd \
    && ln -sf /etc/profile ~/.profile \
    && ln -sf ~/.profile ~/.bash_profile \
    && ln -sf ~/.profile ~/.bashrc \
    && echo > ${profdfile} \
    && echo 'export JAVA_HOME=/usr/lib/jvm/default-jvm' >> ${profdfile} \
    && echo "export DERBY_HOME=${derbytop}/current" >> ${profdfile} \
    && echo 'export PATH=${PATH}:${DERBY_HOME}/bin:${JAVA_HOME}/bin' >> ${profdfile} \
    && mkdir -p ${derbytop} \
    && mkdir -p ${derbydbdir} \
    && cd ${derbytop} \
    && wget ${derbyurl} \
    && sha256sum ${derbyfile} | awk '{print $1}' | grep -q "^${derbysha256}$" \
    && tar -zxf ${derbyfile} \
    && rm -f ${derbyfile} \
    && ln -sf ${derbydir} current \
    && echo '#!/bin/bash' > ${derbystart} \
    && echo "cd ${derbydbdir}" >> ${derbystart} \
    && echo 'ln -sf /dev/stdout derby.log' >> ${derbystart} \
    && echo 'source /etc/profile' >> ${derbystart} \
    && echo 'sysinfo' >> ${derbystart} \
    && echo 'export _JAVA_OPTIONS="-Dderby.drda.logConnections=true"' >> ${derbystart} \
    && echo "startNetworkServer -h 0.0.0.0 -p ${derbyport}" >> ${derbystart} \
    && chmod 755 ${derbystart}

WORKDIR ${derbydbdir}

CMD ${derbystart}
