ARG REG
ARG TAG

FROM ubuntu:focal AS tmp-base
RUN set -eux; \
	apt-get update; \
  apt-get dist-upgrade -y --no-install-recommends; \
	rm -rf /var/lib/apt/lists/*

FROM scratch as qpx-base
COPY --from=tmp-base . .

FROM $REG/qpx-base:$TAG AS tmp-dev
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
    build-essential \
	; \
	rm -rf /var/lib/apt/lists/*

FROM scratch as qpx-dev
COPY --from=tmp-dev . .

FROM $REG/qpx-dev:$TAG AS tmp_src
WORKDIR /tmp
COPY srcs srcs
COPY srcs.sh .
RUN chmod u+x srcs.sh; ./srcs.sh -b

FROM $REG/qpx-base:$TAG AS qpx_src
COPY --from=qpx_src /usr/local /usr/local

FROM $REG/qpx-base:$TAG AS tmp-mkl
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
    intel-mkl \
	; \
	rm -rf /var/lib/apt/lists/*

FROM scratch as qpx-mkl
COPY --from=tmp-mkl . .
