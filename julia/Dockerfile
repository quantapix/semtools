# julia

ARG REG
ARG TAG

FROM $REG/pkg-dev:$TAG AS tmp_old_pkg
ENV VER=1.5.3 \
    DST=/usr/local/julia
WORKDIR /tmp
COPY pkgs pkgs
RUN pkgs/run.sh -r ${VER} ${DST} && rm pkgs/run.sh

FROM $REG/old:$TAG AS jl_old_pkg
ENV JULIA_VERSION=1.5.3 \
    JULIA_PATH=/usr/local/julia \
    PATH=$JULIA_PATH/bin:$PATH
COPY --from=tmp_old_pkg /usr/local /usr/local


FROM $REG/pkg-dev:$TAG AS tmp_new_pkg
ENV VER=1.6.0-beta1 \
    DST=/usr/local/julia
WORKDIR /tmp
COPY pkgs pkgs
RUN pkgs/run.sh -r ${VER} ${DST} && rm pkgs/run.sh

FROM $REG/old:$TAG AS jl_new_pkg
ENV JULIA_VERSION=1.6.0-beta1 \
    JULIA_PATH=/usr/local/julia \
    PATH=$JULIA_PATH/bin:$PATH
COPY --from=tmp_new_pkg /usr/local /usr/local


FROM $REG/pkg-dev:$TAG AS tmp_old_src
ENV VER=1.6.0-beta1 \
    DST=/usr/local/julia
WORKDIR /tmp
# COPY deps* .
# RUN chmod u+x deps.sh; ./deps.sh -b old ${DST}
COPY srcs srcs
RUN srcs/run.sh -r old ${DST} && rm srcs/run.sh

FROM $REG/old:$TAG AS jl_old_src
ENV JULIA_VERSION=1.6.0-beta1 \
    JULIA_PATH=/usr/local/julia \
    PATH=$JULIA_PATH/bin:$PATH
COPY --from=tmp_old_src /usr/local /usr/local


FROM $REG/src-dev:$TAG AS tmp_new_src
ENV VER=1.7.0-dev \
    DST=/usr/local/julia
WORKDIR /tmp
# COPY deps* .
# RUN chmod u+x deps.sh; ./deps.sh -b new ${DST}
COPY srcs srcs
RUN srcs/run.sh -r new ${DST} && rm srcs/run.sh

FROM $REG/new:$TAG AS jl_new_src
ENV JULIA_VERSION=1.7.0-dev \
    JULIA_PATH=/usr/local/julia \
    PATH=$JULIA_PATH/bin:$PATH
COPY --from=tmp_new_src /usr/local /usr/local
