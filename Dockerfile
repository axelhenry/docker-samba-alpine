FROM alpine:latest

ENV UID 1000
ENV USERNAME samba
ENV GID 1000
ENV GROUP samba
ENV PASSWORD password
#ENV CONFIG /config/smb.conf
ENV CONF_DIR /config

#RUN set -xe \
#	&& apk add --update --no-progress samba-common-tools samba-server openssl \
#	&& rm -rf /var/cache/apk/*

#COPY repositories /etc/apk/repositories

RUN set -xe\
	&& apk add --update --no-cache samba-common-tools samba-server curl gnupg

ENV S6_VERSION 1.18.1.5
#RUN set -xe \
#	&& cd /tmp \
#	&& wget https://github.com/just-containers/s6-overlay/releases/download/v$S6_VERSION/s6-overlay-amd64.tar.gz \
#	&& wget https://github.com/just-containers/s6-overlay/releases/download/v$S6_VERSION/s6-overlay-amd64.tar.gz.sig \
#	&& apk add --update --no-progress --virtual gpg gnupg \
#	&& wget -q -O - https://keybase.io/justcontainers/key.asc | gpg --import \
#	&& gpg --verify /tmp/s6-overlay-amd64.tar.gz.sig /tmp/s6-overlay-amd64.tar.gz \
#	&& tar xzf s6-overlay-amd64.tar.gz -C / \
#	&& apk del gpg \
#	&& rm -rf /tmp/s6-overlay-amd64.tar.gz /tmp/s6-overlay-amd64.tar.gz.sig /root/.gnupg /var/cache/apk/*

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
#COPY create-samba-user.s6 /etc/cont-init.d/00-create-samba-user.sh
COPY create-tmp-folder.s6 /etc/cont-init.d/01-create-tmp-folder.sh
COPY run-samba-server.s6 /etc/services.d/samba/run
COPY finish-samba-server.s6 /etc/services.d/samba/finish

EXPOSE 137/udp 138/udp 139/tcp 445/tcp

CMD ["/init"]
