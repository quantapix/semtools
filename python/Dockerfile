# python

ARG REG
ARG TAG


FROM $REG/pkg-dev:$TAG AS tmp_pkg
ENV VER=3.9.1 \
    DST=/usr/local/python
WORKDIR /tmp
COPY pkgs pkgs
RUN pkgs/run.sh -r ${VER} ${DST} && rm pkgs/run.sh

FROM $REG/old:$TAG AS py_pkg
ENV PYTHON_VERSION=3.9.1 \
    PYTHON_PATH=/usr/local/python \
    PATH=$PYTHON_PATH/bin:$PATH
COPY --from=tmp_pkg /usr/local /usr/local


FROM $REG/pkg-dev:$TAG AS tmp_src
ENV VER=3.9.1 \
    DST=/usr/local/python
WORKDIR /tmp
COPY srcs srcs
RUN srcs/run.sh -r old ${DST} && rm srcs/run.sh

FROM $REG/old:$TAG AS py_src
ENV PYTHON_VERSION=3.9.1 \
    PYTHON_PATH=/usr/local/python \
    PATH=$PYTHON_PATH/bin:$PATH
COPY --from=tmp_src /usr/local /usr/local
