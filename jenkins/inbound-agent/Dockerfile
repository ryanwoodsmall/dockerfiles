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
# XXX - docker volumes break plugin w/newer jackson? error with request size too?
#   - https://github.com/jenkinsci/docker-plugin/issues/821
#   - https://github.com/jenkinsci/docker/issues/842
#   - https://github.com/docker-java/docker-java/issues/1509
#   - https://stackoverflow.com/questions/44667924/jenkins-java-plugin-field-gives-bad-message-414-reason-uri-too-long
# XXX - checksum? looks like artifactory (X-Checksum-Sha1/X-Checksum-Sha256/X-Checksum-Md5) and maven central (X-Checksum-MD5/X-Checksum-SHA1) output checksums in headers
# XXX - should this just pull in /usr/share/jenkins/agent.jar from upstream jenkins/agent?
# XXX - tini?
#

FROM debian:trixie

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG AGENT_WORKDIR=/home/${user}/agent
ARG VERSION=3327.v868139a_d00e0

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk

USER root

RUN groupadd -g ${gid} ${group} \
    && useradd -c ${user} -d /home/${user} -u ${uid} -g ${gid} -m ${user}

RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y openjdk-21-jdk-headless curl wget bash procps docker.io xmlstarlet git jq \
    && ln -sf $(find /usr/lib/jvm/ -type d -name java-21-openjdk\* | head -1) /usr/lib/jvm/java-21-openjdk \
    && usermod -a -G docker ${user}

RUN echo 'installing jenkins agent bits' \
    && export REPOSITE="https://repo.jenkins-ci.org/releases/org/jenkins-ci/main/remoting" \
    && export RELEASE="$(curl -kLs ${REPOSITE}/maven-metadata.xml | xmlstarlet sel -t -v /metadata/versioning/release)" \
    && echo ${VERSION} | grep -q ^release && export VERSION="${RELEASE}" || true \
    && mkdir -p /usr/share/jenkins /usr/local/bin \
    && echo 'getting agent script' \
    && curl -kLo /usr/local/bin/jenkins-agent "https://github.com/jenkinsci/docker-inbound-agent/raw/master/jenkins-agent" \
    && chmod 755 /usr/local/bin/jenkins-agent \
    && ln -sf /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave \
    && echo 'getting remoting.jar' \
    && curl -kLo /usr/share/jenkins/remoting.jar "${REPOSITE}/${VERSION}/remoting-${VERSION}.jar" \
    && export SHA1SUM="$(curl -kILs ${REPOSITE}/${VERSION}/remoting-${VERSION}.jar | awk -F: 'BEGIN{IGNORECASE=1} /^x-checksum-sha1:/{print $NF}' | xargs echo)" \
    && sha1sum /usr/share/jenkins/remoting.jar | grep -i "^${SHA1SUM}" \
    && chmod 755 /usr/share/jenkins \
    && chmod 644 /usr/share/jenkins/remoting.jar \
    && ln -sf /usr/share/jenkins/remoting.jar /usr/share/jenkins/agent.jar \
    && ln -sf /usr/share/jenkins/remoting.jar /usr/share/jenkins/slave.jar

USER ${user}

ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir -p /home/${user}/.jenkins \
    && mkdir -p ${AGENT_WORKDIR} \
    && true
    #&& ln -sf ${AGENT_WORKDIR} /home/${user}/remoting

# VOLUME /home/${user}/.jenkins
# VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}

#ENTRYPOINT ["/usr/local/bin/jenkins-agent"]
CMD /usr/bin/java -jar /usr/share/jenkins/remoting.jar -jnlpUrl ${JENKINS_URL}computer/${NODE_NAME}/slave-agent.jnlp -secret ${JNLP_SECRET}
