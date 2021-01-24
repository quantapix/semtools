# ubuntu

ARG REG
ARG TAG
ARG DST

FROM scratch as tmp-old
ADD pkgs/focal/ubuntu-focal-core-cloudimg-amd64-root.tar.gz /
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8
WORKDIR /tmp
COPY pkgs .
RUN set -eux; \
    ./qpx.sh -r; rm qpx.sh; \
    apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        netbase \
        tzdata \
    ; \
    rm -rf /var/lib/apt/lists/*

FROM scratch as old
COPY --from=tmp-old . .


FROM $REG/old:$TAG AS tmp-old-dev
RUN set -ex; \
    apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        devscripts \
        git \
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

FROM scratch as old-dev
COPY --from=tmp-old-dev . .


FROM scratch as tmp-new
ADD pkgs/hirsute/ubuntu-hirsute-core-cloudimg-amd64-root.tar.gz /
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8
WORKDIR /tmp
COPY pkgs .
RUN set -eux; \
    ./qpx.sh -r; rm qpx.sh; \
    apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        netbase \
        tzdata \
    ; \
    rm -rf /var/lib/apt/lists/*

FROM scratch as new
COPY --from=tmp-new . .


FROM $REG/new:$TAG AS tmp-new-dev
RUN set -ex; \
    apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        devscripts \
        git \
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

FROM scratch as new-dev
COPY --from=tmp-new-dev . .


# openssh-client \
# procps \

# aptMark="$(apt-mark showmanual)"
# if ! command -v gpg > /dev/null; then 
#    apt-get update
#    apt-get install -y --no-install-recommends wget gnupg dirmngr
#    rm -rf /var/lib/apt/lists/*
# fi

# apt-mark auto '.*' > /dev/null
# [ -z "$aptMark" ] || apt-mark manual $aptMark
# apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
