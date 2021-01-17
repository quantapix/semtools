ARG REG
ARG TAG


FROM ubuntu:focal AS tmp-lts
RUN set -eux; \
	apt-get update && apt-get dist-upgrade -y --no-install-recommends; \
	rm -rf /var/lib/apt/lists/* && mkdir /var/lib/apt/lists/partial

FROM scratch as ubu-lts
COPY --from=tmp-lts . .


FROM $REG/ubu-lts:$TAG AS tmp-old-run
RUN set -eux; \
	apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		netbase \
		wget \
		tzdata \
	; \
  apt-get update && apt-get install -y --no-install-recommends \
		openssh-client \
		procps \
	; \
	rm -rf /var/lib/apt/lists/* && mkdir /var/lib/apt/lists/partial

FROM scratch as old-run
COPY --from=tmp-old-run . .


FROM $REG/old-run:$TAG AS tmp-old-dev
RUN set -ex; \
	apt-get update && apt-get install -y --no-install-recommends \
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
	; \
	rm -rf /var/lib/apt/lists/* && mkdir /var/lib/apt/lists/partial

FROM scratch as old-dev
COPY --from=tmp-old-dev . .


FROM scratch as tmp-new-run
ADD pkgs/hirsute/ubuntu-hirsute-core-cloudimg-amd64-root.tar.gz /
RUN set -xe \
	\
	&& echo '#!/bin/sh' > /usr/sbin/policy-rc.d \
	&& echo 'exit 101' >> /usr/sbin/policy-rc.d \
	&& chmod +x /usr/sbin/policy-rc.d \
	\
	&& dpkg-divert --local --rename --add /sbin/initctl \
	&& cp -a /usr/sbin/policy-rc.d /sbin/initctl \
	&& sed -i 's/^exit.*/exit 0/' /sbin/initctl \
	\
	&& echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup \
	\
	&& echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean \
	&& echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean \
	&& echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean \
	\
	&& echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages \
	\
	&& echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes \
	\
	&& echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests
RUN [ -z "$(apt-get indextargets)" ]
RUN mkdir -p /run/systemd && echo 'docker' > /run/systemd/container
RUN set -eux; \
	apt-get update && apt-get dist-upgrade -y --no-install-recommends; \
	rm -rf /var/lib/apt/lists/* && mkdir /var/lib/apt/lists/partial

FROM scratch as new-run
COPY --from=tmp-new-run . .


FROM $REG/new-run:$TAG AS tmp-new-dev
RUN set -ex; \
	apt-get update &&	apt-get install -y --no-install-recommends \
    build-essential \
	; \
	rm -rf /var/lib/apt/lists/* && mkdir /var/lib/apt/lists/partial

FROM scratch as new-dev
COPY --from=tmp-new-dev . .


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
