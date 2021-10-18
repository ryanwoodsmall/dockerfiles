#
# multi-arch jnlp jenkins agent w/openjdk+docker
#
# combines bits and pieces of:
#
# jenkins/agent:
# - https://www.github.com/jenkinsci/docker-agent
# - https://hub.docker.com/r/jenkins/agent/dockerfile
#
# jenkins/inbound-agent:
# - https://www.github.com/jenkinsci/docker-inbound-agent
# - https://hub.docker.com/r/jenkins/inbound-agent/dockerfile
#
# XXX - docker-in-docker arm 32-bit on arm 64-bt breaks (at least with arm32v6, arm32v7 seems to work?)
# - echo "deb [arch=armel] https://download.docker.com/linux/debian bullseye stable" > /etc/apt/sources.list.d/docker.list
#
# XXX - need git...
#
# XXX - just rebuild on alpine for smaller image?
#
# XXX - docker volumes break plugin w/newer jackson? error with request size too?
# - https://github.com/jenkinsci/docker-plugin/issues/821
# - https://github.com/jenkinsci/docker/issues/842
# - https://github.com/docker-java/docker-java/issues/1509
# - https://stackoverflow.com/questions/44667924/jenkins-java-plugin-field-gives-bad-message-414-reason-uri-too-long
#

FROM debian:bullseye

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG AGENT_WORKDIR=/home/${user}/agent
ARG VERSION=4.11

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk

USER root

RUN groupadd -g ${gid} ${group} \
    && useradd -c ${user} -d /home/${user} -u ${uid} -g ${gid} -m ${user}

ADD https://repo.jenkins-ci.org/releases/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar /usr/share/jenkins/agent.jar

ADD https://github.com/jenkinsci/docker-inbound-agent/raw/master/jenkins-agent /usr/local/bin/jenkins-agent

RUN chmod 755 /usr/local/bin/jenkins-agent \
    && ln -sf /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave \
    && chmod 755 /usr/share/jenkins \
    && chmod 644 /usr/share/jenkins/agent.jar \
    && ln -sf /usr/share/jenkins/agent.jar /usr/share/jenkins/slave.jar

RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y openjdk-11-jdk-headless curl wget bash procps docker.io \
    && ln -sf $(find /usr/lib/jvm/ -type d -name java-11-openjdk\* | head -1) /usr/lib/jvm/java-11-openjdk \
    && usermod -a -G docker ${user}

USER ${user}

ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir -p /home/${user}/.jenkins \
    && mkdir -p ${AGENT_WORKDIR} \
    && ln -sf ${AGENT_WORKDIR} /home/${user}/remoting

# VOLUME /home/${user}/.jenkins
# VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}

ENTRYPOINT ["jenkins-agent"]
