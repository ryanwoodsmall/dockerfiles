#!/usr/bin/env bash

( time ( docker image pull ryanwoodsmall/crosware
         curl -kLs https://github.com/ryanwoodsmall/dockerfiles/raw/master/crosware/riscv64/Dockerfile \
         | docker build --tag blah - \
           && docker run --name blah blah bash -c 'uname -m ; curl --version ; bash --version ; set | egrep "(TYPE|BASH)"' \
           && docker export blah \
              | docker import -c 'CMD ["bash","-il"]' -c 'WORKDIR /usr/local/crosware' - ryanwoodsmall/crosware:riscv64 \
                && docker image push ryanwoodsmall/crosware:riscv64 \
                && docker rm blah \
                && docker image rm blah
) ) 2>&1 | tee /tmp/riscv64build.out
