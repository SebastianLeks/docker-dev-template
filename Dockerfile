FROM ubuntu:16.04

LABEL vendor="SebastianLeks" \
      is-production="false"



# UPDATES & base installs
# update base os
RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive                  \
    apt-get install -yq --no-install-recommends     \
             apt-utils

RUN DEBIAN_FRONTEND=noninteractive                  \
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
             groff                                  \
             tzdata                                 \
             curl                                   \
             htop                                   \
             git


# Set timezone
RUN echo "America/Chicago" > /etc/timezone \
 && dpkg-reconfigure -f noninteractive tzdata

# NVM
RUN curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh -o install_nvm.sh && \
    bash install_nvm.sh
ENV NVM_DIR=/root/.nvm

# Node
RUN . $HOME/.nvm/nvm.sh && \
    nvm install 6.10.3 && \
    nvm install 8.9.4 && \
    nvm use 6.10.3

# SERVERLESS
# TEMP hack to resolve npm permission errors on post install scripts
# Ref: https://github.com/npm/npm/issues/16766
# Ref: https://github.com/npm/npm/issues/17851
RUN npm config set user 0               && \
    npm config set unsafe-perm true     && \
    npm install -g serverless

# YARN

# Dev cli tools
RUN curl -L http://bit.ly/glances | /bin/bash

# INSTALL pip
RUN easy_install pip

# INSTALL nodemon
RUN . $HOME/.nvm/nvm.sh && \
    npm install --global nodemon

# AWS
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
RUN pip install awslimitchecker
# END of module installation - versions
RUN echo "--- Finished INSTALLATION and UPDATES ---"  && \
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
RUN echo "echo \"run aws configure command to configure keys\"" >> /root/.bashrc

####



## INSTALL Scala
######

## CLEANUP
RUN apt-get clean                                       && \
    rm -rf /var/lib/apt/lists/*

# Bundle app source
#COPY . /usr/src/app

EXPOSE 8080 5858 4040 8443 9001


#CMD [ "npm", "start" ]
CMD "/bin/bash"

