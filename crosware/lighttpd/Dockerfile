FROM ryanwoodsmall/crosware:latest

RUN source /usr/local/crosware/etc/profile \
    && bash /usr/local/crosware/scripts/update-crosware-from-zip.sh \
    && crosware install lighttpd

RUN mkdir -p /data/lighttpd/conf \
    && mkdir -p /data/lighttpd/content

WORKDIR "/data/lighttpd"

ENTRYPOINT ["/usr/local/crosware/software/lighttpd/current/sbin/lighttpd"]

# vim: set ft=sh:
