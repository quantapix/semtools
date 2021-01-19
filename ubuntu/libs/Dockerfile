ARG REG
ARG TAG


FROM $REG/old-dev:$TAG AS tmp-pkg-dev
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /tmp
COPY pkgs.sh .
RUN chmod u+x pkgs.sh; ./pkgs.sh -l; rm pkgs.sh

FROM scratch as pkg-dev
COPY --from=tmp-pkg-dev . .


FROM $REG/new-dev:$TAG AS tmp-src-dev
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /tmp
COPY srcs srcs
COPY pkgs.sh .
RUN chmod u+x pkgs.sh; ./pkgs.sh -l; rm pkgs.sh
COPY srcs.sh .
RUN chmod u+x srcs.sh; ./srcs.sh -b; rm srcs.sh

FROM $REG/new:$TAG AS src-dev
COPY --from=tmp-src-dev /usr/local /usr/local


FROM $REG/old:$TAG AS tmp-mkl
RUN set -ex; \
	apt-get update && apt-get install -y --no-install-recommends \
    intel-mkl \
	; \
	rm -rf /var/lib/apt/lists/* && mkdir /var/lib/apt/lists/partial

FROM scratch as mkl
COPY --from=tmp-mkl . .
