#FROM node:8.15.0
FROM ubuntu:18.04

LABEL vendor="SebastianLeks" \
      is-production="false"

# UPDATES & basic tools
RUN apt-get update                               && \
    DEBIAN_FRONTEND=noninteractive              \
    apt-get install -yq --no-install-recommends \
    apt-utils                                   \
    python3                                     \
    python3-setuptools                          \
    build-essential libssl-dev libffi-dev       \
    python3-dev                                 \
    libev4 libev-dev                            \
    less                                        \
    man                                         \
    wget                                        \
    nano                                        \
    unzip                                       \
    jq                                          \
    httpie                                      \
    htop                                        \
    groff                                       \
    python-pip                                  \
    tzdata




# Set timezone
RUN echo "America/Chicago" > /etc/timezone \
 && dpkg-reconfigure -f noninteractive tzdata

# NVM and Node
ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 8.15.0

RUN mkdir $NVM_DIR && \
    wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash && \
    . $NVM_DIR/nvm.sh               && \
    nvm install $NODE_VERSION       && \
    nvm alias default $NODE_VERSION && \
    nvm use default

# INSTALL nodemon
#RUN npm install --global nodemon

# AWS cli
RUN DEBIAN_FRONTEND=noninteractive              \
    apt-get install -yq --no-install-recommends \
    python-dev libpython-dev                && \
    pip install --upgrade setuptools        && \
    pip install wheel                       && \
    pip install awscli --upgrade --user



## CLEANUP
RUN apt-get clean                   && \
    rm -rf /var/lib/apt/lists/*


RUN . $NVM_DIR/nvm.sh               && \
    npm config set unsafe-perm=true && \
    npm install -g serverless


# AWS Default Profile
# https://github.com/apex/apex/blob/master/docs/aws-credentials.md
RUN printf "\n export AWS_PROFILE=DEV \n" >> /root/.bashrc

# SHELL customizations
# Ref: https://gist.github.com/SebastianLeks/b2f6d0c09f7d4b1c29ae45d5aab46b99
RUN apt-get update                               && \
    DEBIAN_FRONTEND=noninteractive              \
    apt-get install -yq --no-install-recommends \
    git-core                                    \
    zsh                                         \
    curl                                        \
    fonts-powerline

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true && \
    git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

RUN mkdir temp  && \
    cd temp     && \
    git clone https://github.com/gabrielelana/awesome-terminal-fonts && \
    mkdir ~/.fonts && \
    cp ./awesome-terminal-fonts/build/* ~/.fonts/ && \
    fc-cache -fv ~/.fonts && \
    chsh -s $(which zsh)




EXPOSE 8080 5858 4040 8443 9001 3000

CMD ["zsh"]

