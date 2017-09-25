FROM node:8.5.0

LABEL vendor="SebastianLeks" \
      is-production="false"

# Set timezone
RUN echo "America/Chicago" > /etc/timezone \
 && dpkg-reconfigure -f noninteractive tzdata


# update node container
RUN apt-get update

# UPDATES & installs
RUN DEBIAN_FRONTEND=noninteractive               \
    apt-get install -yq --no-install-recommends  \
             apt-utils
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install -yq            \
             python                                 \
             python-setuptools                      \
             build-essential libssl-dev libffi-dev  \
             python-dev                             \
             less                                   \
             man                                    \
             wget                                   \
             nano                                   \
             unzip                                  \
             jq                                     \
             groff                               && \
             apt-get clean                       && \
             rm -rf /var/lib/apt/lists/*

# INSTALL pip
RUN easy_install pip

# INSTALL nodemon
RUN npm install --global nodemon

# CONFIGURE AWS CLI needs the PYTHONIOENCODING environment varialbe to handle UTF-8 correctly:
ENV PYTHONIOENCODING=UTF-8

# INSTALL AWS CLI
RUN pip install --upgrade --user awscli                                      && \
    echo "complete -C '/root/.local/bin/aws_completer' aws" >> /root/.bashrc && \
    echo "export PATH=/root/.local/bin:$PATH" >> /root/.bashrc

# INSTALL SAWS: A Supercharged AWS CLI https://github.com/donnemartin/saws
RUN pip install saws

# INSTALL AWLESS: https://github.com/wallix/awless
RUN curl https://raw.githubusercontent.com/wallix/awless/master/getawless.sh | bash && \
    mv awless /usr/local/bin/ && \
    echo 'source <(awless completion bash)' >> ~/.bashrc

# INSTALL aws limitchecker https://awslimitchecker.readthedocs.io
RUN pip install awslimitchecker                       && \
# END of module installation - display versions
    echo "--- Finished INSTALLATION and UPDATES ---"  && \
    echo "python (req. 2.7.x): " $(python --version)  && \
    echo "pip (req. latest): " $(pip -V)              && \
    echo "node (req. 6.9+): " $(node --version)       && \
    echo "npm: " $(npm --version)                     && \
    echo "SAWS: " $(saws --version)                   && \
    echo "AWS CLI: " $(aws --version)

WORKDIR /aws-wrkspace

# AWS configuration mapping will be stored in local directory ./aws-wrkspace/.aws
RUN ln -s /aws-wrkspace/.aws /root/.aws
# && export AWS_DEFAULT_PROFILE=xyz-profile-name

# MIGRATIONS
# Install Postgres Client 9.5
RUN apt-get purge postgr* \
 && apt-get autoremove \
 && wget -q -O- https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main 9.5" >> /etc/apt/sources.list.d/postgresql.list \
 && apt-get update \
 && apt-get install -y postgresql-client-9.5


RUN echo "echo \"run aws configure command to configure keys\"" >> /root/.bashrc


# use changes to package.json to force Docker not to use the cache
# when we change our application's nodejs dependencies:
#ADD package.json /tmp/package.json
#RUN cd /tmp && npm install
RUN mkdir -p /usr/app/
# use app src directory
#WORKDIR /usr/src/app

#RUN cp -a /tmp/node_modules /usr/app/

# Install nodemon to support development file watch
RUN npm install --global nodemon

# create non-priviledged user to run the app
#RUN useradd --user-group --create-home --shell /bin/false app-user
#ENV HOME=/home/app-user
#RUN chown app-user:app-user /usr/app
#USER app-user


# INSTALL ngrok KEY
ADD https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip /ngrok.zip
RUN set -x \
 && unzip -o /ngrok.zip -d /bin \
 && rm -f /ngrok.zip \
 && mkdir /root/.ngrok2 \
 && echo 'web_addr: 0.0.0.0:4040' > /root/.ngrok2/ngrok.yml
# INSTALL ngrok KEY
#RUN ngrok authtoken abcTOKEN...


# Bundle app source
#COPY . /usr/src/app

EXPOSE 8080 5858 4040 8443


#CMD [ "npm", "start" ]
CMD "/bin/bash"

