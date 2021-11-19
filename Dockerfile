# CHANGE TO FOCAL
FROM ghcr.io/linuxserver/baseimage-ubuntu:bionic

# set version label
LABEL maintainer="Jakob Busk <jakob@webits.dk>"
LABEL name="code-server on Docker"
LABEL version="latest"

# environment settings
ENV HOME="/home"

RUN apt-get update
RUN apt install -y zsh wget curl sudo
RUN touch /home/.zshrc

RUN chown -R abc:abc /home
USER abc
RUN /bin/zsh /home/.zshrc

USER root

RUN \
  echo "**** install node repo ****" && \
  apt-get update && \
  apt-get install -y \
    gnupg && \
  curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
  echo 'deb https://deb.nodesource.com/node_14.x bionic main' \
    > /etc/apt/sources.list.d/nodesource.list && \
  curl -s https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo 'deb https://dl.yarnpkg.com/debian/ stable main' \
    > /etc/apt/sources.list.d/yarn.list && \
  echo "**** install build dependencies ****" && \
  apt-get update && \
  apt-get install -y \
    build-essential \
    libx11-dev \
    libxkbfile-dev \
    libsecret-1-dev \
    pkg-config && \
  echo "**** install runtime dependencies ****" && \
  apt-get install -y \
    git \
    jq \
    nano \
    net-tools \
    nodejs \
    sudo \
    yarn && \
  echo "**** install code-server ****" && \
  if [ -z ${CODE_RELEASE+x} ]; then \
    CODE_RELEASE=$(curl -sX GET https://registry.yarnpkg.com/code-server \
    | jq -r '."dist-tags".latest' | sed 's|^|v|'); \
  fi && \
  CODE_VERSION=$(echo "$CODE_RELEASE" | awk '{print substr($1,2); }') && \
  yarn config set network-timeout 600000 -g && \
  yarn --production --verbose --frozen-lockfile global add code-server@"$CODE_VERSION" && \
  yarn cache clean && \
  echo "**** clean up ****" && \
  apt-get purge --auto-remove -y \
    build-essential \
    libx11-dev \
    libxkbfile-dev \
    libsecret-1-dev \
    pkg-config && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY /root /

RUN sudo apt update
RUN sudo apt -y install software-properties-common
RUN add-apt-repository -y ppa:ondrej/php
RUN sudo apt update
RUN sudo apt -y install composer \
    php8.0 \
    php8.0-dev \
    php8.0-bcmath \
    php8.0-ctype \
    php8.0-curl \
    php8.0-gd \
    php8.0-intl \
    php8.0-mbstring \
    php8.0-mysql \
    php8.0-pgsql \
    php8.0-sqlite3 \
    php8.0-tokenizer \
    php8.0-xml \
    php8.0-zip 

RUN echo "**** install php7.4 ****"
RUN apt update && \
    apt install -y \
    php7.4 \
    php7.4-xml \
    php7.4-mongodb \
    php7.4-mysql \
    php7.4-imagick \
    php7.4-imap \
    php7.4-fpm \
    php7.4-cli \
    php7.4-bcmath \
    php7.4-mbstring 
    
RUN echo "**** install php8.1 ****"
RUN apt update && \
    apt install -y \
    php8.1 \
    php8.1-xml \
    php8.1-mongodb \
    php8.1-mysql \
    php8.1-imagick \
    php8.1-imap \
    php8.1-fpm \
    php8.1-cli \
    php8.1-bcmath \
    php8.1-mbstring 

RUN sudo apt update
RUN sudo apt install -y git zip unzip build-essential libssl-dev libffi-dev python3-dev python3.8 lsof -y
RUN sudo apt-get install -y apt-transport-https ca-certificates gnupg

# Install google cli tools
RUN sudo npm install -g firebase-tools
RUN sudo apt-get install -y apt-transport-https ca-certificates gnupg
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN sudo apt-get update && sudo apt-get install -y \
    google-cloud-sdk \
    google-cloud-sdk-datastore-emulator \
    google-cloud-sdk-cloud-build-local \
    google-cloud-sdk-pubsub-emulator

# RUN sudo apt update
# RUN sudo apt install -y docker docker-compose

# ports and volumes
EXPOSE 2999-9000
RUN sudo usermod --shell /bin/zsh abc

COPY ./.zshrc /home