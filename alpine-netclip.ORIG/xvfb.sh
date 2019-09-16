#!/bin/bash
l="/var/log/xvfb.log"
echo -n > ${l}
while true ; do
  echo "${0}: starting Xvfb"
  u="$(cat ${clipdata}/user)"
  s="$(cat ${clipdata}/clipscreen)"
  su - ${u} -c ". /etc/profile ; /usr/bin/xinit -- /usr/bin/Xvfb :${s} -screen 0 1366x768x24" 2>&1 | tee -a ${l}
  sleep 1
done
