FROM debian:stretch as builder
MAINTAINER Respoke <info@respoke.io>

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
COPY build-asterisk.sh /build-asterisk
RUN /build-asterisk && rm -f /build-asterisk
COPY asterisk-docker-entrypoint.sh /

# ---------------------------------

FROM debian:stretch-slim

RUN useradd --system asterisk && \
    apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
            ca-certificates \
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
    apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/* && \
    chown -R asterisk:asterisk /var/*/asterisk && \
    chmod -R 750 /var/spool/asterisk


COPY --from=builder /etc/asterisk/ /etc/asterisk/
COPY --from=builder /usr/sbin/ /usr/sbin/
COPY --from=builder /usr/lib/asterisk/ /usr/lib/asterisk/
COPY --from=builder /usr/lib/libasterisk* /usr/lib/
COPY --from=builder /run/asterisk/ /run/asterisk/
COPY --from=builder /var/lib/asterisk/ /var/lib/asterisk/
COPY --from=builder /var/spool/asterisk/ /var/spool/asterisk/
COPY --from=builder /var/log/asterisk /var/log/asterisk

COPY asterisk-docker-entrypoint.sh /


CMD ["/usr/sbin/asterisk", "-f"]
ENTRYPOINT ["/asterisk-docker-entrypoint.sh"]
