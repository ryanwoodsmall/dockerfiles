FROM ryanwoodsmall/crosware:minimal
ENV jgitsh=jgitsh7
ENV CW_GIT_CMD=jgit
ENV cwtop=/usr/local/crosware
RUN cd ${cwtop} \
    && . ${cwtop}/etc/profile \
    && `${cwtop}/scripts/tcrs zulu17musl ${jgitsh}` \
    && test -e /usr/local/bin || mkdir -p /usr/local/bin \
    && ln -sf ${cwtop}/scripts/jgit /usr/local/bin/jgit \
    && rm -rf ${cwtop}/.git \
    && bash ${cwtop}/scripts/reconstitute-git.sh
