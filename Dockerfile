FROM alpine:latest

ENV UID 1000
ENV USERNAME samba
ENV GID 1000
ENV GROUP samba
ENV PASSWORD password
ENV CONF_DIR /config

#COPY repositories /etc/apk/repositories

RUN set -xe\
	&& apk add --update --no-cache samba-common-tools samba-server curl gnupg

ENV S6_VERSION 1.18.1.5

#download s6-overlay
RUN set -xe \
        && curl -Lo /tmp/s6.tar.gz https://github.com/just-containers/s6-overlay/releases/download/v$S6_VERSION/s6-overlay-amd64.tar.gz \
        && curl -Lo /tmp/s6.sig https://github.com/just-containers/s6-overlay/releases/download/v$S6_VERSION/s6-overlay-amd64.tar.gz.sig \
        && curl -Lo /tmp/key.asc https://keybase.io/justcontainers/key.asc

RUN set -xe \
        && cd /tmp \
        && gpg --import /tmp/key.asc \
        && gpg --verify /tmp/s6.sig /tmp/s6.tar.gz \
        && tar xzf s6.tar.gz -C / \
        && rm -rf /tmp /root/.gnupg

RUN set -xe \
	&& apk del gnupg curl

COPY create-samba-users.s6 /etc/cont-init.d/00-create-samba-users.sh
COPY create-tmp-folder.s6 /etc/cont-init.d/01-create-tmp-folder.sh
COPY run-samba-server.s6 /etc/services.d/samba/run
#COPY finish-samba-server.s6 /etc/services.d/samba/finish

EXPOSE 137/udp 138/udp 139/tcp 445/tcp

CMD ["/init"]
