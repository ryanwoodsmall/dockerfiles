FROM ryanwoodsmall/crosware:zulu

# http listener
EXPOSE 9631/tcp
# control listener - localhost only by default
#EXPOSE 9632/tcp
# gossip listeners
EXPOSE 9638/tcp
EXPOSE 9638/udp

RUN source /etc/profile \
    && crosware update \
    && crosware upgrade-all \
    && rmdir /usr/sbin \
    && ln -s /usr/bin /usr/sbin \
    && crosware install habitat tini \
    && source /etc/profile \
    && install -m 0755 `which tini` /usr/sbin/tini \
    && env TERM=dumb hab pkg install core/hab \
    && env TERM=dumb hab pkg install core/hab-sup \
    && env TERM=dumb hab pkg install core/hab-launcher \
    && busybox addgroup -S hab \
    && busybox adduser -H -D -S -h /hab -G hab -s /bin/bash hab

RUN >/sup.sh \
    && chmod 755 /sup.sh \
    && echo '#!/usr/bin/env bash' >> /sup.sh \
    && echo 'source /etc/profile' >> /sup.sh \
    && echo 'echo "logging hab-sup stdout/stderr to ${cwtop}/tmp/hab-sup.log" 1>&2' >> /sup.sh \
    && echo 'while true ; do' >> /sup.sh \
    && echo '  hab sup run >>"${cwtop}/tmp/hab-sup.log" 2>&1' >> /sup.sh \
    && echo '  sleep 3' >> /sup.sh \
    && echo 'done' >> /sup.sh

RUN >/init.sh \
    && chmod 755 /init.sh \
    && echo '#!/usr/bin/env bash' >> /init.sh \
    && echo 'source /etc/profile' >> /init.sh \
    && echo '/sup.sh &' >> /init.sh \
    && echo 'test ${#} -eq 0 && exec bash -il || exec "${@}"' >> /init.sh

ENTRYPOINT ["/usr/sbin/tini","-gwvv","--","/init.sh"]

CMD ["/bin/bash","-il"]
