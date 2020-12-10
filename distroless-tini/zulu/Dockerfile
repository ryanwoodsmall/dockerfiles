FROM alpine as ALPINE

RUN apk update \
    && apk upgrade \
    && apk add curl tini-static \
    && rm -rf /zulu \
    && mkdir -p /zulu \
    && cd /zulu/ \
    && curl -kLO https://cdn.azul.com/zulu/bin/zulu11.33.15-ca-jdk11.0.4-linux_x64.tar.gz \
    && tar -zxf zulu*.tar.gz \
    && rm -f zulu*.tar.gz \
    && mv zulu*/* . \
    && rmdir zulu*/ \
    && apk add busybox-static

FROM gcr.io/distroless/java:11

ENV JAVA_HOME=/zulu

COPY --from=ALPINE /sbin/tini-static /sbin/tini
COPY --from=ALPINE /zulu /zulu
COPY --from=ALPINE /bin/busybox.static /bin/busybox
COPY --from=ALPINE /bin/busybox.static /bin/sh

RUN /bin/busybox --list | while read -r a ; do test -e /bin/${a} || busybox ln -s busybox /bin/${a} ; done \
    && rm -f /bin/sh \
    && ln -s /bin/ash /bin/sh \
    && ln -sf /zulu/bin/* /usr/bin/

ENTRYPOINT ["/sbin/tini","-gwvv","--"]

CMD ["jshell"]

# vim: set ft=sh:
