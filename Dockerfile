FROM jenkinsci/jenkins:2.89
# hierarchy:
# https://hub.docker.com/r/jenkins/jenkins/
# jenkinsci/jenkins -> https://github.com/jenkinsci/docker/blob/master/Dockerfile
# openjdk:jdk-8 -> https://github.com/docker-library/openjdk/blob/a893fe3cd82757e7bccc0948c88bfee09bd916c3/8-jdk/Dockerfile
# buildpack-deps:stretch-scm -> https://github.com/docker-library/buildpack-deps/blob/master/stretch/scm/Dockerfile
# buildpack-deps:stretch-curl -> https://github.com/docker-library/buildpack-deps/blob/master/stretch/curl/Dockerfile
# debian:stretch

# Install lastest Docker for Debian
# https://docs.docker.com/engine/installation/linux/docker-ce/debian/
USER root
# The docker goup id might be different on the
ARG docker_group=docker_host
ARG docker_gid=992
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
         apt-transport-https \
         ca-certificates \
         curl \
         gnupg2 \
         software-properties-common && \
    (curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg |  apt-key add -) && \
    add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
       $(lsb_release -cs) \
       stable" && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker-ce && \
    groupadd -g ${docker_gid} ${docker_group} && \
    usermod -a -G ${docker_group} jenkins && \
    rm -rf /var/lib/apt/lists/*

# Finish configuring Jenkins
USER jenkins
# There should be 0 exeutors on the main Jenkins CI server
COPY executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy
# Generate a list of plugins from an existing server
# JENKINS_HOST=username:password@myhost.com:port
# curl -sSL "https://$JENKINS_HOST/pluginManager/api/xml?depth=1&xpath=/*/*/shortName|/*/*/version&wrapper=plugins" \
# | perl -pe 's/.*?<shortName>([\w-]+).*?<version>([^<]+)()(<\/\w+>)+/\1 \2\n/g'|sed 's/ /:/' > plugins.txt
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
# Set to indicate Jenkins is already configured, don't prompt to install plugins
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state
