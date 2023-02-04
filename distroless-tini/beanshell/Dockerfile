FROM alpine AS alpine

RUN apk update \
    && apk add tini-static

FROM gcr.io/distroless/java17-debian11

COPY --from=alpine /sbin/tini-static /tini

ADD https://github.com/beanshell/beanshell/releases/download/2.1.1/bsh-2.1.1.jar /bsh.jar

ENTRYPOINT ["/tini","-gwvv","--","java","-cp"]

CMD ["/bsh.jar","bsh.Interpreter"]

# vim: set ft=sh:
