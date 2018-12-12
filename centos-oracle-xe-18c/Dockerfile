FROM centos:7

EXPOSE 1521
EXPOSE 5500

ENV password=oracle
ENV ORACLE_DOCKER_INSTALL=true

COPY files/rpm/oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm /orainst/
COPY files/rpm/oracle-database-xe-18c-1.0-1.x86_64.rpm /orainst/
COPY files/scripts/startup.sh /

RUN chmod 755 /startup.sh \
    && yum clean all \
    && yum -y update \
    && yum -y install /orainst/oracle-database*.rpm \
    && yum clean all \
    && rm -rf /var/cache/yum

# XXX - capture configure output
# && { echo ${password} ; echo ${password} ; } | /etc/init.d/oracle-xe-18c configure \
# && /etc/init.d/oracle-xe-18c stop

# XXX - tail the listener log?
#CMD /startup.sh && tail -f /dev/null
