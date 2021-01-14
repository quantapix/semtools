FROM ubuntu:focal
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
	rm -rf /var/lib/apt/lists/*
RUN set -eux; \
  apt-get update; \
	apt-get install -y --no-install-recommends \
		openssh-client \
		procps \
	; \
	rm -rf /var/lib/apt/lists/*

# RUN set -eux; \
# 	aptMark="$(apt-mark showmanual)"; \
# 	if ! command -v gpg > /dev/null; then \
# 		apt-get update; \
# 		apt-get install -y --no-install-recommends \
# 			gnupg \
# 			dirmngr \
# 		; \
# 		rm -rf /var/lib/apt/lists/*; \
# 	fi; \

# 	apt-mark auto '.*' > /dev/null; \
# 	[ -z "$aptMark" ] || apt-mark manual $aptMark; \
# 	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \

FROM qbrn.reg/ubu-run:std
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
    python \
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