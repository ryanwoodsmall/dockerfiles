#
# builds a fully-featured, mbedtls-enabled uacme instance by default
#
# to build a gnutls variant:
#   docker build --no-cache --build-arg uacmevariant=gnutls --tag uacmegnutls .
#
# XXX - dedicated user/group
#

FROM ryanwoodsmall/crosware:latest

ARG uacmevariant
ENV uacmevariant=${uacmevariant:-mbedtls}

RUN source /usr/local/crosware/etc/profile \
    && bash /usr/local/crosware/scripts/update-crosware-from-zip.sh \
    && crosware install uacme${uacmevariant} \
    && ln -sf /usr/local/crosware/software/uacme${uacmevariant}/current/bin/uacme /usr/bin/uacme

RUN mkdir -p /data/uacme

WORKDIR "/data/uacme"

ENTRYPOINT ["/usr/bin/uacme"]

# vim: set ft=sh:
