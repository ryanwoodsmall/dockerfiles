#!/usr/bin/env bash
#
# build riscv64 crosware
#
# override url with:
#   env u="file://$(realpath Dockerfile)" bash build.sh
#
# XXX - this is pretty general, could use for zulu
# XXX - use ${t} for target instead of ${a} for arch
#

set -e
set -u
set -o pipefail

v="ryanwoodsmall"
i="crosware"
a="riscv64"
c="${i}build${a}"

: ${u:="https://github.com/${v}/dockerfiles/raw/master/${i}/${a}/Dockerfile"}

docker rm ${c} || true
docker image rm ${c} || true
docker image rm ${v}/${i}:${a} || true

( time ( docker image pull ${v}/${i}
         curl -kLs ${u} \
         | docker build --tag ${c} - \
           && docker run --name ${c} ${c} bash -c 'uname -m ; curl --version ; bash --version ; set | egrep "(TYPE|BASH)"' \
           && docker export ${c} \
              | docker import -c 'CMD ["bash","-il"]' -c 'WORKDIR /usr/local/crosware' - ${v}/${i}:${a} \
                && docker rm ${c} \
                && docker image rm ${c}
) ) 2>&1 | tee /tmp/${c}.out
