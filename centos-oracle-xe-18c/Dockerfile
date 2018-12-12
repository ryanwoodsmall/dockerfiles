FROM centos:7

EXPOSE 1521
EXPOSE 5500

ENV ORACLE_DOCKER_INSTALL=true

# XXX - should probably be an argument
ENV password=oracle

COPY files/rpm/oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm /orainst/
COPY files/rpm/oracle-database-xe-18c-1.0-1.x86_64.rpm /orainst/
COPY files/scripts/startup.sh /
COPY files/scripts/configure.sh /

RUN chmod 755 /startup.sh /configure.sh \
    && yum clean all \
    && yum -y update \
    && yum -y install /orainst/oracle-database*.rpm \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && rm -f /orainst/*.rpm

# XXX - buh, needs to be privileged
#    && su - oracle -c true || { echo 'run build as (real) root, i.e., "sudo docker build ..."' ; exit 1 ; } \
#    && { echo ${password} ; echo ${password} ; } | /etc/init.d/oracle-xe-18c configure 2>&1 | tee /oracle-xe-18c_configure.out \
#    && /etc/init.d/oracle-xe-18c stop \
#    && echo 'oracle xe 18c installed and configured'

# XXX - need to allow :5500 to listen/respond on 0.0.0.0
# XXX - or put a proxy in front of it

# XXX - tail the listener log?
# XXX - https://stackoverflow.com/questions/32353055/how-to-start-a-stopped-docker-container-with-a-different-command
# XXX - trap SIGTERM, via https://stackoverflow.com/questions/41451159/how-to-execute-a-script-when-i-terminate-a-docker-container
#CMD /startup.sh
