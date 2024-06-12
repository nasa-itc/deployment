# NOS3 Ubuntu Dockerfile
# https://github.com/nasa-itc/deployment
#
# Install latest docker from PPA: https://docs.docker.com/engine/install/ubuntu/
# 
# Follow multi-arch instructions: https://www.docker.com/blog/multi-arch-images/
#   docker buildx create --name nos3builder
#   docker buildx use nos3builder
#   docker buildx build --platform linux/amd64,linux/arm64 -t ivvitc/nos3-64:dev .
# 
# Debugging
#   docker run -it ivvitc/nos3-64:dev /bin/bash
#
# Pushing
#   docker login ivvitc
#   docker push ivvitc/nos3-64:dev

FROM ubuntu:jammy-20240212 AS nos0

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y \
    && apt-get install -y \
        cmake \
        curl \
        git \
		gdb \
        python3-dev \
        python3-pip \
        python-is-python3 \
        dwarves \
        freeglut3-dev \
        libboost-dev \
        libboost-system-dev \
        libboost-program-options-dev \
        libboost-filesystem-dev \
        libboost-thread-dev \
        libboost-regex-dev \
        libcurl4-openssl-dev \
        libmariadb-dev \
        libmariadb-dev-compat \
        libgcrypt20-dev \
        libgtest-dev \
        libicu-dev \
        libncurses5-dev \
        libreadline-dev \
        libsocketcan-dev \
        libxerces-c-dev \
		netcat \
        unzip \
        wget \
    && rm -rf /var/lib/apt/lists/*

FROM nos0 AS nos1
ADD ./nos3_filestore /nos3_filestore/
RUN sed 's/fs.mqueue.msg_max/fs.mqueue.msg_max=500/' /etc/sysctl.conf \
    && arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) \
    && apt-get install -y \
        /nos3_filestore/packages/ubuntu/*_${arch}.deb \
    && chmod -R 777 /usr \
    && ln -s /usr/lib/libnos_engine_client.so /usr/lib/libnos_engine_client_cxx11.so

FROM nos1 AS nos2
ARG WOLFSSL_VERSION=5.6.0-stable
RUN curl \
        -LS https://github.com/wolfSSL/wolfssl/archive/v${WOLFSSL_VERSION}.zip \
        -o v${WOLFSSL_VERSION}.zip \
    && unzip v${WOLFSSL_VERSION}.zip \
    && rm v${WOLFSSL_VERSION}.zip \
    && cd wolfssl-${WOLFSSL_VERSION} \
    && mkdir -p build \
    && cd build \
    && cmake -DWOLFSSL_AESCCM=yes -DWOLFSSL_AESSIV=yes -DWOLFSSL_CMAC=yes .. \
    && cmake --build . \
    && make install \
    && ldconfig 