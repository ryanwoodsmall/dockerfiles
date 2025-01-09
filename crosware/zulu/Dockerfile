#
# musl (alpine) zulu on crosware x86_64/aarch64
#
FROM debian:bookworm AS checkout

ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /usr/local/ \
    && cd /usr/local/ \
    && apt update \
    && apt install -y git \
    && git clone https://github.com/ryanwoodsmall/crosware.git \
    && tar -C / -cf /tmp/crosware.tar /usr/local/crosware

FROM ryanwoodsmall/crosware:latest

# crosware
ENV cwtop=/usr/local/crosware
ENV cwdl=${cwtop}/downloads
ENV cwsw=${cwtop}/software
ENV cwvar=${cwtop}/var
ENV cwprofd=/etc/profile.d/crosware.sh
ENV ult=/usr/local/tmp

# only 64-bit for now
RUN uname -m | grep -qE '^(x86_64|aarch64)$'

# fresh git checkout
COPY --from=checkout /tmp/crosware.tar /tmp/crosware.tar
RUN rm -rf ${cwtop}/.git ${cwtop}/recipes ${cwtop}/scripts \
    && tar -C / -xvf /tmp/crosware.tar \
    && rm -f /tmp/crosware.tar

# install zulu, jgitsh and make sure it's default
RUN source /etc/profile \
    && for i in jgitsh zulu17musl ; do crosware check-installed $i || crosware install $i ; done \
    && source /etc/profile \
    && ccache -C || true \
    && find ${cwdl}/*/ ${ult}/ -type f | xargs rm -f \
    && rmdir ${cwdl}/*/ \
    && sed -i s/CW_GIT_CMD=git/CW_GIT_CMD=jgitsh/g ${cwprofd} \
    && sed -i s/CW_USE_JGIT=false/CW_USE_JGIT=true/g ${cwprofd} \
    && sed -i s/CW_USE_JAVA=false/CW_USE_JAVA=true/g ${cwprofd} \
    && echo 'export CW_EXT_JAVA=true' >> ${cwprofd} \
    && mkdir -p /usr/local/bin \
    && ln -sf ${cwsw}/jgitsh7/current/bin/jgitsh7 /usr/local/bin/jgitsh \
    && ln -sf ${cwsw}/jgitsh7/current/bin/jgit /usr/local/bin/jgit

# install updates, a bunch of common stuff, dump info, etc.
RUN source /etc/profile \
    && crosware update \
    && crosware upgrade-all || true \
    && for i in ccache busybox toybox sed gawk m4 flex pkgconfig byacc reflex shellish htermutils diffutils tini libxml2 xmlstarlet baseutils vimnetbsdcurses tmux lunzip xz ; do crosware check-installed $i || crosware install $i ; done \
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
    && bash install-on-chrome-os.sh \
    && cd ${cwtop}/tmp/ \
    && echo 'listing installed' \
    && time crosware list-installed > ${cwtop}/tmp/installed.out \
    && echo 'dumping expanded recipes' \
    && time crosware list-recipe-reqs-expanded > ${cwtop}/tmp/exp.out \
    && echo 'dumping a full shell "set"' \
    && time crosware set > ${cwtop}/tmp/crosware.set.out \
    && echo 'dumping git info' \
    && jgitsh ls-files > ${cwtop}/tmp/git_ls-files.out \
    && jgitsh rev-parse HEAD > ${cwtop}/tmp/git_commit.out

RUN source /etc/profile \
    && javac -version 2>&1 | grep -i ^javac

# vim: set ft=sh:
