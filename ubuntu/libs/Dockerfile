# ubuntu/libs

ARG REG
ARG TAG


FROM $REG/old-dev:$TAG AS tmp-pkg-dev
WORKDIR /tmp
COPY pkgs .
RUN ./qpx.sh -r

FROM scratch as pkg-dev
COPY --from=tmp-pkg-dev . .


FROM $REG/new-dev:$TAG AS tmp-src-dev
WORKDIR /tmp
COPY srcs .
RUN ./qpx.sh -r

FROM $REG/new-dev:$TAG AS src-dev
COPY --from=tmp-src-dev . .


FROM $REG/old:$TAG AS tmp-mkl
RUN set -ex; \
	apt-get update && apt-get install -y --no-install-recommends \
    intel-mkl \
	; \
	rm -rf /var/lib/apt/lists/*

FROM scratch as mkl
COPY --from=tmp-mkl . .
