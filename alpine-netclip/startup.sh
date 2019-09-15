#!/bin/bash
/dropbear.sh &
/xvfb.sh &
/x11vnc.sh &
wait
