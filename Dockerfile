FROM debian:buster
LABEL maintainer="sailorpapay <sailorpapayy@gmail.com>"
LABEL description="Image with Janus Gateway 2020"

RUN apt-get update -y \
    && apt-get upgrade -y

RUN apt-get install -y \
    build-essential \
    libmicrohttpd-dev \
    libjansson-dev \
    libssl-dev \
    libsofia-sip-ua-dev \
    libglib2.0-dev \
    libopus-dev \
    libogg-dev \
    libini-config-dev \
    libcollection-dev \
    pkg-config \
    gengetopt \
    libtool \
    autotools-dev \
    libcurl4-openssl-dev \
    automake \
    libconfig-dev \
    gtk-doc-tools

RUN apt-get install -y \
    sudo \
    make \
    git \
    doxygen \
    graphviz \
    cmake \
    nginx

RUN cd ~ \
    && git clone https://github.com/cisco/libsrtp.git \
    && cd libsrtp \
    && git checkout v2.3.0 \
    && ./configure --prefix=/usr --enable-openssl \
    && make shared_library \
    && sudo make install

RUN cd ~ \
    && git clone https://github.com/sctplab/usrsctp \
    && cd usrsctp \
    && ./bootstrap \
    && ./configure --prefix=/usr \
    && make \
    && sudo make install

RUN cd ~ \
    && git clone https://github.com/warmcat/libwebsockets.git \
    && cd libwebsockets \
    && git checkout v4.1.6 \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr .. \
    && make \
    && sudo make install


RUN cd ~ \
    && git clone https://github.com/sailorpapay/libnice \
    && cd libnice \
    && ./autogen.sh \
    && ./configure --prefix=/usr \
    && make \
    && sudo make install

RUN cd ~ \
    && git clone https://github.com/meetecho/janus-gateway.git \
    && cd janus-gateway \
    && sh autogen.sh \
    && ./configure --prefix=/opt/janus --disable-rabbitmq  \
    && make CFLAGS='-std=c99' \
    && make install \
    && make configs


RUN rm /opt/janus/etc/janus/*
ADD ./conf/*.jcfg /opt/janus/etc/janus/
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80 7088 8088 8188 8089
EXPOSE 10000-10200/udp

CMD service nginx restart && /opt/janus/bin/janus --nat-1-1=${DOCKER_IP}
