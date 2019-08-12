#
# build statictoolchain for crosware in crosware
#   build: docker build --pull --tag ryanwoodsmall/crosware-statictoolchain .
#   run: docker run --rm -it -v /tmp/$(date '+%Y%m%d%H%M')-statictoolchain-$(uname -m):/tmp ryanwoodsmall/crosware-statictoolchain
# resulting compilers and build output located in /tmp/
#
#
FROM ryanwoodsmall/crosware:latest
CMD ["bash","/usr/local/crosware/scripts/build-statictoolchain.sh"]
