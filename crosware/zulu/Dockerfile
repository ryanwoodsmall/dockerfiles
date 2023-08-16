#
# musl (alpine) zulu on crosware x86_64
#
# XXX - zulu 8/11/17 musl now have aarch64 builds
#

FROM debian:bullseye AS checkout

ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /usr/local/ \
    && cd /usr/local/ \
    && apt update \
    && apt install -y git \
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

# only 64-bit intel for now
RUN uname -m | grep -q '^x86_64$'

# fresh git checkout
COPY --from=checkout /tmp/crosware.tar /tmp/crosware.tar
RUN rm -rf ${cwtop}/.git ${cwtop}/recipes ${cwtop}/scripts \
    && tar -C / -xvf /tmp/crosware.tar \
    && rm -f /tmp/crosware.tar

# install jgitsh and make sure it's default
RUN source /etc/profile \
    && for i in jgitsh ccache busybox toybox sed gawk m4 flex pkgconfig byacc reflex shellish htermutils diffutils tini libxml2 xmlstarlet ; do crosware check-installed $i || crosware install $i ; done \
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
    && crosware install zulu11musl \
    && pf="${cwtop}/etc/profile.d/zz_zulu11musl.sh" \
    && echo "test -e ${pf} && . ${pf} || true" > ${cwtop}/etc/local.d/zulumusl.sh \
    && source /etc/profile \
    && crosware update \
    && crosware upgrade-all || true \
    && for i in vimnetbsdcurses tmux ; do crosware check-installed $i || crosware install $i ; done \
    && ccache -C || true \
    && mkdir -p /usr/local/bin \
    && ln -sf ${cwtop}/scripts/jgit /usr/local/bin/jgit \
    && find ${cwdl}/*/ ${ult}/ -type f | xargs rm -f \
    && rmdir ${cwdl}/*/

RUN source /etc/profile \
    && cd ${cwtop}/tmp/ \
    && jgit clone https://github.com/ryanwoodsmall/dotfiles.git \
    && jgit clone https://github.com/ryanwoodsmall/vimrcs.git \
    && cd ${cwtop}/tmp/dotfiles/ \
    && for f in dot_* ; do install -m 644 ${f} ${HOME}/${f//dot_/.} ; done \
    && cd ${cwtop}/tmp/vimrcs/ \
    && bash install-on-chrome-os.sh

RUN source /etc/profile \
    && javac -version 2>&1 | grep -i ^javac

# vim: set ft=sh:
