# docker

ARG REG
ARG TAG
ARG DST

FROM alpine:3.12 as dkr
RUN apk add --no-cache \
		ca-certificates \
		openssh-client
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf
ENV DOCKER_VERSION=20.10.2 \
    DOCKER_TLS_CERTDIR=/certs
COPY modprobe.sh /usr/local/bin/modprobe
COPY docker-entrypoint.sh /usr/local/bin/
WORKDIR /tmp
COPY pkgs .
RUN mkdir /certs /certs/client && chmod 1777 /certs /certs/client \
    ./qpx.sh -r ${DOCKER_VERSION} ${DST}
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]