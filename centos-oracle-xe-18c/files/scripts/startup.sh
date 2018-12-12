#!/bin/sh

source /sethostname.sh

/etc/init.d/oracle-xe-18c start

#tail -f /dev/null
tail -f /opt/oracle/diag/tnslsnr/${orahost}/listener/trace/listener.log
