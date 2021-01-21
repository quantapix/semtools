ARG REG
ARG TAG

FROM ubuntu:focal AS ubu
ENV DEBIAN_FRONTEND=noninteractive
RUN set -eux; \
	apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    dirmngr \
    gnupg \
    netbase \
    tzdata \
    wget \
	; \
	rm -rf /var/lib/apt/lists/* && mkdir /var/lib/apt/lists/partial


FROM $REG/ubu:$TAG AS tmp-pkgs
WORKDIR /tmp
COPY pkgs .
RUN pkgs/run.sh -i load && rm pkgs/run.sh

FROM scratch as pkgs
COPY --from=tmp-pkgs /tmp/pkgs /
