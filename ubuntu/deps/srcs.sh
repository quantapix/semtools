#!/bin/bash

set -eux

init() {
    if [ ! -e upstream ]; then
        mkdir upstream
        (cd upstream
      	    git clone https://github.com/libgit2/libgit2.git
      	    git clone https://github.com/ninja-build/ninja.git
            git clone https://github.com/curl/curl.git
            git clone https://github.com/Kitware/CMake.git
            git clone https://github.com/libssh2/libssh2.git
            git clone https://github.com/madler/zlib.git
            git clone https://github.com/nghttp2/nghttp2.git
            git clone https://github.com/vtjnash/libwhich.git
        )
    fi
    if [ $1 == "pull" ]; then
        (cd upstream || exit
            for repo in *; do
                (cd "$repo" || exit; git pull)
            done
        )
    else
        rm -rf srcs
        mkdir srcs
        CMAKE_BRANCH=v3.19.3
        CURL_BRANCH=curl-7_74_0
        LIBGIT2_BRANCH=v1.1.0
        LIBSSH2_BRANCH=libssh2-1.9.0
        LIBWHICH_BRANCH=v1.1.0
        NGHTTP2_BRANCH=v1.42.0
        NINJA_BRANCH=v1.10.2
        ZLIB_BRANCH=v1.2.11
        (cd srcs
            git clone -b $CMAKE_BRANCH --depth 1 ../upstream/CMake
            git clone -b $CURL_BRANCH --depth 1 ../upstream/curl
            git clone -b $LIBGIT2_BRANCH --depth 1 ../upstream/libgit2
            git clone -b $LIBSSH2_BRANCH --depth 1 ../upstream/libssh2
            git clone -b $LIBWHICH_BRANCH --depth 1 ../upstream/libwhich
            git clone -b $NGHTTP2_BRANCH --depth 1 ../upstream/nghttp2
            git clone -b $NINJA_BRANCH --depth 1 ../upstream/ninja
            git clone -b $ZLIB_BRANCH --depth 1 ../upstream/zlib
        )
    fi
}

build() {

}

clean() {
    rm -rf srcs
}

show_usage() {
    echo "Usage: $(basename "$0") [-i {pull|srcs}] [-b DST] [-c]"
}

main() {
    local OPTIND=1
    local INIT=
    local BUILD=
    local CLEAN=
    while getopts "i:brh" opt; do
              case $opt in
                  i) INIT=$OPTARG;;
                  b) BUILD=true;;
                  c) CLEAN=true;;
                  *) show_usage; return 1;;
              esac
    done
    shift $((OPTIND-1))
    if [[ -n "$INIT" ]]; then
        init $INIT
    fi
    if [[ -n "$BUILD" ]]; then
        build
    fi
    if [[ -n "$CLEAN" ]]; then
        clean
    fi
}

main "$@"


http://archive.ubuntu.com/ubuntu/pool/restricted/n/nvidia-graphics-drivers-460/nvidia-graphics-drivers-460_460.32.03.orig-amd64.tar.gz
http://archive.ubuntu.com/ubuntu/pool/restricted/n/nvidia-graphics-drivers-460/nvidia-graphics-drivers-460_460.32.03.orig.tar.gz
http://archive.ubuntu.com/ubuntu/pool/restricted/n/nvidia-graphics-drivers-460/nvidia-graphics-drivers-460_460.32.03-0ubuntu1.debian.tar.xz