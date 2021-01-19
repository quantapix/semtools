#!/bin/bash
set -Eeuxo pipefail

init() {
    mkdir -p pkgs
}

load() {
	  apt-get update
    apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        cmake \
        curl \
        file \
        gfortran \
        libgit2-28 \
        libgit2-dev \
        libnghttp2-dev \
        libssh2-1 \
        libssh2-1-dev\
        nghttp2 \
        ninja-build \
        pkg-config \
        python3 \
        unzip \
        wget \
        zlib1g \
        zlib1g-dev
        # imagemagick \
        # libbz2-dev \
        # libcurl4-openssl-dev \
        # libdb-dev \
        # libevent-dev \
        # libffi-dev \
        # libgdbm-dev \
        # libglib2.0-dev \
        # libgmp-dev \
        # libjpeg-dev \
        # libkrb5-dev \
        # liblzma-dev \
        # libmagickcore-dev \
        # libmagickwand-dev \
        # libmaxminddb-dev \
        # libncurses5-dev \
        # libncursesw5-dev \
        # libpng-dev \
        # libpq-dev \
        # libreadline-dev \
        # libsqlite3-dev \
        # libssl-dev \
        # libtool \
        # libwebp-dev \
        # libxml2-dev \
        # libxslt-dev \
        # libyaml-dev \
	  rm -rf /var/lib/apt/lists/*
    mkdir /var/lib/apt/lists/partial
}

clean() {
    rm -rf pkgs
}

show_usage() {
    echo "Usage: $(basename "$0") [-i] [-l] [-c]"
}

main() {
    local OPTIND=1
    local INIT=
    local LOAD=
    local CLEAN=
    while getopts "ilch" opt; do
              case $opt in
                  i) INIT=true;;
                  l) LOAD=true;;
                  c) CLEAN=true;;
                  *) show_usage; return 1;;
              esac
    done
    shift $((OPTIND-1))
    if [[ -n "$INIT" ]]; then
        init
    fi
    if [[ -n "$LOAD" ]]; then
        load
    fi
    if [[ -n "$CLEAN" ]]; then
        clean
    fi
}

main "$@"