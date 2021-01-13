FROM ubuntu:focal
RUN set -eux; \
	apt-get update; \
  apt-get upgrade; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		openssh-client \
		procps \
		# netbase \
		# tzdata \
		# wget \
	; \
	rm -rf /var/lib/apt/lists/*


# RUN set -eux; \
# 	savedAptMark="$(apt-mark showmanual)"; \
# 	if ! command -v gpg > /dev/null; then \
# 		apt-get update; \
# 		apt-get install -y --no-install-recommends \
# 			gnupg \
# 			dirmngr \
# 		; \
# 		rm -rf /var/lib/apt/lists/*; \
# 	fi; \

# 	apt-mark auto '.*' > /dev/null; \
# 	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
# 	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \

