ARG REG
ARG TAG

FROM ubuntu:focal AS ubu
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


FROM $REG/ubu:$TAG AS tmp-pkgs
ENV LANG=C.UTF-8
WORKDIR /tmp
COPY pkgs .
RUN ./run.sh -i pkgs

FROM scratch as pkgs
ENV LANG=C.UTF-8
COPY --from=tmp-pkgs /tmp /
