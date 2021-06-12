#
# musl (alpine) zulu on crosware x86_64
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

# fresh git checkout
COPY --from=checkout /tmp/crosware.tar /tmp/crosware.tar
RUN rm -rf ${cwtop}/.git ${cwtop}/recipes ${cwtop}/scripts \
    && tar -C / -xvf /tmp/crosware.tar \
    && rm -f /tmp/crosware.tar

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

# install zulu, update, etc.
RUN source /etc/profile \
    && crosware install zulu8musl \
    && pf="${cwtop}/etc/profile.d/zz_zulu8musl.sh" \
    && echo "test -e ${pf} && . ${pf} || true" > ${cwtop}/etc/local.d/zulumusl.sh \
    && source /etc/profile \
    && crosware update \
    && crosware upgrade-all || true \
    && ccache -C || true \
    && find ${cwdl}/*/ ${ult}/ -type f | xargs rm -f \
    && rmdir ${cwdl}/*/

# vim: set ft=sh:
