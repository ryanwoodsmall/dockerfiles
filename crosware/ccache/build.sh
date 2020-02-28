#!/bin/bash

set -eu

basecon="ryanwoodsmall/crosware:latest"
ccachecon="crosware-ccache"
crosware="/usr/local/crosware/bin/crosware"

declare -A volumes
volumes["crosware-ccache"]="/root/.ccache"
volumes["crosware-downloads"]="/usr/local/crosware/downloads"
vopts=""

for v in ${!volumes[@]} ; do
  docker volume ls --quiet --filter name="${v}" | wc -l | grep -q '^1$' \
  || docker volume create "${v}"
  vopts+="-v ${v}:${volumes[${v}]} "
done

docker pull ${basecon}
docker kill ${ccachecon} || true
docker rm ${ccachecon} || true
docker run --name ${ccachecon} ${vopts} ${basecon} bash -l ${crosware} install ccache \
&& docker commit -c 'CMD ["bash","-il"]' -c 'WORKDIR /usr/local/crosware' ${ccachecon} ${basecon} \
&& docker rm ${ccachecon}
