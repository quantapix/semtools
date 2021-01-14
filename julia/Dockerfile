ARG REG
ARG TAG

FROM $REG/ubu-base:$TAG AS jl_old_pkg
ENV JULIA_VERSION=1.5.3
ENV JULIA_PATH=/usr/local/julia_${JULIA_VERSION}/
ENV PATH=$JULIA_PATH/bin:$PATH
ADD pkgs pkgs
COPY pkgs.sh .
RUN ./pkgs.sh ${JULIA_VERSION}

FROM $REG/ubu-base:$TAG AS jl_new_pkg
ENV JULIA_VERSION=1.6.0-beta1
ENV JULIA_PATH=/usr/local/julia_${JULIA_VERSION}/
ENV PATH=$JULIA_PATH/bin:$PATH
ADD pkgs pkgs
COPY pkgs.sh .
RUN ./pkgs.sh ${JULIA_VERSION}

FROM $REG/ubu-dev:$TAG AS jl_old_src
ENV JULIA_VERSION=1.6.0-beta1
ENV JULIA_PATH /usr/local/julia_${JULIA_VERSION}/
ENV PATH $JULIA_PATH/bin:$PATH
ADD srcs srcs
RUN set -eux; \
  cd upstream; \
  make -j $(nproc); \
  make install prefix=${JULIA_PATH}

FROM $REG/ubu-dev:$TAG AS jl_new_src
ENV JULIA_VERSION=1.7.0
ENV JULIA_PATH /usr/local/julia_${JULIA_VERSION}/
ENV PATH $JULIA_PATH/bin:$PATH
ADD srcs srcs
RUN set -eux; \
  cd upstream; \
  make -j $(nproc); \
  make install prefix=${JULIA_PATH}
