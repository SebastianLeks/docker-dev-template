FROM node:8.10.0

LABEL vendor="SebastianLeks" \
      is-production="false"


# UPDATES & basic tools
RUN apt-get update                              && \
    DEBIAN_FRONTEND=noninteractive                  \
    apt-get install -yq --no-install-recommends     \
             apt-utils                          && \
    DEBIAN_FRONTEND=noninteractive                  \
    apt-get install -yq                             \
             python                                 \
             python-setuptools                      \
             build-essential libssl-dev libffi-dev  \
             python-dev                             \
             libev4 libev-dev                       \
             less                                   \
             man                                    \
             wget                                   \
             nano                                   \
             unzip                                  \
             jq                                     \
             httpie                                 \
             htop                                   \
             groff


# Set timezone
RUN echo "America/Chicago" > /etc/timezone \
 && dpkg-reconfigure -f noninteractive tzdata

# pip
RUN easy_install pip

# INSTALL nodemon
RUN npm install --global nodemon

# AWS
# CONFIGURE AWS CLI needs the PYTHONIOENCODING environment varialbe to handle UTF-8 correctly:
ENV PYTHONIOENCODING=UTF-8

# AWS CLI
RUN pip install --upgrade --user awscli                                      && \
    echo "complete -C '/root/.local/bin/aws_completer' aws" >> /root/.bashrc && \
    echo "export PATH=/root/.local/bin:$PATH" >> /root/.bashrc

# SAWS: A Supercharged AWS CLI https://github.com/donnemartin/saws
RUN pip install saws

# AWLESS: https://github.com/wallix/awless
RUN curl https://raw.githubusercontent.com/wallix/awless/master/getawless.sh | bash && \
    mv awless /usr/local/bin/ && \
    echo 'source <(awless completion bash)' >> ~/.bashrc

# aws limitchecker https://awslimitchecker.readthedocs.io
RUN pip install awslimitchecker
# END of module installation - versions
RUN echo "--- Finished INSTALLATION and UPDATES ---"  && \
    echo "python (req. 2.7.x): " $(python --version)  && \
    echo "pip (req. latest): " $(pip -V)              && \
    echo "node (req. 6.9+): " $(node --version)       && \
    echo "npm: " $(npm --version)                     && \
    echo "AWS CLI: " $(aws --version)


# AWS configuration mapping will be stored in local directory ./aws-wrkspace/.aws
RUN ln -s /aws-wrkspace/.aws /root/.aws
# aws cli execution notes
# export AWS_DEFAULT_PROFILE=xyz-profile-name
RUN echo "echo \"\nRun aws configure command to update keys\n\"" >> /root/.bashrc && \
    echo "echo \"\nSet default aws profile thru: export AWS_DEFAULT_PROFILE=xyz-profile-name\n\"" >> /root/.bashrc

## CLEANUP
RUN apt-get clean                                    && \
    rm -rf /var/lib/apt/lists/*

# SERVERLESS framework
RUN npm install -g serverless''

# Postgres Client (9.5)
RUN apt-get purge postgr* \
 && apt-get autoremove \
 && wget -q -O- https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main 9.5" >> /etc/apt/sources.list.d/postgresql.list \
 && apt-get update \
 && apt-get install -y postgresql-client-9.5

# ngrok
ADD https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip /ngrok.zip
RUN set -x \
 && unzip -o /ngrok.zip -d /bin \
 && rm -f /ngrok.zip \
 && mkdir /root/.ngrok2 \
 && echo 'web_addr: 0.0.0.0:4040' > /root/.ngrok2/ngrok.yml
# configure ngrok KEY
#RUN ngrok authtoken abcTOKEN...



# Java.
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list && \
    echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections         && \
    echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections           && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886                      && \
    apt-get update                                                                                  && \
    apt-get install -yq oracle-java8-set-default
# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle


## Scala sbt
RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 && \
    apt-get install apt-transport-https && \
    apt-get update && \
    apt-get install sbt && \
    sbt about

RUN wget http://www.scala-lang.org/files/archive/scala-2.12.4.deb

## Scala ammonite REPL http://ammonite.io/
RUN curl -L -o /usr/local/bin/amm https://git.io/vdNv2 && chmod +x /usr/local/bin/amm
# Launch with 'amm'

## Scala (2.12)
ENV SCALA_VERSION 2.12.4
ENV SCALA_TARBALL http://www.scala-lang.org/files/archive/scala-$SCALA_VERSION.deb

RUN echo "===> install Scala"                           && \
    DEBIAN_FRONTEND=noninteractive                         \
        apt-get install -y --force-yes libjansi-java    && \
    curl -sSL $SCALA_TARBALL -o scala.deb               && \
    dpkg -i scala.deb                                   && \
    \
    echo "===> clean up..."                             && \
    rm -f *.deb


# AWS Default Profile
# https://github.com/apex/apex/blob/master/docs/aws-credentials.md
RUN printf "\n export AWS_PROFILE=DEV \n" >> /root/.bashrc

# Customize prompt
# https://www.howtogeek.com/307701/how-to-customize-and-colorize-your-bash-prompt/
RUN printf "PS1=\"\[\033[02;33m\]docker \u@\h: \[\033[01;34m\]\w\\n \[\033[00m\]\$ \"\n" >> /root/.bashrc && \
    printf "alias ll='ls -la --color=auto'\n" >> /root/.bashrc              && \
    printf "alias ..='cd ..'\n" >> /root/.bashrc                            && \
    printf "alias h='history'\n" >> /root/.bashrc                           && \
    printf "\n" >> /root/.bashrc                                            && \
    printf "shopt -s histappend\n" >> /root/.bashrc                         && \
    printf "PROMPT_COMMAND=\"history -n; history -a\"\n" >> /root/.bashrc   && \
    printf "unset HISTFILESIZE\n" >> /root/.bashrc                          && \
    printf "HISTSIZE=5000\n" >> /root/.bashrc

EXPOSE 8080 5858 4040 8443 9001 3000

CMD "/bin/bash"

