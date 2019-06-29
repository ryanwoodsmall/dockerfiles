#!/bin/bash

#
# scatter:
#   run this natively on arm32/arm64/amd64/i386 to build the container
#   tmux windowpanes, gnu parallel, jenkins, whatever floats your boat
#
# gather:
#   # using dbclient with keys exchanged
#   # a better solution is to use a local registry
#   # can forward a central (localhost:5000), tag as localhost:5000/ryanwoodsmall/crosware:arch, push, then tag and push
#   # for i386:
#   #   docker run -d -p 5000:5000 --restart always --name registry registry:2
#   #   ssh -R 5000:localhost:5000 i386 docker image tag ryanwoodsmall/crosware:i386 localhost:5000/ryanwoodsmall/crosware:i386
#   #   ssh -R 5000:localhost:5000 i386 docker image push localhost:5000/ryanwoodsmall/crosware:i386
#   #   docker pull localhost:5000/ryanwoodsmall/crosware:i386
#   #   docker tag localhost:5000/ryanwoodsmall/crosware:i386 ryanwoodsmall/crosware:i386
#   #   docker push ryanwoodsmall/crosware:i386
#   # manual:
#   for n in $(for h in amd64 i386/2222 arm32v6/222 arm64v8 ; do dbclient -y -y ${h} docker image ls | awk '/ryanwoodsmall\/crosware:(amd64|arm32v6|arm64v8|i386)/{print $1":"$2}' | sed "s#^#${h}:#g" ; done) ; do
#     dbclient -y -y ${n%%:*} docker save ${n#*:} | docker load
#   done
#
# push:
#   for a in amd64 arm32v6 arm64v8 i386 ; do
#     docker push ryanwoodsmall/crosware:${a}
#   done
#
# manifest:
#   docker manifest create ryanwoodsmall/crosware:{latest,arm64v8,arm32v6,amd64,i386}
#   docker manifest push --purge ryanwoodsmall/crosware:latest
#

set -eu

v="ryanwoodsmall"
c="crosware"
b="${c}build"
u="https://raw.githubusercontent.com/${v}/dockerfiles/master/${c}/Dockerfile"
a="$(docker info | awk -F: '/Architecture/{print $2}' | tr -d ' ')"
o="-c 'CMD [\"bash\",\"-il\"]'"
t="${a}"
if [[ ${a} =~ ^aarch64 ]] ; then
	t="arm64v8"
elif [[ ${a} =~ ^arm ]] ; then
	t="arm32v6"
	o+=' '
	o+="-c 'ENTRYPOINT [\"linux32\"]'"
elif [[ ${a} =~ x86_64 ]] ; then
	t="amd64"
elif [[ ${a} =~ ^i.86 ]] ; then
	t="i386"
	o+=' '
	o+="-c 'ENTRYPOINT [\"linux32\"]'"
fi

docker stop "${b}" || true
docker kill "${b}" || true
docker rm "${b}" || true

docker image rm "${b}" || true

docker build --force-rm --no-cache --pull --tag "${b}" "${u}"

docker run --name "${b}" "${b}" bash -c 'uname -m ; bash --version ; set | egrep "(TYPE|BASH)"'

docker export "${b}" \
| eval docker import "${o}" - "${v}/${c}:${t}"

docker rm "${b}"
