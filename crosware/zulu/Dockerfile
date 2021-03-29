#
# musl (alpine) zulu on crosware x86_64
#
#  XXX - should this be a recipe? if there are other arches, yes.
#  XXX - recipes: zulu8musl, zulu11musl
#

FROM centos:7 AS checkout

RUN mkdir -p /usr/local/ \
    && cd /usr/local/ \
    && yum clean all \
    && yum -y install git \
    && git clone https://github.com/ryanwoodsmall/crosware.git \
    && tar -C / -cf /tmp/crosware.tar /usr/local/crosware

FROM ryanwoodsmall/crosware:amd64

# crosware
ENV cwtop=/usr/local/crosware
ENV cwdl=${cwtop}/downloads
ENV cwsw=${cwtop}/software
ENV cwvar=${cwtop}/var
ENV cwprofd=/etc/profile.d/crosware.sh
ENV ult=/usr/local/tmp

# zulu
ENV zulutop=/usr/local/zulu

# only 64-bit intel for now
RUN uname -m | grep -q '^x86_64$'

# XXX - somewhat out of order, but keep fast stuff at top for implicit caching/singletons

# fresh git checkout
COPY --from=checkout /tmp/crosware.tar /tmp/crosware.tar
RUN rm -rf ${cwtop}/.git \
    && tar -C / -xvf /tmp/crosware.tar \
    && rm -f /tmp/crosware.tar

## setup /lib symlinks(s)
#RUN source /etc/profile \
#    && test -e /lib && rm -f /lib || true \
#    && test -e /lib64 && rm -f /lib64 || true \
#    && test -e /usr/lib && rm -f /usr/lib || true \
#    && test -e /usr/lib64 && rm -f /usr/lib64 || true \
#    && ln -s ${cwsw}/statictoolchain/current/$(gcc -dumpmachine)/lib /usr/lib \
#    && ln -s /usr/lib /usr/lib64 \
#    && ln -s /usr/lib /lib \
#    && ln -s /usr/lib64 /lib64

# install jgitsh and make sure it's default
RUN source /etc/profile \
    && crosware install jgitsh ccache busybox toybox sed gawk m4 flex pkgconfig byacc reflex \
    && source /etc/profile \
    && ccache -C || true \
    && find ${cwdl}/*/ ${ult}/ -type f | xargs rm -f \
    && rmdir ${cwdl}/*/ \
    && sed -i s/CW_GIT_CMD=git/CW_GIT_CMD=jgitsh/g ${cwprofd} \
    && sed -i s/CW_USE_JGIT=false/CW_USE_JGIT=true/g ${cwprofd} \
    && sed -i s/CW_USE_JAVA=false/CW_USE_JAVA=true/g ${cwprofd} \
    && echo 'export CW_EXT_JAVA=true' >> ${cwprofd}

## install zulu, update, etc.
#RUN source /etc/profile \
#    && bash ${cwtop}/scripts/install-musl-zulu.sh 11 \
#    && bash ${cwtop}/scripts/install-musl-zulu.sh 8 \
#    && rm -f ${zulutop}/previous \
#    && chown -R ${UID}:${GROUPS} ${zulutop} \
#    && find ${ult}/ -type f | xargs rm -f \
#    && crosware update \
#    && crosware upgrade-all || true \
#    && ccache -C || true \
#    && find ${cwdl}/*/ ${ult}/ -type f | xargs rm -f \
#    && rmdir ${cwdl}/*/

# install zulu, update, etc.
RUN source /etc/profile \
    && crosware install zulu8musl zulu11musl \
    && pf="${cwtop}/etc/profile.d/zz_zulu8musl.sh" \
    && echo "test -e ${pf} && . ${pf} || true" > ${cwtop}/etc/local.d/zulumusl.sh \
    && source /etc/profile \
    && crosware update \
    && crosware upgrade-all || true \
    && ccache -C || true \
    && find ${cwdl}/*/ ${ult}/ -type f | xargs rm -f \
    && rmdir ${cwdl}/*/

# vim: set ft=sh:
