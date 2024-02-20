# NOS3 Ubuntu Dockerfile
#
# https://github.com/nasa-itc/deployment
#
# docker build -t ivvitc/nos3-64:latest .
# docker run -it ivvitc/nos3-64 /bin/bash
# docker push ivvitc/nos3-64:latest

FROM ubuntu:jammy-20240212 AS nos0

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y \
    && apt-get install -y \
        cmake \
        g++-multilib \ 
        gcc-multilib \ 
        git \
		gdb \
        python3-dev \
        python3-pip \
        dwarves \
        freeglut3-dev \
        libboost-dev \
        libboost-system-dev \
        libboost-program-options-dev \
        libboost-filesystem-dev \
        libboost-thread-dev \
        libboost-regex-dev \
        libgtest-dev \
        libicu-dev \
        libncurses5-dev \
        libreadline-dev \
        libsocketcan-dev \
        libxerces-c-dev \
		netcat \
        wget \
    && rm -rf /var/lib/apt/lists/*

FROM nos0 AS nos1
ADD ./nos3_filestore /nos3_filestore/
RUN sed 's/fs.mqueue.msg_max/fs.mqueue.msg_max=500/' /etc/sysctl.conf \
    && apt-get install -y \
        /nos3_filestore/packages/ubuntu/*_amd64.deb \
    && chmod -R 777 /usr \
    && ln -s /usr/lib/libnos_engine_client.so /usr/lib/libnos_engine_client_cxx11.so \
#    && mkdir -p /opt/nos3 \
#    && cd /opt/nos3 \
#    && git clone https://github.com/ericstoneking/42.git --depth=1 \
#    && cd /opt/nos3/42 \
#    && git reset --hard f20d8d517b352b868d2f45ee3bffdb7deeedb218 \
#    && cd /opt/nos3/42 \
#    && sed 's/#GLUT_OR_GLFW = _USE_GLUT_/GLUT_OR_GLFW = _USE_GLUT_/' -i /opt/nos3/42/Makefile \
#    && make \
#    && chmod -R 777 /opt
