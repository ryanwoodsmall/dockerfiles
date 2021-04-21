#!/usr/bin/env bash

set -e
set -u
set -o pipefail

v="ryanwoodsmall"
i="crosware"
a="riscv64"
c="${i}build${a}"

docker rm ${c} || true
docker image rm ${c} || true
docker image rm ${v}/${i}:${a} || true

( time ( docker image pull ${v}/${i}
         curl -kLs https://github.com/${v}/dockerfiles/raw/master/${i}/${a}/Dockerfile \
         | docker build --tag ${c} - \
           && docker run --name ${c} ${c} bash -c 'uname -m ; curl --version ; bash --version ; set | egrep "(TYPE|BASH)"' \
           && docker export ${c} \
              | docker import -c 'CMD ["bash","-il"]' -c 'WORKDIR /usr/local/crosware' - ${v}/${i}:${a} \
                && docker image push ${v}/${i}:${a} \
                && docker rm ${c} \
                && docker image rm ${c}
) ) 2>&1 | tee /tmp/${c}.out
