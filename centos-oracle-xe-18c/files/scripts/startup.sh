#!/bin/sh

# XXX - need to "sysctl -p"

orainitd="/etc/init.d/oracle-xe-18c"

function stoporacle() {
  echo "stopping oracle"
  "${orainitd}" stop
}

trap stoporacle SIGINT
trap stoporacle SIGTERM

source /sethostname.sh

"${orainitd}" start

tail -f \
  /opt/oracle/diag/tnslsnr/${orahost}/listener/trace/listener.log \
  /opt/oracle/diag/rdbms/xe/XE/trace/alert_XE.log
