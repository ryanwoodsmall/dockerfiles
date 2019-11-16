#
# musl (alpine) zulu on crosware x86_64
#
#  XXX - should this be a recipe? if there are other arches, yes.
#

FROM ryanwoodsmall/crosware:amd64

# crosware
ENV cwtop   /usr/local/crosware
ENV cwdl    ${cwtop}/downloads
ENV cwsw    ${cwtop}/software
ENV cwvar   ${cwtop}/var
ENV cwprofd /etc/profile.d/crosware.sh
ENV ult     /usr/local/tmp

# zulu
ENV zulucdn    https://cdn.azul.com/zulu/bin
ENV zulutop    /usr/local/zulu
ENV zuluprofd  /etc/profile.d/zulu.sh
ENV zuludefver 8
ENV zulu8ver   8.42.0.23-ca-jdk8.0.232
ENV zulu8dir   zulu${zulu8ver}-linux_musl_x64
ENV zulu8file  ${zulu8dir}.tar.gz
ENV zulu8url   ${zulucdn}/${zulu8file}
ENV zulu8sha   2735d6e456b9194ec8843e5874ef2820e9e54d00aa4cb19c01174722d65ad7a5
ENV zulu11ver  11.35.15-ca-jdk11.0.5
ENV zulu11dir  zulu${zulu11ver}-linux_musl_x64
ENV zulu11file ${zulu11dir}.tar.gz
ENV zulu11url  ${zulucdn}/${zulu11file}
ENV zulu11sha  cef8591c619a4bec06a94d0f7e21847b04b97468a8385b6683b3c5fa2641ab57

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
    && test -e /usr/lib && rm -f /usr/lib || true \
    && test -e /usr/lib64 && rm -f /usr/lib64 || true \
    && ln -s ${cwsw}/statictoolchain/current/$(gcc -dumpmachine)/lib /usr/lib \
    && ln -s /usr/lib /usr/lib64 \
    && ln -s /usr/lib /lib \
    && ln -s /usr/lib64 /lib64

# setup profile
RUN source /etc/profile \
    && echo "export JAVA_HOME=${zulutop}/current" > ${zuluprofd} \
    && echo "export _JAVA_OPTIONS='-Djava.io.tmpdir=${cwtop}/tmp -Djava.awt.headless=true'" >> ${zuluprofd} \
    && echo 'prepend_path "${JAVA_HOME}/bin"' >> ${zuluprofd}

# setup libz.so
# XXX - need to build zlib/sortix libz shared lib???
RUN source /etc/profile \
    && mkdir -p ${zulutop}/${zulu11dir} \
    && cd ${zulutop}/${zulu11dir} \
    && crosware run-func cwfetchcheck,${zliburl},${ult}/${zlibfile},${zlibsha} \
    && tar -zxf ${ult}/${zlibfile} \
    && find ${ult}/ -type f | xargs rm -f

# install jgitsh and make sure it's default
RUN source /etc/profile \
    && crosware install jgitsh ccache busybox toybox sed gawk byacc m4 flex pkgconfig \
    && sed -i s/CW_GIT_CMD=git/CW_GIT_CMD=jgitsh/g ${cwprofd} \
    && sed -i s/CW_USE_JGIT=false/CW_USE_JGIT=true/g ${cwprofd} \
    && sed -i s/CW_USE_JAVA=false/CW_USE_JAVA=true/g ${cwprofd} \
    && echo 'export CW_EXT_JAVA=true' >> ${cwprofd} \
    && find ${cwdl}/*/ ${ult}/ -type f | xargs rm -f \
    && source /etc/profile \
    && ccache -C || true

# fetch and extract zulu
RUN source /etc/profile \
    && crosware run-func cwfetchcheck,${zulu8url},${ult}/${zulu8file},${zulu8sha} \
                         cwfetchcheck,${zulu11url},${ult}/${zulu11file},${zulu11sha} \
                         cwextract,${ult}/${zulu8file},${zulutop} \
                         cwextract,${ult}/${zulu11file},${zulutop} \
    && ln -s ${zulutop}/${zulu8dir} ${zulutop}/zulu8 \
    && ln -s ${zulutop}/${zulu11dir} ${zulutop}/zulu11 \
    && ln -s ${zulutop}/zulu${zuludefver} ${zulutop}/current \
    && chown -R ${UID}:${GROUPS} ${zulutop} \
    && find ${ult}/ -type f | xargs rm -f \
    && crosware update \
    && crosware upgrade-all || true \
    && find ${cwdl}/*/ ${ult}/ -type f | xargs rm -f \
    && ccache -C || true

# vim: set ft=sh:
