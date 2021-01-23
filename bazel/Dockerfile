# bazel

ARG REG
ARG TAG


FROM $REG/old-dev:$TAG AS tmp_old
ENV DEBIAN_FRONTEND=noninteractive \
    VER=4.0.0 \
    DST=/usr/local
RUN set -ex; \
    apt-get update && apt-get install -y --no-install-recommends \
        openjdk-11-jdk \
        python \
        unzip \
        zip \
    ; \
    rm -rf /var/lib/apt/lists/*
WORKDIR /tmp
COPY pkgs pkgs
RUN pkgs/run.sh -r ${VER} ${DST}
COPY srcs srcs
RUN srcs/run.sh -r old ${DST}

FROM $REG/old:$TAG AS bzl_old
COPY --from=tmp_old /usr/local /usr/local


FROM $REG/new-dev:$TAG AS tmp_new
ENV DEBIAN_FRONTEND=noninteractive \
    VER=4.0.0 \
    DST=/usr/local
RUN set -ex; \
    apt-get update && apt-get install -y --no-install-recommends \
        openjdk-11-jdk \
        python \
        unzip \
        zip \
    ; \
    rm -rf /var/lib/apt/lists/*
WORKDIR /tmp
COPY pkgs pkgs
RUN pkgs/run.sh -r ${VER} ${DST}
COPY srcs srcs
RUN srcs/run.sh -r old ${DST}

FROM $REG/new:$TAG AS bzl_new
COPY --from=tmp_new /usr/local /usr/local
