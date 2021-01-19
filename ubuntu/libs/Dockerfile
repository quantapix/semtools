# ubuntu/libs

ARG REG
ARG TAG


FROM $REG/old-dev:$TAG AS tmp-pkg-dev
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /tmp
COPY pkgs .
RUN pkgs/run.sh -r; rm pkgs/run.sh

FROM scratch as pkg-dev
COPY --from=tmp-pkg-dev . .


FROM $REG/new-dev:$TAG AS tmp-src-dev
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /tmp
COPY pkgs .
RUN pkgs/run.sh -r; rm pkgs/run.sh
COPY srcs .
RUN srcs/run.sh -r; rm srcs/run.sh

FROM $REG/new-dev:$TAG AS src-dev
COPY --from=tmp-src-dev /usr/local /usr/local


FROM $REG/old:$TAG AS tmp-mkl
RUN set -ex; \
	apt-get update && apt-get install -y --no-install-recommends \
    intel-mkl \
	; \
	rm -rf /var/lib/apt/lists/* && mkdir /var/lib/apt/lists/partial

FROM scratch as mkl
COPY --from=tmp-mkl . .
