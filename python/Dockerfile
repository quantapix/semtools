# python

ARG REG
ARG TAG
ARG DST

FROM $REG/pkg-dev:$TAG AS tmp_pkg
WORKDIR /tmp
COPY pkgs .
RUN ./qpx.sh -r "" ${DST}

FROM $REG/old:$TAG AS py_pkg
ENV PYTHON_VERSION=3.9.1 \
    PYTHON_PATH=${DST}/python \
    PATH=$PYTHON_PATH/bin:$PATH
COPY --from=tmp_pkg ${DST} ${DST}


FROM $REG/pkg-dev:$TAG AS tmp_src
WORKDIR /tmp
COPY srcs .
RUN ./qpx.sh -r old ${DST}

FROM $REG/old:$TAG AS py_src
ENV PYTHON_VERSION=3.9.1 \
    PYTHON_PATH=${DST}/python \
    PATH=$PYTHON_PATH/bin:$PATH
COPY --from=tmp_src ${DST} ${DST}
