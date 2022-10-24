# NOS3 Ubuntu Dockerfile

FROM ubuntu:20.04 AS nos1

# Enable i386 architecture
RUN dpkg --add-architecture i386

# Install required packages
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y \
    && apt-get install -y \
        cmake \
        g++-multilib \
        gcc-multilib \
        python-apt \
        python3-dev \
        python3-pip \
        dwarves \
        freeglut3-dev:i386 \
        lib32z1 \
        libboost-dev:i386 \
        libboost-system-dev:i386 \
        libboost-program-options-dev:i386 \
        libboost-filesystem-dev:i386 \
        libboost-thread-dev:i386 \
        libboost-regex-dev:i386 \
        libgtest-dev \
        libicu-dev:i386 \
        libncurses5-dev \
        libsocketcan-dev \
        libxerces-c-dev \
        wget \
    && rm -rf /var/lib/apt/lists/*

# Install Xerces-C required for NOS Engine
FROM nos1 AS nos2
RUN cd /tmp \
    && wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/xerces-c/3.2.0+debian-2/xerces-c_3.2.0+debian.orig.tar.gz \
    && tar -xf /tmp/xerces-c_3.2.0+debian.orig.tar.gz \
    && cd /tmp/xerces-c-3.2.0 \
    && /tmp/xerces-c-3.2.0/configure --prefix=/usr CFLAGS=-m32 CXXFLAGS=-m32 \
    && cd /tmp/xerces-c-3.2.0 \
    && make install

# Configure environment
FROM nos2 AS nos3
ADD ./nos3_filestore /nos3_filestore/
RUN sed 's/fs.mqueue.msg_max/fs.mqueue.msg_max=500/' /etc/sysctl.conf \
    && apt-get install -y \
        /nos3_filestore/packages/ubuntu/itc-common-Release_1.10.1_i386.deb \
        /nos3_filestore/packages/ubuntu/nos-engine-Release_1.6.1_i386.deb
