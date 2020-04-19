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
ENV zuluprofd  ${cwtop}/etc/local.d/zulu.sh
ENV zuludefver 8
ENV zulu8ver   8.46.0.19-ca-jdk8.0.252
ENV zulu8dir   zulu${zulu8ver}-linux_musl_x64
ENV zulu8file  ${zulu8dir}.tar.gz
ENV zulu8url   ${zulucdn}/${zulu8file}
ENV zulu8sha   306ec531eed55c119321dcd9ae7664a110d98955afc571d5d19ad6b69172a705
ENV zulu11ver  11.39.15-ca-jdk11.0.7
ENV zulu11dir  zulu${zulu11ver}-linux_musl_x64
ENV zulu11file ${zulu11dir}.tar.gz
ENV zulu11url  ${zulucdn}/${zulu11file}
ENV zulu11sha  0de7ac5afede2ddeda399f10c9f9df83f91c9b60481ecf304aa5785ed50f36ce

# alpine musl zlib
ENV alpver   3.11
ENV zlibver  1.2.11-r3
ENV zlibfile zlib-${zlibver}.apk
ENV zliburl  http://dl-cdn.alpinelinux.org/alpine/v${alpver}/main/x86_64/${zlibfile}
ENV zlibsha  cf6da20f78633551c1dc0233c4c6dd172437e09de05b6c12110daf19fecd7c85

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
    && echo "export _JAVA_OPTIONS='-Djava.io.tmpdir=${cwtop}/tmp -Djava.awt.headless=true -XX:-UsePerfData'" >> ${zuluprofd} \
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
    && crosware install jgitsh ccache busybox toybox sed gawk m4 flex pkgconfig byacc reflex \
    && source /etc/profile \
    && ccache -C || true \
    && find ${cwdl}/*/ ${ult}/ -type f | xargs rm -f \
    && sed -i s/CW_GIT_CMD=git/CW_GIT_CMD=jgitsh/g ${cwprofd} \
    && sed -i s/CW_USE_JGIT=false/CW_USE_JGIT=true/g ${cwprofd} \
    && sed -i s/CW_USE_JAVA=false/CW_USE_JAVA=true/g ${cwprofd} \
    && echo 'export CW_EXT_JAVA=true' >> ${cwprofd}

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
    && ccache -C || true \
    && find ${cwdl}/*/ ${ult}/ -type f | xargs rm -f

# vim: set ft=sh:
