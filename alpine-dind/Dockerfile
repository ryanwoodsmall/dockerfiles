#
# run with:
#   docker run -d --privileged --network host --name $NAME --volume /lib/modules:/lib/modules:ro $IMG
#
#
# XXX - does NOT really run as non-root user
#       /var/lib/docker and /var/run/docker perms...
#

FROM alpine:latest

ARG contpass=alpine
ARG dockerip=0.0.0.0
ARG dockerport=2375
ARG sshport=22222

ENV contuser root
ENV ep /entrypoint.sh

USER root

RUN apk update \
    && apk upgrade \
    && apk add \
           bash \
           docker \
           dropbear \
           dropbear-convert \
           dropbear-dbclient \
           openssh-client \
           openssh-keygen \
           openssh-sftp-server \
           tini-static \
    && getent passwd ${contuser} || useradd -m ${contuser} \
    && usermod -G docker -a ${contuser} \
    && sed -i "/^${contuser}:/s/ash$/bash/g" /etc/passwd \
    && echo "${contuser}:${contpass}" | chpasswd \
    && hd=`getent passwd ${contuser} | cut -f6 -d:` \
    && mkdir -p ${hd}/.ssh \
    && chmod 700 ${hd}/.ssh \
    && chown ${contuser}:${contuser} ${hd}/.ssh \
    && mkdir -p /etc/dropbear \
    && touch /var/log/lastlog \
    && rm -rf /var/cache/apk/* \
    && echo '#!/bin/sh' > ${ep} \
    && echo 'rm -f /var/run/docker.pid /var/run/dropbear.pid /run/docker/containerd/containerd.pid /run/dropbear.pid /run/docker.pid' >> ${ep} \
    && echo "/usr/sbin/dropbear -R -E -p ${sshport}" >> ${ep} \
    && echo "/usr/bin/dockerd -H unix:///var/run/docker.sock -H tcp://${dockerip}:${dockerport} -s vfs" >> ${ep} \
    && chmod 755 ${ep}

ENTRYPOINT ["/sbin/tini-static","-s","-g"]
CMD ${ep}
