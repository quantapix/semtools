# rust

ARG REG
ARG TAG
ARG DST

FROM $REG/pkg-dev:$TAG AS tmp_pkg
WORKDIR /tmp
COPY pkgs .
RUN ./qpx.sh -r "" ${DST}

FROM $REG/old:$TAG AS py_pkg
ENV RUST_VERSION=1.49.0 \
    RUSTUP_HOME=${DST}/rustup \
    CARGO_HOME=${DST}/cargo \
    PATH=${DST}/cargo/bin:$PATH
COPY --from=tmp_pkg ${DST} ${DST}


FROM $REG/pkg-dev:$TAG AS tmp_src
WORKDIR /tmp
COPY srcs .
RUN ./qpx.sh -r old ${DST}

FROM $REG/old:$TAG AS py_src
ENV RUST_VERSION=1.49.0 \
    RUSTUP_HOME=${DST}/rustup \
    CARGO_HOME=${DST}/cargo \
    PATH=${DST}/cargo/bin:$PATH
COPY --from=tmp_src ${DST} ${DST}

FROM rust:1.41.0 as build-env
WORKDIR /app
ADD . /app
RUN cargo build --release

FROM gcr.io/distroless/cc
COPY --from=build-env /app/target/release/hello-world-distroless /
CMD ["./hello-world-distroless"]
