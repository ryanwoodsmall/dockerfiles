#!/bin/bash

#
# scatter:
#   run this natively on arm32/arm64/amd64/i386 to build the container
#   tmux windowpanes, gnu parallel, jenkins, whatever floats your boat
#
# gather:
#   # using dbclient with keys exchanged
#   for n in $(for h in amd64 i386/2222 arm32v6/222 arm64v8 ; do dbclient -y -y ${h} docker image ls | awk '/ryanwoodsmall\/crosware/{print $1":"$2}' | sed "s#^#${h}:#g" ; done) ; do
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

docker stop "${c}" || true
docker kill "${c}" || true
docker rm "${c}" || true

docker image rm "${c}" || true

docker build --pull --tag "${c}" "${u}"

docker run --name "${c}" "${c}" uname -m

docker export ${c} \
| eval docker import "${o}" - "${v}/${c}:${t}"
