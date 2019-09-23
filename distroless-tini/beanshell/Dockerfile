FROM alpine as ALPINE

RUN apk update \
    && apk upgrade \
    && apk add curl tini-static \
    && curl -kLo /bsh.jar https://github.com/beanshell/beanshell/releases/download/2.0b6/bsh-2.0b6.jar

FROM gcr.io/distroless/java:11

COPY --from=ALPINE /sbin/tini-static /tini
COPY --from=ALPINE /bsh.jar /bsh.jar

ENTRYPOINT ["/tini","-gwvv","--"]

CMD ["java","-cp","/bsh.jar","bsh.Interpreter"]

# vim: set ft=sh:
