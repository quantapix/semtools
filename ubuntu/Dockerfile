ARG REG
ARG TAG

FROM ubuntu:focal AS tmp-base
RUN set -eux; \
	apt-get update; \
  apt-get dist-upgrade -y --no-install-recommends; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		netbase \
		wget \
		tzdata \
	; \
  apt-get update; \
	apt-get install -y --no-install-recommends \
		openssh-client \
		procps \
	; \
	rm -rf /var/lib/apt/lists/*

FROM scratch as ubu-base
COPY --from=tmp-base . .

FROM $REG/ubu-base:$TAG AS tmp-mkl
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
    intel-mkl \
	; \
	rm -rf /var/lib/apt/lists/*

FROM scratch as ubu-mkl
COPY --from=tmp-mkl . .

FROM $REG/ubu-base:$TAG AS tmp-dev
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    cmake \
    file \
    gfortran \
    git \
    pkg-config \
    python3 \
    unzip \
    wget \
    zlib1g-dev \
    \
#		imagemagick \
#		libbz2-dev \
#		libcurl4-openssl-dev \
#		libdb-dev \
#		libevent-dev \
#		libffi-dev \
#		libgdbm-dev \
#		libglib2.0-dev \
#		libgmp-dev \
#		libjpeg-dev \
#		libkrb5-dev \
#		liblzma-dev \
#		libmagickcore-dev \
#		libmagickwand-dev \
#		libmaxminddb-dev \
#		libncurses5-dev \
#		libncursesw5-dev \
#		libpng-dev \
#		libpq-dev \
#		libreadline-dev \
#		libsqlite3-dev \
#		libssl-dev \
#		libtool \
#		libwebp-dev \
#		libxml2-dev \
#		libxslt-dev \
#		libyaml-dev \
#		$( \
#			if apt-cache show 'default-libmysqlclient-dev' 2>/dev/null | grep -q '^Version:'; then \
#				echo 'default-libmysqlclient-dev'; \
#			else \
#				echo 'libmysqlclient-dev'; \
#			fi \
#		) \
	; \
	rm -rf /var/lib/apt/lists/*

FROM scratch as ubu-dev
COPY --from=tmp-dev . .
