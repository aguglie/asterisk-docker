FROM debian:stretch as builder

RUN useradd --system asterisk

RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
            autoconf \
            binutils-dev \
            build-essential \
            ca-certificates \
            curl \
            libcurl4-openssl-dev \
            libedit-dev \
            libgsm1-dev \
            libjansson-dev \
            libogg-dev \
            libpopt-dev \
            libresample1-dev \
            libspandsp-dev \
            libspeex-dev \
            libspeexdsp-dev \
            libsqlite3-dev \
            libsrtp0-dev \
            libssl-dev \
            libvorbis-dev \
            libxml2-dev \
            libxslt1-dev \
            portaudio19-dev \
            unixodbc-dev \
            uuid \
            uuid-dev \
            xmlstarlet \
            && \
    apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/*

ENV ASTERISK_VERSION=16.27.0
COPY build-asterisk.sh /build-asterisk.sh
RUN /build-asterisk.sh && rm -f /build-asterisk.sh

# ---------------------------------

FROM debian:stretch-slim

COPY --from=builder /usr/src/asterisk /usr/src/asterisk 

RUN useradd --system asterisk && \

    # Install dependencies
    apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
            ca-certificates \
            make \
            binutils \
            curl \
            libcurl3 \
            libedit2 \
            libgsm1 \
            libjansson4 \
            libogg0 \
            libpopt0 \
            libresample1 \
            libspandsp2 \
            libspeex1 \
            libspeexdsp1 \
            libsqlite3-0 \
            libsrtp0 \
            libssl1.1 \
            libvorbis0a  \
            libxml2 \
            libxslt1.1 \
            libportaudio2 \
            unixodbc \
            uuid \
            && \
    apt-get purge -y --auto-remove && \
    rm -rf /var/lib/apt/lists/* && \

    # install Asterisk    
    cd /usr/src/asterisk && \
    make install && \
    chown -R asterisk:asterisk /var/*/asterisk && \
    chmod -R 750 /var/spool/asterisk && \
    mkdir -p /etc/asterisk/ && \
    cp /usr/src/asterisk/configs/basic-pbx/*.conf /etc/asterisk/ && \
    sed -i -E 's/^;(run)(user|group)/\1\2/' /etc/asterisk/asterisk.conf && \
    rm -rf /usr/src/asterisk

CMD ["/usr/sbin/asterisk", "-f"]
