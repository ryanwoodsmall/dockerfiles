FROM i386/centos:6

RUN echo i386 > /etc/yum/vars/basearch \
    && yum clean all \
    && yum -y update \
    && yum -y install util-linux-ng \
    && yum clean all \
    && rm -rf /var/cache/yum/*

CMD ["/usr/bin/setarch","i686","/bin/bash"]
