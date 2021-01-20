# ubuntu/libs

init() {
    mkdir -p pkgs
}

run() {
	  apt-get update
    apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        cmake \
        curl \
        dpkg-dev \
        file \
        gfortran \
        libbluetooth-dev \
        libbz2-dev \
        libc6-dev \
        libexpat1-dev \
        libffi-dev \
        libgdbm-dev \
        libgit2-28 \
        libgit2-dev \
        liblzma-dev \
        libncursesw5-dev \
        libnghttp2-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssh2-1 \
        libssh2-1-dev\
        libssl-dev \
        nghttp2 \
        ninja-build \
        pkg-config \
        python3 \
        tk-dev \
        unzip \
        uuid-dev \
        wget \
        xz-utils \
        zlib1g \
        zlib1g-dev \
        
        # imagemagick \
        # libcurl4-openssl-dev \
        # libdb-dev \
        # libevent-dev \
        # libglib2.0-dev \
        # libgmp-dev \
        # libjpeg-dev \
        # libkrb5-dev \
        # libmagickcore-dev \
        # libmagickwand-dev \
        # libmaxminddb-dev \
        # libncurses5-dev \
        # libncursesw5-dev \
        # libpng-dev \
        # libpq-dev \
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
