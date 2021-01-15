ARG REG
ARG TAG

FROM $REG/ubu-base:$TAG AS tmp_old_pkg
ENV VER=1.5.3
ENV DST=/usr/local/julia/
WORKDIR /var/lib/julia
COPY pkgs pkgs
COPY pkgs.sh .
RUN chmod u+x pkgs.sh; ./pkgs.sh -l ${VER} ${DST}

FROM $REG/ubu-base:$TAG AS jl_old_pkg
ENV JULIA_VERSION=1.5.3
ENV JULIA_PATH /usr/local/julia/
ENV PATH $JULIA_PATH/bin:$PATH
COPY --from=tmp_old_pkg ${JULIA_PATH} ${JULIA_PATH}

FROM $REG/ubu-base:$TAG AS tmp_new_pkg
ENV VER=1.6.0-beta1
ENV DST=/usr/local/julia/
WORKDIR /var/lib/julia
COPY pkgs pkgs
COPY pkgs.sh .
RUN chmod u+x pkgs.sh; ./pkgs.sh -l ${VER} ${DST}

FROM $REG/ubu-base:$TAG AS jl_new_pkg
ENV JULIA_VERSION=1.6.0-beta1
ENV JULIA_PATH /usr/local/julia/
ENV PATH $JULIA_PATH/bin:$PATH
COPY --from=tmp_new_pkg ${JULIA_PATH} ${JULIA_PATH}

FROM $REG/ubu-dev:$TAG AS tmp_old_src
ENV VER=1.6.0-beta1
ENV DST /usr/local/julia/
WORKDIR /var/lib/julia
# COPY deps* .
# RUN chmod u+x deps.sh; ./deps.sh -b old ${DST}
COPY srcs srcs
COPY srcs.sh .
RUN chmod u+x srcs.sh; ./srcs.sh -b old ${DST}

FROM $REG/ubu-base:$TAG AS jl_old_src
ENV JULIA_VERSION=1.6.0-beta1
ENV JULIA_PATH /usr/local/julia/
ENV PATH $JULIA_PATH/bin:$PATH
COPY --from=tmp_old_src ${JULIA_PATH} ${JULIA_PATH}

FROM $REG/ubu-dev:$TAG AS tmp_new_src
ENV VER=1.7.0
ENV DST /usr/local/julia/
WORKDIR /var/lib/julia
# COPY deps* .
# RUN chmod u+x deps.sh; ./deps.sh -b new ${DST}
COPY srcs srcs
COPY srcs.sh .
RUN chmod u+x srcs.sh; ./srcs.sh -b new ${DST}

FROM $REG/ubu-base:$TAG AS jl_new_src
ENV JULIA_VERSION=1.7.0
ENV JULIA_PATH /usr/local/julia/
ENV PATH $JULIA_PATH/bin:$PATH
COPY --from=tmp_new_src ${JULIA_PATH} ${JULIA_PATH}
