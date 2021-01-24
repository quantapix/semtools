# golang

ARG REG
ARG TAG
ARG DST

FROM $REG/pkg-dev:$TAG AS tmp_pkg
WORKDIR /tmp
COPY pkgs .
RUN ./qpx.sh -r "" ${DST}

FROM $REG/old:$TAG AS go_pkg
ENV GOLANG_VERSION=1.15.6 \
    GOLANG_PATH=${DST}/go \
    PATH=$GOLANG_PATH/bin:$PATH
COPY --from=tmp_pkg ${DST} ${DST}
ENV GOPATH=/go \
    PATH=$GOPATH/bin:$PATH
RUN mkdir -p $GOPATH/src $GOPATH/bin && chmod -R 777 $GOPATH
WORKDIR $GOPATH


FROM $REG/pkg-dev:$TAG AS tmp_src
RUN set -eux; \
		apt-get update && apt-get install -y --no-install-recommends \
        golang-go
WORKDIR /tmp
COPY srcs .
RUN ./qpx.sh -r old ${DST}

FROM $REG/old:$TAG AS go_src
ENV GOLANG_VERSION=1.15.6 \
    GOLANG_PATH=${DST}/go \
    PATH=$GOLANG_PATH/bin:$PATH
COPY --from=tmp_src ${DST} ${DST}
ENV GOPATH=/go \
    PATH=$GOPATH/bin:$PATH
RUN mkdir -p $GOPATH/src $GOPATH/bin && chmod -R 777 $GOPATH
WORKDIR $GOPATH