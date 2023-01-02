#
# builds a fully-featured, mbedtls-enabled inadyn instance by default
#
# to build a minimal (i.e., no tls) variant:
#   docker build --no-cache --build-arg inadynvariant=gnutls --tag inadyngnutls .
#
# XXX - dedicated user/group
# XXX - moved to mbedtls, this needs to be tested... ca certificate(s), etc. are kinda unknown
#

FROM ryanwoodsmall/crosware:latest

ARG inadynvariant
ENV inadynvariant=${inadynvariant:-mbedtls}

RUN source /usr/local/crosware/etc/profile \
    && bash /usr/local/crosware/scripts/update-crosware-from-zip.sh \
    && crosware install inadyn${inadynvariant} \
    && ln -sf /usr/local/crosware/software/inadyn${inadynvariant}/current/sbin/inadyn /usr/sbin/inadyn

RUN mkdir -p /data/inadyn

WORKDIR "/data/inadyn"

ENTRYPOINT ["/usr/sbin/inadyn"]

# vim: set ft=sh:
