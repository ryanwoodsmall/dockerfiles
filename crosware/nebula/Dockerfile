#
# run with:
#   docker run -it -d --restart always --name nebula --network host --privileged -v /opt/nebula/conf:/opt/nebula/conf:ro nebula -config /opt/nebula/conf/config.yml
#

FROM ryanwoodsmall/crosware:latest AS NEBULABUILD

RUN source /usr/local/crosware/etc/profile \
    && bash /usr/local/crosware/scripts/update-crosware-from-zip.sh \
    && crosware install nebula tini \
    && mkdir /stow \
    && cp -a /usr/local/crosware/software/nebula/current/bin/nebula-cert /stow/nebula-cert \
    && cp -a /usr/local/crosware/software/nebula/current/bin/nebula /stow/nebula \
    && cp -a /usr/local/crosware/software/tini/current/sbin/tini /stow/tini

FROM scratch
COPY --from=NEBULABUILD /stow/nebula-cert /nebula-cert
COPY --from=NEBULABUILD /stow/nebula /nebula
COPY --from=NEBULABUILD /stow/tini /tini
COPY --from=NEBULABUILD /etc/group /etc/
COPY --from=NEBULABUILD /etc/passwd /etc/
COPY --from=NEBULABUILD /etc/shadow /etc/
ENTRYPOINT ["/tini","-gwvv","--","/nebula"]

# vim: set ft=sh:
