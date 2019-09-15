#!/bin/bash
l="/var/log/x11vnc.log"
echo -n > ${l}
while true ; do
  echo "${0}: starting x11vnc"
  p="$(cat ${clipdata}/vncport)"
  s="$(cat ${clipdata}/clipscreen)"
  u="$(cat ${clipdata}/user)"
  h="$(getent passwd ${u} | awk -F: '{print $(NF-1)}')"
  su - ${u} -c ". /etc/profile ; /usr/bin/x11vnc -localhost -listen localhost -xkb -noxrecord -noxfixes -noxdamage -display :${s} -forever -rfbauth ${h}/.vnc/passwd -users ${u} -rfbport ${p}" 2>&1 | tee -a ${l}
  sleep 1
done
