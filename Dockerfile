FROM ubuntu:xenial

# Required system packages
RUN apt-get update \
    && apt-get install -y \
        wget \
        build-essential \
        ruby \
        ruby-dev \
        libffi-dev \
        autoconf \
        libtool

RUN mkdir /build /build/root
WORKDIR /build

RUN gem install fpm

# Download package
RUN wget https://github.com/statsite/statsite/archive/v0.8.0.tar.gz \
    && echo "79d30a68e395b23e736eb2856ce35055aedb9662e4a00c2492b43b975b4ea24a  v0.8.0.tar.gz" | sha256sum --check - \
    && tar zxf v0.8.0.tar.gz

# Compile and install statsite
RUN cd /build/statsite-0.8.0 \
    && ./bootstrap.sh \
    && ./configure \
    && make \
    && make install DESTDIR=/build/root

# Add extras to the build root
COPY conf/* conf/
COPY scripts/* scripts/

RUN cd /build/root \
    && mkdir -p \
        etc/statsite \
        etc/systemd/system \
        usr/bin \
    && mv /build/conf/statsite.ini etc/statsite/statsite.ini \
    && mv /build/conf/statsite.service etc/systemd/system/statsite.service \
    && mv usr/local/bin/statsite usr/bin/statsite \
    && rm -rf usr/local

# Build deb
RUN fpm -s dir -t deb \
    -n statsite \
    -v 0.8.0 \
    -C /build/root \
    -p statsite_VERSION-ARCH.deb \
    --description 'Metrics aggregation server written in C based heavily on StatsD' \
    --url 'https://github.com/statsite/statsite' \
    --after-install scripts/postinstall \
    --after-remove scripts/postremove \
    --before-remove scripts/preremove \
    etc usr

