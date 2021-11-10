FROM jenkins/jenkins:2.235.1-lts-centos7
LABEL maintainer="KAINOS"

# Install system packages (ansible and JJB)
USER root
RUN yum clean all

RUN yum -y install build-essential \
            python-pyrex \
            idle-python2.7 \
            python-dev \
            python-setuptools \
            openssl \
            python3-pip \
            wget \
            ansible

RUN pip-3 install jenkins-job-builder

ENV PATH ~/.local/bin/:$PATH

# Install Maven
RUN wget https://archive.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz -P /tmp/
RUN tar xf /tmp/apache-maven-3.6.3-bin.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-3.6.3 /opt/maven

# Setup maven environment variables
RUN echo "export JAVA_HOME=/usr/lib/jvm/jre-openjdk \
          export M2_HOME=/opt/maven \
          export MAVEN_HOME=/opt/maven \
          export PATH=/opt/maven/bin:${PATH}" > /etc/profile.d/maven.sh

# Make the maven script executable
RUN chmod +x /etc/profile.d/maven.sh
RUN source /etc/profile.d/maven.sh

# Remove maven installer file
RUN rm /tmp/apache-maven-3.6.3-bin.tar.gz

# Install Docker engine
RUN yum update -y && \
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
    yum list docker-ce && \
    yum update && \
    yum install docker-ce -y && \
    yum clean all
RUN usermod -a -G docker jenkins

ENV PATH ~/.local/bin/:$PATH

# Jenkins Configuration
USER jenkins
COPY /jenkins_jobs.ini /etc/jenkins_jobs/jenkins_jobs.ini

# COPY and install the plugins
COPY plugins.txt /usr/share/jenkins/ref/
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

#Set user and password
ENV JENKINS_USER jenkins
ENV JENKINS_PASS jenkins

# Skip initial setup
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Setup Jenkins admin user
COPY executors.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY default-user.groovy /usr/share/jenkins/ref/init.groovy.d/
