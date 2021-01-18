ARG REG
ARG TAG


FROM scratch as tmp-old
ENV DEBIAN_FRONTEND=noninteractive
ADD pkgs/focal/ubuntu-focal-core-cloudimg-amd64-root.tar.gz /
WORKDIR /var/lib
COPY pkgs.sh .
RUN set -eux; \
    chmod u+x pkgs.sh; ./pkgs.sh -l; rm pkgs.sh; \
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
	; \
	rm -rf /var/lib/apt/lists/* && mkdir /var/lib/apt/lists/partial

FROM scratch as old-dev
COPY --from=tmp-old-dev . .


FROM scratch as tmp-new
ENV DEBIAN_FRONTEND=noninteractive
ADD pkgs/hirsute/ubuntu-hirsute-core-cloudimg-amd64-root.tar.gz /
WORKDIR /var/lib
COPY pkgs.sh .
RUN set -eux; \
    chmod u+x pkgs.sh; ./pkgs.sh -l; rm pkgs.sh; \
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
	; \
	rm -rf /var/lib/apt/lists/* && mkdir /var/lib/apt/lists/partial

FROM scratch as new-dev
COPY --from=tmp-new-dev . .


#   apt-get update && apt-get install -y --no-install-recommends \
#     openssh-client \
#     procps \
#   	; \

#    autoconf \
#    automake \
#    cmake \
#    file \
#    gfortran \
#    python3 \
#    pkg-config \
#    unzip \
#    wget \
#    zlib1g-dev \

#    imagemagick \
#    libbz2-dev \
#    libcurl4-openssl-dev \
#    libdb-dev \
#    libevent-dev \
#    libffi-dev \
#    libgdbm-dev \
#    libglib2.0-dev \
#    libgmp-dev \
#    libjpeg-dev \
#    libkrb5-dev \
#    liblzma-dev \
#    libmagickcore-dev \
#    libmagickwand-dev \
#    libmaxminddb-dev \
#    libncurses5-dev \
#    libncursesw5-dev \
#    libpng-dev \
#    libpq-dev \
#    libreadline-dev \
#    libsqlite3-dev \
#    libssl-dev \
#    libtool \
#    libwebp-dev \
#    libxml2-dev \
#    libxslt-dev \
#    libyaml-dev \
#    $( \
#    	if apt-cache show 'default-libmysqlclient-dev' 2>/dev/null | grep -q '^Version:'; then \
#    echo 'default-libmysqlclient-dev'; \
#    	else \
#    echo 'libmysqlclient-dev'; \
#    	fi \
#    ) \

#    aptMark="$(apt-mark showmanual)"
#    if ! command -v gpg > /dev/null; then 
#        apt-get update
#        apt-get install -y --no-install-recommends wget gnupg dirmngr
#        rm -rf /var/lib/apt/lists/*
#    fi; 

#    apt-mark auto '.*' > /dev/null
#    [ -z "$aptMark" ] || apt-mark manual $aptMark
#    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
