FROM alpine AS alpine

RUN apk update \
    && apk add tini-static

FROM gcr.io/distroless/java:8

COPY --from=alpine /sbin/tini-static /tini

ADD https://github.com/beanshell/beanshell/releases/download/2.0b6/bsh-2.0b6.jar /bsh.jar

ENTRYPOINT ["/tini","-gwvv","--","java","-cp"]

CMD ["/bsh.jar","bsh.Interpreter"]

# vim: set ft=sh:
