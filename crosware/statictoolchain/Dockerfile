#
# build statictoolchain for crosware in crosware
#   build: docker build --pull --tag ryanwoodsmall/crosware-statictoolchain .
#   run: docker run --rm -it -v /tmp/$(date '+%Y%m%d%H%M%S')-statictoolchain-$(uname -m):/tmp ryanwoodsmall/crosware-statictoolchain
# resulting compilers and build output located in /tmp/
#
# XXX - buildscript probably belongs in crosware's scripts/ directory
#
FROM ryanwoodsmall/crosware:latest
COPY files/build-statictoolchain.sh /
RUN chmod 755 /build-statictoolchain.sh
CMD ["/build-statictoolchain.sh"]
