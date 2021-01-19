#!/bin/bash
set -Eeuo pipefail

# ubuntu/libs

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
            git clone -qb $CMAKE_BRANCH ../upstream/cmake
            git clone -qb $CURL_BRANCH ../upstream/curl
            git clone -qb $LIBGIT2_BRANCH ../upstream/libgit2
            git clone -qb $LIBSSH2_BRANCH ../upstream/libssh2
            git clone -qb $LIBWHICH_BRANCH ../upstream/libwhich
            git clone -qb $NGHTTP2_BRANCH ../upstream/nghttp2
            git clone -qb $NINJA_BRANCH ../upstream/ninja
            git clone -qb $ZLIB_BRANCH ../upstream/zlib
        )
    fi
}

run() {
    echo "run"
}

clean() {
    rm -rf srcs
}
