# NOS3 Ubuntu Dockerfile
# https://github.com/nasa-itc/deployment
#
# Install latest docker from PPA: https://docs.docker.com/engine/install/ubuntu/
# 
# Debugging
#   docker build -t ivvitc/nos3-64:dev .
#   docker run -it ivvitc/nos3-64:dev /bin/bash
#
# Follow multi-arch instructions: https://www.docker.com/blog/multi-arch-images/
#   docker login ivvitc
#   docker buildx create --name nos3builder
#   docker buildx use nos3builder
#   docker buildx build --platform linux/amd64,linux/arm64 -t ivvitc/nos3-64:20241219 --push .
# 

FROM ubuntu:jammy-20240530 AS nos0
ADD ./nos3_filestore /nos3_filestore/
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y \
    && apt-get install -y \
        bc \
        cmake \
        curl \
        dwarves \
        freeglut3-dev \
        gcovr \
        gdb \
        git \
        lcov \
        libboost-dev \
        libboost-system-dev \
        libboost-program-options-dev \
        libboost-filesystem-dev \
        libboost-thread-dev \
        libboost-regex-dev \
        libcurl4-openssl-dev \
        libgtest-dev \
        libicu-dev \
        libncurses5-dev \
        libreadline-dev \
        libsocketcan-dev \
        libxerces-c-dev \
        maven \
        netcat \
        openjdk-17-jdk \
        openjdk-17-jre \
        python3-dev \
        python3-pip \
        python-is-python3 \
        python3.10-venv \
        python3-sphinx \
        python3-sphinx-rtd-theme \
        python3-myst-parser \
        unzip \
        wget \
    && rm -rf /var/lib/apt/lists/*
RUN python3 -m pip install --upgrade pip \
    && pip3 install -r /nos3_filestore/requirements.txt \ 
    && pip3 install ait-core==2.5.2 ait-gui==2.4.1 rawsocket==0.2

FROM nos0 AS nos1
ADD ./nos3_filestore /nos3_filestore/
RUN sed 's/fs.mqueue.msg_max/fs.mqueue.msg_max=500/' /etc/sysctl.conf \
    && arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) \
    && apt-get install -y \
        /nos3_filestore/packages/ubuntu/*_${arch}.deb \
    && chmod -R 777 /usr \
    && ln -s /usr/lib/libnos_engine_client.so /usr/lib/libnos_engine_client_cxx11.so

FROM nos1 AS nos2
# For CryptoLib
ARG GPG_ERROR_VERSION=1.50
ARG GCRYPT_VERSION=1.11.0
RUN curl \ 
    -LS https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-${GPG_ERROR_VERSION}.tar.bz2 \
    -o /tmp/libgpg-error-${GPG_ERROR_VERSION}.tar.bz2 \
    && tar -xjf /tmp/libgpg-error-${GPG_ERROR_VERSION}.tar.bz2 -C /tmp/ \
    && cd /tmp/libgpg-error-${GPG_ERROR_VERSION} \
    && ./configure \
    && make install \
    && export LD_LIBRARY_PATH="$LD_LIBRARYPATH:/usr/local/lib" \
    && curl \ 
        -LS https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-${GCRYPT_VERSION}.tar.bz2 \
        -o /tmp/libgcrypt-${GCRYPT_VERSION}.tar.bz2 \
    && tar -xjf /tmp/libgcrypt-${GCRYPT_VERSION}.tar.bz2 -C /tmp/ \
    && cd /tmp/libgcrypt-${GCRYPT_VERSION} \
    && ./configure \
    && make install \
    && ldconfig \
    && rm -rf /tmp/*
