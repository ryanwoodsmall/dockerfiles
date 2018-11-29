#
# run with something like
#  mkdir -p rpmbuild
#  docker run -it --rm -v ${PWD}/rpmbuild:/root/rpmbuild blah/blah:blah
#

FROM centos:latest

COPY files/build-rpms.sh /

RUN chmod 755 /build-rpms.sh

CMD ["/build-rpms.sh"]
