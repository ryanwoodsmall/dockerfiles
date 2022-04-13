FROM ryanwoodsmall/crosware:latest AS builder

RUN . /etc/profile \
  && crosware update \
  && crosware reinstall thttpd \
  && adduser -h /home/static -s /sbin/nologin -u 1000 -g static -D -H static \
  && mkdir /home/static \
  && chown static:static /home/static \
  && grep ^static: /etc/passwd > /tmp/passwd.new \
  && grep ^static: /etc/group > /tmp/group.new

FROM scratch

COPY --from=builder /usr/local/crosware/software/thttpd/current/sbin/thttpd /thttpd
COPY --from=builder /tmp/passwd.new /etc/passwd
COPY --from=builder /tmp/group.new /etc/group
COPY --from=builder /home/static /home/static

USER static

WORKDIR "/home/static"

ENTRYPOINT ["/thttpd"]

CMD ["-D", "-h", "0.0.0.0", "-p", "3000", "-d", "/home/static", "-u", "static", "-l", "-", "-M", "60"]
