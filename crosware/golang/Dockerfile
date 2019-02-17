#
# build static golang for crosware in crosware
#   build: docker build --pull --tag ryanwoodsmall/crosware-golang .
#   run: docker run --rm -it -v ${PWD}/tmp:/usr/local/crosware/tmp/ ryanwoodsmall/crosware-golang
# resulting archives and build output located in /usr/local/crosware/tmp/
#
FROM ryanwoodsmall/crosware:latest
ADD https://raw.githubusercontent.com/ryanwoodsmall/go-misc/master/bootstrap-static/build.sh /build.sh
RUN touch /build-golang.sh \
    && echo '#!/bin/sh' >> /build-golang.sh \
    && echo '. /etc/profile' >> /build-golang.sh \
    && echo 'bash /build.sh' >> /build-golang.sh \
    && chmod 755 /build-golang.sh
CMD ["/build-golang.sh"]
