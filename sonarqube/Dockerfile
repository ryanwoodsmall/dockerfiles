#
# braindead firewall rules can break gpg key pulls
#   via https://github.com/SonarSource/docker-sonarqube/blob/master/7.1/Dockerfile
#

FROM sonarqube:latest

ENV SONAR_VERSION 7.3

RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y rsync \
    && cd /opt/ \
    && rm -rf sonarcube \
    && curl -kLO https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip \
    && curl -kLO https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip.asc \
    && gpg --batch --verify sonarqube-${SONAR_VERSION}.zip.asc sonarqube-${SONAR_VERSION}.zip \
    && unzip -q sonarqube-${SONAR_VERSION}.zip \
    && rsync -aqHS --delete sonarqube-${SONAR_VERSION}/. sonarqube/. \
    && rm -rf sonarqube-${SONAR_VERSION} \
    && rm -f *.zip *.zip.asc \
    && rm -rf ${SONARQUBE_HOME}/bin/* \
    && cd ${SONARQUBE_HOME}/bin \
    && curl -kLO https://raw.githubusercontent.com/SonarSource/docker-sonarqube/master/7.1/run.sh \
    && chmod 755 run.sh \
    && chown -R sonarqube:sonarqube ${SONARQUBE_HOME}
