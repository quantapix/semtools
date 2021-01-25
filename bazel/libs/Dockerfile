# bazel

ARG REG
ARG TAG
ARG DST=/usr/local

FROM $REG/old-dev:$TAG AS tmp_old
ARG DST
ENV DEBIAN_FRONTEND=noninteractive
RUN set -ex; \
    apt-get update && apt-get install -y --no-install-recommends \
        openjdk-11-jdk \
        python \
        unzip \
        zip \
    ; \
    rm -rf /var/lib/apt/lists/*
WORKDIR /tmp
COPY pkgs .
RUN ./qpx.sh -r "" ${DST}

FROM $REG/old:$TAG AS bzl_old
ARG DST
RUN set -ex; \
    apt-get update && apt-get install -y --no-install-recommends \
        g++ \
        unzip \
        zip \
    ; \
    rm -rf /var/lib/apt/lists/*
COPY --from=tmp_old ${DST} ${DST}


FROM $REG/new-dev:$TAG AS tmp_new
ARG DST
ENV DEBIAN_FRONTEND=noninteractive
RUN set -ex; \
    apt-get update && apt-get install -y --no-install-recommends \
        openjdk-11-jdk \
        python \
        unzip \
        zip \
    ; \
    rm -rf /var/lib/apt/lists/*
WORKDIR /tmp
COPY srcs .
RUN ./qpx.sh -r old ${DST}

FROM $REG/new:$TAG AS bzl_new
ARG DST
RUN set -ex; \
    apt-get update && apt-get install -y --no-install-recommends \
        g++ \
        unzip \
        zip \
    ; \
    rm -rf /var/lib/apt/lists/*
COPY --from=tmp_new ${DST} ${DST}
