ARG REG
ARG TAG
ARG DST

FROM ubuntu:focal AS boot
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8
RUN set -eux; \
    apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        netbase \
        tzdata \
        wget \
    ; \
    rm -rf /var/lib/apt/lists/*
RUN set -ex; \
    if ! command -v gpg > /dev/null; then \
        apt-get update && apt-get install -y --no-install-recommends \
            dirmngr \
            gnupg \
        ; \
        rm -rf /var/lib/apt/lists/*; \
    fi


FROM $REG/boot:$TAG AS tmp-pkgs
WORKDIR /tmp
COPY pkgs .
RUN ./qpx.sh -i pkgs

FROM scratch as pkgs
COPY --from=tmp-pkgs /tmp /
