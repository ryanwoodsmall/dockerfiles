FROM alpine as ALPINE

ADD https://github.com/beanshell/beanshell/releases/download/2.0b6/bsh-2.0b6.jar /bsh.jar

RUN apk update \
    && apk add tini-static

FROM gcr.io/distroless/java:8

COPY --from=ALPINE /sbin/tini-static /tini
COPY --from=ALPINE /bsh.jar /bsh.jar

ENTRYPOINT ["/tini","-gwvv","--"]

CMD ["java","-cp","/bsh.jar","bsh.Interpreter"]

# vim: set ft=sh:
