FROM alpine as ALPINE

RUN apk update \
    && apk upgrade \
    && apk add tini-static

FROM gcr.io/distroless/python3

COPY --from=ALPINE /sbin/tini-static /tini

ENTRYPOINT ["/tini","-gwvv","--"]

CMD ["python3"]
