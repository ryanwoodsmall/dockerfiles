#!/bin/sh

# XXX - need to "sysctl -p"

# XXX - trap SIGTERM, run stop script
#   https://stackoverflow.com/questions/41451159/how-to-execute-a-script-when-i-terminate-a-docker-container

source /sethostname.sh

/etc/init.d/oracle-xe-18c start

tail -f /opt/oracle/diag/tnslsnr/${orahost}/listener/trace/listener.log
