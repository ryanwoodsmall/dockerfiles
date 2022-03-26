#
# builds a fully-featured, mbedtls-enabled lighttpd instance by default
#
# to build a minimal (i.e., no tls) variant:
#   docker build --no-cache --build-arg lighttpdvariant=minimal --tag lighttpdminimal .
#
# XXX - dedicated user/group
#

FROM ryanwoodsmall/crosware:latest

ARG lighttpdvariant
ENV lighttpdvariant=${lighttpdvariant:-}

RUN source /usr/local/crosware/etc/profile \
    && bash /usr/local/crosware/scripts/update-crosware-from-zip.sh \
    && crosware install lighttpd${lighttpdvariant} \
    && ln -sf /usr/local/crosware/software/lighttpd${lighttpdvariant}/current/sbin/lighttpd /usr/sbin/lighttpd \
    && crosware install cronolog \
    && ln -sf /usr/local/crosware/software/cronolog/current/sbin/cronolog /usr/sbin/cronolog

RUN mkdir -p /data/lighttpd/conf \
    && mkdir -p /data/lighttpd/content \
    && mkdir -p /data/lighttpd/logs

WORKDIR "/data/lighttpd"

ENTRYPOINT ["/usr/sbin/lighttpd"]

# vim: set ft=sh:
