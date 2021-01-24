# julia

ARG REG
ARG TAG
ARG DST=/usr/local

FROM $REG/pkg-dev:$TAG AS tmp_old_pkg
ARG DST
WORKDIR /tmp
COPY pkgs .
RUN ./qpx.sh -r old ${DST}

FROM $REG/old:$TAG AS jl_old_pkg
ARG DST
ENV JULIA_PATH=${DST}/julia \
    PATH=$JULIA_PATH/bin:$PATH
COPY --from=tmp_old_pkg ${DST} ${DST}


FROM $REG/pkg-dev:$TAG AS tmp_new_pkg
ARG DST
WORKDIR /tmp
COPY pkgs .
RUN ./qpx.sh -r new ${DST}

FROM $REG/old:$TAG AS jl_new_pkg
ARG DST
ENV JULIA_PATH=${DST}/julia \
    PATH=$JULIA_PATH/bin:$PATH
COPY --from=tmp_new_pkg ${DST} ${DST}


FROM $REG/pkg-dev:$TAG AS tmp_old_src
ARG DST
WORKDIR /tmp
# COPY deps* .
# RUN chmod u+x deps.sh; ./deps.sh -b old ${DST}
COPY srcs .
RUN ./qpx.sh -r old ${DST}

FROM $REG/old:$TAG AS jl_old_src
ARG DST
ENV JULIA_PATH=${DST}/julia \
    PATH=$JULIA_PATH/bin:$PATH
COPY --from=tmp_old_src ${DST} ${DST}


FROM $REG/src-dev:$TAG AS tmp_new_src
ARG DST
WORKDIR /tmp
# COPY deps* .
# RUN chmod u+x deps.sh; ./deps.sh -b new ${DST}
COPY srcs .
RUN ./qpx.sh -r new ${DST}

FROM $REG/new:$TAG AS jl_new_src
ARG DST
ENV JULIA_PATH=${DST}/julia \
    PATH=$JULIA_PATH/bin:$PATH
COPY --from=tmp_new_src ${DST} ${DST}
