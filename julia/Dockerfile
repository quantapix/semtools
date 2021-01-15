ARG REG
ARG TAG

FROM $REG/ubu-base:$TAG AS jl_old_pkg
ENV JULIA_VERSION=1.5.3
ENV JULIA_PATH=/usr/local/julia_${JULIA_VERSION}/
ENV PATH=$JULIA_PATH/bin:$PATH
WORKDIR /var/lib/julia
COPY pkgs* .
RUN chmod u+x pkgs.sh; ./pkgs.sh -l ${JULIA_VERSION}

FROM $REG/ubu-base:$TAG AS jl_new_pkg
ENV JULIA_VERSION=1.6.0-beta1
ENV JULIA_PATH=/usr/local/julia_${JULIA_VERSION}/
ENV PATH=$JULIA_PATH/bin:$PATH
WORKDIR /var/lib/julia
COPY pkgs* .
RUN chmod u+x pkgs.sh; ./pkgs.sh -l ${JULIA_VERSION}

FROM $REG/ubu-dev:$TAG AS tmp_old_src
ENV JULIA_VERSION=1.6.0-beta1
ENV JULIA_PATH /usr/local/julia_${JULIA_VERSION}/
WORKDIR /var/lib/julia
# COPY deps* .
# RUN chmod u+x deps.sh; ./deps.sh -b old ${JULIA_PATH}
COPY srcs* .
RUN chmod u+x srcs.sh; ./srcs.sh -b old ${JULIA_PATH}

FROM $REG/ubu-base:$TAG AS jl_old_src
ENV JULIA_VERSION=1.6.0-beta1
ENV JULIA_PATH /usr/local/julia_${JULIA_VERSION}/
ENV PATH $JULIA_PATH/bin:$PATH
COPY --from=tmp_old_src ${JULIA_PATH} ${JULIA_PATH}

FROM $REG/ubu-dev:$TAG AS tmp_new_src
ENV JULIA_VERSION=1.7.0
ENV JULIA_PATH /usr/local/julia_${JULIA_VERSION}/
WORKDIR /var/lib/julia
# COPY deps* .
# RUN chmod u+x deps.sh; ./deps.sh -b new ${JULIA_PATH}
COPY srcs* .
RUN chmod u+x srcs.sh; ./srcs.sh -b new ${JULIA_PATH}

FROM $REG/ubu-base:$TAG AS jl_new_src
ENV JULIA_VERSION=1.7.0
ENV JULIA_PATH /usr/local/julia_${JULIA_VERSION}/
ENV PATH $JULIA_PATH/bin:$PATH
COPY --from=tmp_new_src ${JULIA_PATH} ${JULIA_PATH}
