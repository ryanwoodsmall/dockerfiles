#
# musl (alpine) zulu on crosware x86_64
#
#  XXX - should this be a recipe? if there are other arches, yes.
#

FROM ryanwoodsmall/crosware:latest

# crosware
ENV cwtop /usr/local/crosware
ENV cwsw  ${cwtop}/software
ENV cwdl  ${cwtop}/downloads
ENV cwtmp ${cwtop}/tmp

# zulu
ENV zulucdn    https://cdn.azul.com/zulu/bin
ENV zulutop    /usr/local/zulu
ENV zuluprofd  /etc/profile.d/zulu.sh
ENV zuludefver 8
ENV zulu8ver   8.40.0.25-ca-jdk8.0.222
ENV zulu8dir   zulu${zulu8ver}-linux_musl_x64
ENV zulu8file  ${zulu8dir}.tar.gz
ENV zulu8url   ${zulucdn}/${zulu8file}
ENV zulu8sha   80fcc823ca4e86cf2969937403c763375f7eff9f543fc5d2854daca0098bfa68
ENV zulu11ver  11.33.15-ca-jdk11.0.4
ENV zulu11dir  zulu${zulu11ver}-linux_musl_x64
ENV zulu11file ${zulu11dir}.tar.gz
ENV zulu11url  ${zulucdn}/${zulu11file}
ENV zulu11sha  5fbf6921641711033be7725c584af97ba2a61d678598134b5179a65e1224af66

# alpine musl zlib
ENV alpver   3.10
ENV zlibver  1.2.11-r1
ENV zlibfile zlib-${zlibver}.apk
ENV zliburl  http://dl-cdn.alpinelinux.org/alpine/v${alpver}/main/x86_64/${zlibfile}
ENV zlibsha  9295333293b4ffbe4e2af94d91841a3d69542a19da66654c8d866e6e3f53ae34

# only 64-bit intel for now
RUN uname -m | grep -q '^x86_64$'

# XXX - somewhat out of order, but keep fast stuff at top for implicit caching/singletons

# setup /lib symlinks(s)
RUN source /etc/profile \
    && test -e /lib && rm -f /lib || true \
    && test -e /lib64 && rm -f /lib64 || true \
    && ln -s ${cwsw}/statictoolchain/current/$(gcc -dumpmachine)/lib /lib \
    && ln -s /lib /lib64

# setup profile
RUN source /etc/profile \
    && echo "export JAVA_HOME=${zulutop}/current" > ${zuluprofd} \
    && echo "export _JAVA_OPTIONS='-Djava.io.tmpdir=${cwtmp} -Djava.awt.headless=true'" >> ${zuluprofd} \
    && echo 'append_path "${JAVA_HOME}/bin"' >> ${zuluprofd}

# install jgitsh and make sure it's default
RUN source /etc/profile \
    && crosware install jgitsh \
    && sed -i s/CW_GIT_CMD=git/CW_GIT_CMD=jgitsh/g /etc/profile.d/crosware.sh \
    && sed -i s/CW_USE_JGIT=false/CW_USE_JGIT=true/g /etc/profile.d/crosware.sh

# fetch zulu
RUN source /etc/profile \
    && crosware run-func cwfetchcheck,${zulu8url},${cwdl}/zulu/${zulu8file},${zulu8sha} \
                         cwfetchcheck,${zulu11url},${cwdl}/zulu/${zulu11file},${zulu11sha}

# extract zulu
RUN source /etc/profile \
    && mkdir -p ${zulutop} \
    && crosware run-func cwextract,${cwdl}/zulu/${zulu8file},${zulutop} \
                         cwextract,${cwdl}/zulu/${zulu11file},${zulutop} \
    && ln -s ${zulutop}/${zulu8dir} ${zulutop}/zulu8 \
    && ln -s ${zulutop}/${zulu11dir} ${zulutop}/zulu11 \
    && ln -s ${zulutop}/zulu${zuludefver} ${zulutop}/current

# setup libz.so
# XXX - need to build zlib/sortix libz shared lib???
RUN source /etc/profile \
    && cd ${zulutop}/zulu11 \
    && crosware run-func cwfetchcheck,${zliburl},${cwdl}/zlib/${zlibfile},${zlibsha} \
    && tar -zxf ${cwdl}/zlib/${zlibfile}

# chown everything
RUN chown -R ${USER}:${GROUPS} ${zulutop}
