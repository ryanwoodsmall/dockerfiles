#
# run with:
#   docker run -d --privileged --network host --name $NAME --volume /lib/modules:/lib/modules:ro $IMG
#
#
# XXX - does NOT really run as non-root user
#       /var/lib/docker and /var/run/docker perms...
#
# XXX - replace docker w/latest static, eg. armhf:
#   cd /tmp \
#   wget https://download.docker.com/linux/static/stable/armhf/docker-19.03.5.tgz \
#   tar -zxvf docker-19.03.5.tgz \
#   find docker -type f | awk -F/ '{print $NF}' | sort | while read -r d ; do cat ./docker/$d > $(which $d) ; echo $d ; done \
#   rm -rf docker*
#
# XXX - for 32-bit builds...
#   prepend "linux32" and FROM i386/alpine or arm32v7/alpine on x86_64 and aarch64 builds, respectively
#   might _still_ need qemu-*
#   arm32v7/centos:7 breaks running as "armv8l" on aarch64
#

FROM alpine:latest

ARG contpass=alpine
ARG dockerip=0.0.0.0
ARG dockerport=22375
ARG sshport=22222

ENV contuser root
ENV ep /entrypoint.sh

USER root

RUN apk update \
    && apk upgrade \
    && apk add \
           bash \
           curl \
           docker \
           dropbear \
           dropbear-convert \
           dropbear-dbclient \
           findutils \
           openssh-client \
           openssh-keygen \
           openssh-sftp-server \
           screen \
           tini-static \
           vim \
    && getent passwd ${contuser} || useradd -m ${contuser} \
    && sed -i "/^docker:/s/\$/${contuser}/g" /etc/group \
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
    && echo 'rm -rf /var/lib/docker/runtimes /var/lib/docker/tmp' >> ${ep} \
    && echo "/usr/sbin/dropbear -R -E -p ${sshport}" >> ${ep} \
    && echo "/usr/bin/dockerd -H unix:///var/run/docker.sock -H tcp://${dockerip}:${dockerport} -s vfs" >> ${ep} \
    && chmod 755 ${ep}

ENTRYPOINT ["/sbin/tini-static","-s","-g","--"]
CMD ["sh","-c","/entrypoint.sh"]
