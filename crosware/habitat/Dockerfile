FROM ryanwoodsmall/crosware:amd64

RUN source /etc/profile \
    && crosware install habitat \
    && source /etc/profile \
    && env TERM=dumb hab pkg install core/hab \
    && env TERM=dumb hab pkg install core/hab-sup \
    && busybox addgroup -S hab \
    && busybox adduser -H -D -S -h /hab -G hab -s /bin/bash hab
