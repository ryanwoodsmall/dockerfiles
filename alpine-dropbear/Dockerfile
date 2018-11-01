FROM alpine:latest

EXPOSE 22

RUN apk update \
    && apk upgrade \
    && apk add dropbear dropbear-convert dropbear-dbclient dropbear-scp dropbear-ssh \
    && mkdir -p /etc/dropbear

CMD ["dropbear","-R","-F","-E","-B"]
