# golang

ARG REG
ARG TAG


FROM $REG/pkg-dev:$TAG AS tmp_pkg
ENV VER=1.15.6 \
    DST=/usr/local/go
WORKDIR /tmp
COPY pkgs pkgs
RUN pkgs/qpx.sh -r ${VER} ${DST}

FROM $REG/old:$TAG AS go_pkg
ENV GOLANG_VERSION=1.15.6 \
    GOLANG_PATH=/usr/local/go \
    PATH=$GOLANG_PATH/bin:$PATH
COPY --from=tmp_pkg /usr/local /usr/local
ENV GOPATH /go \
    PATH=$GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH


FROM $REG/pkg-dev:$TAG AS tmp_src
RUN set -eux; \
		apt-get update && apt-get install -y --no-install-recommends \
        golang-go
ENV VER=1.15.6 \
    DST=/usr/local/go
WORKDIR /tmp
COPY srcs srcs
RUN srcs/qpx.sh -r old ${DST}

FROM $REG/old:$TAG AS go_src
ENV GOLANG_VERSION=1.15.6 \
    GOLANG_PATH=/usr/local/go \
    PATH=$GOLANG_PATH/bin:$PATH
COPY --from=tmp_src /usr/local /usr/local
ENV GOPATH /go \
    PATH=$GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH