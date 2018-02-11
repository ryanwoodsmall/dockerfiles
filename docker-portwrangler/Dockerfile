#
# https://github.com/ryanwoodsmall/docker-portwrangler
#
# build:
#  docker image rm $(basename $(pwd)):latest ; docker build --force-rm --tag $(basename $(pwd)) .
#
# run:
#  docker run -it --rm -p 5000:5000 -v /var/run/docker.sock:/var/run/docker.sock $(basename $(pwd))
#

FROM alpine

ENV projdir /docker-portwrangler

EXPOSE 5000

WORKDIR /

RUN apk update \
    && apk upgrade \
    && apk add \
               git \
               python3 \
    && git clone https://github.com/ryanwoodsmall/docker-portwrangler.git

WORKDIR ${projdir}

RUN pip3 install -r requirements.txt

CMD ["env","FLASK_APP=docker-portwrangler.py","flask","run","--host=0.0.0.0","--reload"]
