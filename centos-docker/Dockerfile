FROM centos:7

RUN yum clean all \
    && yum -y update \
    && yum -y install curl vim-enhanced file which less wget openssh-clients openssh-server epel-release screen \
    && curl https://get.docker.com/ | env CHANNEL=stable bash \
    && yum -y update \
    && yum clean all \
    && rm -rf /var/cache/yum/
