#!/bin/bash
set -Eeuo pipefail

init() {
    if [ ! -e upstream ]; then
        mkdir upstream
        (cd upstream || exit
      	    git clone -q https://github.com/libgit2/libgit2.git
      	    git clone -q https://github.com/ninja-build/ninja.git
            git clone -q https://github.com/curl/curl.git
            git clone -q https://github.com/Kitware/CMake.git cmake
            git clone -q https://github.com/libssh2/libssh2.git
            git clone -q https://github.com/madler/zlib.git
            git clone -q https://github.com/nghttp2/nghttp2.git
            git clone -q https://github.com/vtjnash/libwhich.git
        )
    fi
    if [ $1 == "pull" ]; then
        (cd upstream || exit
            for r in *; do
                (cd $r || exit; git pull -q)
            done
        )
    else
        CMAKE_BRANCH=v3.19.3
        CURL_BRANCH=curl-7_74_0
        LIBGIT2_BRANCH=v1.1.0
        LIBSSH2_BRANCH=libssh2-1.9.0
        LIBWHICH_BRANCH=v1.1.0
        NGHTTP2_BRANCH=v1.42.0
        NINJA_BRANCH=v1.10.2
        ZLIB_BRANCH=v1.2.11
        rm -rf srcs
        mkdir srcs
        (cd srcs
            git clone -qb $CMAKE_BRANCH --depth 1 ../upstream/cmake
            git clone -qb $CURL_BRANCH --depth 1 ../upstream/curl
            git clone -qb $LIBGIT2_BRANCH --depth 1 ../upstream/libgit2
            git clone -qb $LIBSSH2_BRANCH --depth 1 ../upstream/libssh2
            git clone -qb $LIBWHICH_BRANCH --depth 1 ../upstream/libwhich
            git clone -qb $NGHTTP2_BRANCH --depth 1 ../upstream/nghttp2
            git clone -qb $NINJA_BRANCH --depth 1 ../upstream/ninja
            git clone -qb $ZLIB_BRANCH --depth 1 ../upstream/zlib
        )
    fi
}

build() {
    echo "build"
}

clean() {
    rm -rf srcs
}

show_usage() {
    echo "Usage: $(basename "$0") [-i] [-b] [-c] {pull|srcs} dst"
}

main() {
    local OPTIND=1
    local INIT=
    local BUILD=
    local CLEAN=
    while getopts "ibch" opt; do
        case $opt in
            i) INIT=true;;
            b) BUILD=true;;
            c) CLEAN=true;;
            *) show_usage; return 1;;
        esac
    done
    shift $((OPTIND-1))
    if [[ -n "$INIT" ]]; then
        init $1
    fi
    if [[ -n "$BUILD" ]]; then
        build $2
    fi
    if [[ -n "$CLEAN" ]]; then
        clean
    fi
}

main "$@"
