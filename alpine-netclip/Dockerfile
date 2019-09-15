#
# use ssh+xclip+xvnc+xvfb as a network-addressible clipboard
#
# https://wiki.alpinelinux.org/wiki/Remote_Desktop_Server
# https://github.com/danielguerra69/alpine-vnc
# https://github.com/jkuri/alpine-xfce4
#
# XXX - debug environment var - run vs build time
# XXX - log to ${clipdata}/history/ w/debug on - $(date +%s%N) for nanonsecond
# XXX - watch a fifo?
#

FROM alpine

# port choices, add em up
# - x11: 6000
# - vnc: 5900
# - ssh: 22
ENV vncport 11900
ENV clipport 11922
ENV clipscreen 99
ENV clipuser clippy
ENV cliphome /home/${clipuser}
ENV clipdata /data/clip

EXPOSE ${clipport}

COPY dropbear.sh /
COPY xvfb.sh /
COPY x11vnc.sh /
COPY startup.sh /
COPY clip /

RUN chmod 755 /*.sh \
    && apk --no-cache update \
    && apk --no-cache upgrade \
    && apk --no-cache add bash coreutils busybox-extras busybox-initscripts dropbear file openbox openssh-keygen openssl procps psmisc sudo tini vim x11vnc xclip xinit xsetroot xterm xvfb \
    && rm -f /bin/sh \
    && ln -s /bin/bash /bin/sh \
    && ln -s /clip /usr/bin/ \
    && sed -i.ORIG '/^root:/s#/bin/ash#/bin/bash#g' /etc/passwd \
    && mkdir -p /etc/dropbear ${clipdata} \
    && sed -i.ORIG "/^wheel:/s/:root/:root,${clipuser}/g" /etc/group \
    && sed -i "/^shadow:/s/:\$/:${clipuser}/g" /etc/group \
    && echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel \
    && chmod 600 /etc/sudoers.d/wheel \
    && openssl rand -base64 16 > ${clipdata}/passwd \
    && echo ${clipuser} > ${clipdata}/user \
    && echo ${clipport} > ${clipdata}/clipport \
    && echo ${clipscreen} > ${clipdata}/clipscreen \
    && echo ${vncport} > ${clipdata}/vncport \
    && echo "export clipdata=${clipdata}" > /etc/profile.d/clip.sh \
    && addgroup -S ${clipuser} \
    && adduser -D -S -G ${clipuser} -s /bin/bash -h ${cliphome} ${clipuser} \
    && echo "${clipuser}:$(cat ${clipdata}/passwd)" | chpasswd \
    && su - ${clipuser} -c "mkdir -p ${cliphome}/.vnc" \
    && su - ${clipuser} -c "x11vnc -storepasswd '$(cat ${clipdata}/passwd)' ${cliphome}/.vnc/passwd" \
    && echo 'xsetroot -solid darkslategrey' > ${cliphome}/.xinitrc \
    && echo 'exec openbox' >> ${cliphome}/.xinitrc \
    && chmod 755 ${cliphome}/.x* \
    && chown -R ${clipuser}:${clipuser} ${cliphome} ${clipdata} /etc/dropbear \
    && chmod 640 ${clipdata}/*

#EXPOSE ${vncport}
#RUN openssl rand -base64 16 > ${clipdata}/debug \
#    && adduser -D -S -G wheel -s /bin/bash debug \
#    && echo "debug:$(cat ${clipdata}/debug)" | chpasswd \
#    && chmod 640 ${clipdata}/*

ENTRYPOINT ["/sbin/tini","-gwvv","--"]

CMD ["/startup.sh"]

# vim: set ft=sh:
