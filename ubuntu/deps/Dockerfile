ARG REG
ARG TAG


FROM $REG/qpx-dev:$TAG AS tmp_src
WORKDIR /tmp
COPY srcs srcs
COPY srcs.sh .
RUN chmod u+x srcs.sh; ./srcs.sh -b

FROM $REG/qpx-base:$TAG AS qpx_src
COPY --from=tmp_src /usr/local /usr/local


FROM $REG/qpx-base:$TAG AS tmp-mkl
RUN set -ex; \
	apt-get update && apt-get install -y --no-install-recommends \
    intel-mkl \
	; \
	rm -rf /var/lib/apt/lists/* && mkdir /var/lib/apt/lists/partial

FROM scratch as qpx-mkl
COPY --from=tmp-mkl . .
