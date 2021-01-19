# golang

ARG REG
ARG TAG


FROM $REG/pkg-dev:$TAG AS tmp_pkg
ENV VER=1.15.6
ENV DST=/usr/local/go/
WORKDIR /tmp
COPY pkgs .
RUN pkgs/run.sh -r ${VER} ${DST}; rm pkgs/run.sh

FROM $REG/old:$TAG AS go_pkg
ENV GOLANG_VERSION=1.15.6
ENV GOLANG_PATH /usr/local/go/
ENV PATH $GOLANG_PATH/bin:$PATH
COPY --from=tmp_pkg ${GOLANG_PATH} ${GOLANG_PATH}
ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH

FROM $REG/pkg-dev:$TAG AS tmp_src
RUN set -eux; \
		aptMark="$(apt-mark showmanual)"; \
		apt-get update && apt-get install -y --no-install-recommends golang-go
ENV VER=1.15.6
ENV DST /usr/local/go/
WORKDIR /tmp
# COPY deps* .
# RUN chmod u+x deps.sh; ./deps.sh -b old ${DST}
COPY srcs .
RUN srcs/run.sh -r old ${DST}; rm srcs/run.sh
RUN set -eux; \
		apt-mark auto '.*' > /dev/null; \
		apt-mark manual $aptMark > /dev/null; \
		apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/* && mkdir /var/lib/apt/lists/partial

FROM $REG/old:$TAG AS go_src
ENV GOLANG_VERSION=1.15.6
ENV GOLANG_PATH /usr/local/go/
ENV PATH $GOLANG_PATH/bin:$PATH
COPY --from=tmp_src ${GOLANG_PATH} ${GOLANG_PATH}
ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH