FROM ryanwoodsmall/crosware:minimal
ENV jgitsh=jgitsh7
ENV CW_GIT_CMD=jgit
ENV cwtop=/usr/local/crosware
RUN cd ${cwtop} \
    && . ${cwtop}/etc/profile \
    && `${cwtop}/scripts/tcrs zulu21musl ${jgitsh}` \
    && test -e /usr/local/bin || mkdir -p /usr/local/bin \
    && ln -sf ${cwtop}/scripts/jgit /usr/local/bin/jgit \
    && ln -sf $(which ${jgitsh}) /usr/local/bin/${jgitsh} \
    && ln -sf /usr/local/bin/${jgitsh} /usr/local/bin/jgitsh \
    && echo CW_GIT_CMD=${CW_GIT_CMD} | tee ${cwtop}/etc/local.d/zz_${jgitsh} \
    && rm -rf ${cwtop}/.git \
    && bash ${cwtop}/scripts/reconstitute-git.sh
