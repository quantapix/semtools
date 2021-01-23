# python

ARG REG
ARG TAG


FROM $REG/pkg-dev:$TAG AS tmp_pkg
ENV VER=1.49.0 \
    DST=/usr/local/python
WORKDIR /tmp
COPY pkgs pkgs
RUN pkgs/run.sh -r ${VER} ${DST} && rm pkgs/run.sh

FROM $REG/old:$TAG AS py_pkg
ENV RUST_VERSION=1.49.0 \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH
COPY --from=tmp_pkg /usr/local /usr/local


FROM $REG/pkg-dev:$TAG AS tmp_src
ENV VER=1.49.0 \
    DST=/usr/local/python
WORKDIR /tmp
COPY srcs srcs
RUN srcs/run.sh -r old ${DST} && rm srcs/run.sh

FROM $REG/old:$TAG AS py_src
ENV RUST_VERSION=1.49.0 \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH
COPY --from=tmp_src /usr/local /usr/local
