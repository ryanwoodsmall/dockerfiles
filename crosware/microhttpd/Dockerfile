# XXX - tini? adds 40KB or so...

FROM ryanwoodsmall/crosware:latest AS builder

RUN . /etc/profile \
  && crosware update \
  && crosware reinstall microhttpd microinetd \
  && mkdir -p /fake/bin \
  && install -m 755 /usr/local/crosware/software/microhttpd/current/bin/micro_httpd /fake/bin \
  && install -m 755 /usr/local/crosware/software/microinetd/current/bin/micro_inetd /fake/bin \
  && strip --strip-all /fake/bin/* \
  && adduser -h /home/static -s /sbin/nologin -u 1000 -g static -D -H static \
  && mkdir /home/static \
  && chown static:static /home/static \
  && grep ^static: /etc/passwd > /tmp/passwd.new \
  && grep ^static: /etc/group > /tmp/group.new \
  && rm -f /bin \
  && mv /fake/bin /

FROM scratch

COPY --from=builder /bin /bin
COPY --from=builder /tmp/passwd.new /etc/passwd
COPY --from=builder /tmp/group.new /etc/group
COPY --from=builder /home/static /home/static

USER static

EXPOSE 3000

WORKDIR "/home/static"

ENTRYPOINT ["/bin/micro_inetd"]

CMD ["3000","/bin/micro_httpd","/home/static"]
