#
# https://github.com/ryanwoodsmall/docker-portwrangler
#

FROM alpine

ENV projdir /docker-portwrangler

WORKDIR /

RUN apk update \
    && apk upgrade \
    && apk add docker \
               git \
               python3 \
    && git clone https://github.com/ryanwoodsmall/docker-portwrangler.git

WORKDIR ${projdir}

RUN pip3 install -r requirements.txt

CMD ["env","FLASK_APP=docker-portwrangler.py","flask","run","--host=0.0.0.0","--reload"]
