FROM centos:7

EXPOSE 1521
EXPOSE 5500

ENV ORACLE_DOCKER_INSTALL=true

# XXX - should probably be arguments
ENV orapass=oracle
ENV orahost=oraxe18c

COPY files/rpm/oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm /orainst/
COPY files/rpm/oracle-database-xe-18c-1.0-1.x86_64.rpm /orainst/
COPY files/scripts/startup.sh /
COPY files/scripts/configure.sh /
COPY files/scripts/sethostname.sh /

RUN chmod 755 /*.sh \
    && yum clean all \
    && yum -y update \
    && yum -y install /orainst/oracle-database*.rpm \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && rm -f /orainst/*.rpm

# XXX - need to allow :5500 to listen/respond on 0.0.0.0
# XXX - or put a proxy in front of it
