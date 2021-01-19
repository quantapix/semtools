# ubuntu

ARG REG
ARG TAG


FROM scratch as tmp-old
ENV DEBIAN_FRONTEND=noninteractive
ADD pkgs/focal/ubuntu-focal-core-cloudimg-amd64-root.tar.gz /
WORKDIR /tmp
COPY pkgs .
RUN set -eux; \
    pkgs/run.sh -r; rm pkgs.sh; \
    apt-get update && apt-get dist-upgrade -y --install-recommends; \
    rm -rf /var/lib/apt/lists/* && mkdir /var/lib/apt/lists/partial

FROM scratch as old
COPY --from=tmp-old . .


FROM $REG/old:$TAG AS tmp-old-dev
ENV DEBIAN_FRONTEND=noninteractive
RUN set -ex; \
	apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    devscripts \
    git \
    pkg-config \
	; \
	rm -rf /var/lib/apt/lists/* && mkdir /var/lib/apt/lists/partial

FROM scratch as old-dev
COPY --from=tmp-old-dev . .


FROM scratch as tmp-new
ENV DEBIAN_FRONTEND=noninteractive
ADD pkgs/hirsute/ubuntu-hirsute-core-cloudimg-amd64-root.tar.gz /
WORKDIR /tmp
COPY pkgs .
RUN set -eux; \
    pkgs/run.sh -r; rm pkgs.sh; \
    apt-get update && apt-get dist-upgrade -y --install-recommends; \
    rm -rf /var/lib/apt/lists/* && mkdir /var/lib/apt/lists/partial

FROM scratch as new
COPY --from=tmp-new . .


FROM $REG/new:$TAG AS tmp-new-dev
ENV DEBIAN_FRONTEND=noninteractive
RUN set -ex; \
	apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    devscripts \
    git \
    pkg-config \
	; \
	rm -rf /var/lib/apt/lists/* && mkdir /var/lib/apt/lists/partial

FROM scratch as new-dev
COPY --from=tmp-new-dev . .


#   apt-get update && apt-get install -y --no-install-recommends \
#     openssh-client \
#     procps \
#   	; \

#    aptMark="$(apt-mark showmanual)"
#    if ! command -v gpg > /dev/null; then 
#        apt-get update
#        apt-get install -y --no-install-recommends wget gnupg dirmngr
#        rm -rf /var/lib/apt/lists/*
#    fi; 

#    apt-mark auto '.*' > /dev/null
#    [ -z "$aptMark" ] || apt-mark manual $aptMark
#    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
