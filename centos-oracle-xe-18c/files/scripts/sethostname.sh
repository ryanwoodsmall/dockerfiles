#!/bin/sh

if [ -z "${orahost}" ] ; then
  orahost="oraxe18c"
fi

grep -qi "^127\.0\.0\.1.*${orahost}" /etc/hosts || {
  cat /etc/hosts > /etc/hosts.ORIG
  cat /etc/hosts > /etc/hosts.WORK
  sed -i "/^127\.0\.0\.1/ s/$/ ${orahost}/g" /etc/hosts.WORK
  cat /etc/hosts.WORK > /etc/hosts
  rm -f /etc/hosts.WORK
}
echo "${orahost}" > /etc/hostname
hostname "${orahost}"
HOSTNAME="${orahost}"
export HOSTNAME
export orahost
