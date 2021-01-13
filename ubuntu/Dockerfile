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

