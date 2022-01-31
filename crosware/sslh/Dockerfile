FROM ryanwoodsmall/crosware:latest as SSLHBUILDER
RUN source /usr/local/crosware/etc/profile \
    && bash /usr/local/crosware/scripts/update-crosware-from-zip.sh \
    && crosware install sslh \
    && source /usr/local/crosware/etc/profile \
    && rm -rf /stow/ \
    && mkdir -p /stow \
    && cp /usr/local/crosware/software/sslh/current/sbin/sslh-fork /stow/ \
    && cp /usr/local/crosware/software/sslh/current/sbin/sslh-select /stow/ \
    && strip --strip-all /stow/sslh*

FROM scratch
COPY --from=SSLHBUILDER /stow/sslh-fork /sslh
COPY --from=SSLHBUILDER /stow/sslh-fork /sslh-fork
COPY --from=SSLHBUILDER /stow/sslh-select /sslh-select
COPY --from=SSLHBUILDER /etc/group /etc/
COPY --from=SSLHBUILDER /etc/passwd /etc/
COPY --from=SSLHBUILDER /etc/shadow /etc/
ENTRYPOINT ["/sslh"]

# vim: set ft=sh:
