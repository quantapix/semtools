# golang

ARG REG
ARG TAG


FROM $REG/pkg-dev:$TAG AS tmp_pkg
ENV VER=1.15.6
ENV DST=/usr/local/go/
WORKDIR /tmp
COPY pkgs .
COPY pkgs.sh .
RUN chmod u+x pkgs.sh; ./pkgs.sh -l ${VER} ${DST}

FROM $REG/old:$TAG AS go_pkg
ENV GOLANG_VERSION=1.15.6
ENV GOLANG_PATH /usr/local/go/
ENV PATH $GOLANG_PATH/bin:$PATH
COPY --from=tmp_pkg ${GOLANG_PATH} ${GOLANG_PATH}


FROM $REG/pkg-dev:$TAG AS tmp_src
ENV VER=1.15.6
ENV DST /usr/local/go/
WORKDIR /tmp
# COPY deps* .
# RUN chmod u+x deps.sh; ./deps.sh -b old ${DST}
COPY srcs .
COPY srcs.sh .
RUN chmod u+x srcs.sh; ./srcs.sh -b old ${DST}

FROM $REG/old:$TAG AS go_src
ENV GOLANG_VERSION=1.15.6
ENV GOLANG_PATH /usr/local/go/
ENV PATH $GOLANG_PATH/bin:$PATH
COPY --from=tmp_src ${GOLANG_PATH} ${GOLANG_PATH}
