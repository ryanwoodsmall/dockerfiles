FROM ryanwoodsmall/crosware:latest AS NEBULABUILD

RUN source /usr/local/crosware/etc/profile \
    && bash /usr/local/crosware/scripts/update-crosware-from-zip.sh \
    && crosware install nebula \
    && mkdir /stow \
    && cp -a /usr/local/crosware/software/nebula/current/bin/nebula-cert /stow/nebula-cert \
    && cp -a /usr/local/crosware/software/nebula/current/bin/nebula /stow/nebula

FROM scratch
COPY --from=NEBULABUILD /stow/nebula-cert /nebula-cert
COPY --from=NEBULABUILD /stow/nebula /nebula
COPY --from=NEBULABUILD /etc/group /etc/
COPY --from=NEBULABUILD /etc/passwd /etc/
COPY --from=NEBULABUILD /etc/shadow /etc/
ENTRYPOINT ["/nebula"]

# vim: set ft=sh:
