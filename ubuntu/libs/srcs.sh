# ubuntu/libs

init() {
    if [ $1 == "pull" ]; then
        if [ ! -e upstream ]; then
            mkdir upstream
            (cd upstream || exit
                git clone -q https://github.com/curl/curl.git
                git clone -q https://github.com/Kitware/CMake.git cmake
                git clone -q https://github.com/libgit2/libgit2.git
                git clone -q https://github.com/libssh2/libssh2.git
                git clone -q https://github.com/madler/zlib.git
                git clone -q https://github.com/nghttp2/nghttp2.git
                git clone -q https://github.com/ninja-build/ninja.git
                git clone -q https://github.com/vtjnash/libwhich.git
            )
        fi
        (cd upstream || exit
            for r in *; do
                (cd $r || exit; git pull -q)
            done
        )
    else
        mv srcs/qpx.sh .
        rm -rf srcs
        mkdir srcs
        mv qpx.sh srcs/
        (cd srcs
            git clone -qb $CMAKE_TAG ../upstream/cmake
            git clone -qb $CURL_TAG ../upstream/curl
            git clone -qb $LIBGIT2_TAG ../upstream/libgit2
            git clone -qb $LIBSSH2_TAG ../upstream/libssh2
            git clone -qb $LIBWHICH_TAG ../upstream/libwhich
            git clone -qb $NGHTTP2_TAG ../upstream/nghttp2
            git clone -qb $NINJA_TAG ../upstream/ninja
            git clone -qb $ZLIB_TAG ../upstream/zlib
        )
    fi
}

run() {
	  apt-get update
    apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        dpkg-dev \
        file \
        gfortran \
        libbluetooth-dev \
        libbz2-dev \
        libc6-dev \
        libexpat1-dev \
        libffi-dev \
        libgdbm-dev \
        liblzma-dev \
        libncursesw5-dev \
        libnghttp2-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        pkg-config \
        python3 \
        tk-dev \
        unzip \
        uuid-dev \
        wget \
        xz-utils
	  rm -rf /var/lib/apt/lists/*
}

clean() {
    rm -rf srcs
}
