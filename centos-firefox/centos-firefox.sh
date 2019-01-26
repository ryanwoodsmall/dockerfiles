#!/bin/bash

#
# weird shell/docker thing
# awful race somewhere on startup/profile creation
# start twice, wonderful
#

set -eu

VENDOR="$(cut -f2- -d= ../common/common.mak | tr -d ' ')"
IMAGE="centos-firefox"
CONTAINER="${USER}-${IMAGE}"
TAG="${USER}"
FFUSER="firefoxuser"
FFHOME="/home/${FFUSER}"
BASEIMG="centos:latest"
XVOL="/tmp/.X11-unix"
ETCMID="/etc/machine-id"
RDBUSSOCK="/run/dbus/system_bus_socket"
RUUID="/run/user/${UID}"
SHM="/dev/shm"
ESLNCC="/etc/security/limits.d/99-zz-no-core.conf"
EP="/entrypoint.sh"

echo "
FROM ${BASEIMG}
RUN yum -y install firefox sudo psmisc \\
    && yum clean all \\
    && rm -rf /var/cache/yum
RUN /usr/sbin/groupadd -f -o -g ${GROUPS} ${FFUSER} \\
    && /usr/sbin/useradd -o -d ${FFHOME} -m -s /bin/bash -u ${UID} -g ${GROUPS} -G video ${FFUSER} \\
    && echo '${FFUSER} ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel \\
    && echo '* soft core 0' > ${ESLNCC} \\
    && echo '* hard core 0' >> ${ESLNCC} \\
    && echo 'firefox --no-remote -P ${FFUSER} \"\${@}\" || firefox --no-remote -P ${FFUSER} \"\${@}\"' > ${EP} \\
    && chmod 755 ${EP}
USER ${FFUSER}
RUN firefox --no-remote --headless -CreateProfile ${FFUSER} \\
    && firefox --no-remote --headless -CreateProfile ${FFUSER}
ENV HOME ${FFHOME}
WORKDIR ${FFHOME}
ENTRYPOINT [\"bash\",\"-x\",\"${EP}\"]
" | docker build --pull --tag ${VENDOR}/${IMAGE}:${TAG} -
#    && sudo -iu ${FFUSER} firefox --no-remote --headless https://www.google.com/ & sleep 5 \\
#ENTRYPOINT [\"firefox\"]
#CMD [\"--no-remote\",\"-P\",\"${FFUSER}\",\"--sync\",\"-no-remote\"]
docker run \
  --interactive \
  --env DISPLAY="${DISPLAY}" \
  --name ${CONTAINER} \
  --network host \
  --rm \
  --tty \
  --volume ${SHM}:${SHM}:rw \
  --volume ${XVOL}:${XVOL}:rw \
    ${VENDOR}/${IMAGE}:${TAG} \
      "${@}"

#  --env LANG="${LANG}" \
#  --volume ${ETCMID}:${ETCMID}:ro \
#  --volume ${RDBUSSOCK}:${RDBUSSOCK}:rw \
#  --volume ${RUUID}:${RUUID}:rw \
#  --env DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS}" \
#  --pid host \
