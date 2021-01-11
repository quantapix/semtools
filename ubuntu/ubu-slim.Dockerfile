FROM ubuntu:focal
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		netbase \
		wget \
		tzdata \
	; \
	rm -rf /var/lib/apt/lists/*
RUN set -ex; \
	if ! command -v gpg > /dev/null; then \
		apt-get update; \
		apt-get install -y --no-install-recommends \
			gnupg \
			dirmngr \
		; \
		rm -rf /var/lib/apt/lists/*; \
	fi
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		git \
		openssh-client \
		procps \
	&& rm -rf /var/lib/apt/lists/*
