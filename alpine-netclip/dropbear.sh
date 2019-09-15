#!/bin/bash
l="/var/log/dropbear.log"
echo -n > ${l}
while true ; do
  u="$(cat ${clipdata}/user)"
  p="$(cat ${clipdata}/clipport)"
  echo "${0}: starting dropbear"
  echo "user: ${u}"
  test -e ${clipdata}/passwd && {
    echo "pass: $(cat ${clipdata}/passwd)"
  }
  echo "clipport: ${p}"
  echo "vncport: $(cat ${clipdata}/vncport)"
  test -e ${clipdata}/debug && {
    echo "debug: $(cat ${clipdata}/debug)"
  }
  rm -f /var/run/dropbear.pid
  su - ${u} -c "/usr/sbin/dropbear -R -F -E -B -p ${p}" 2>&1 | tee -a ${l}
  sleep 1
done
