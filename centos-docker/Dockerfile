FROM centos:7

RUN yum clean all \
    && yum -y update \
    && yum -y install epel-release \
    && yum -y install curl vim-enhanced file which less wget openssh-clients openssh-server screen jq net-tools \
    && curl -kL https://get.docker.com/ | env CHANNEL=stable bash \
    && yum clean all \
    && rm -rf /var/cache/yum/
