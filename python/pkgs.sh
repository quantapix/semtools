# python

init() {
    export GNUPGHOME="$(mktemp -d)"
    GPG=E3FF2839C048B25C084DEBE9B26995E310250568
	  gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG"

    v=3.9.1
    tar="Python-$v.tar.xz"
    url="https://www.python.org/ftp/python/$v"
		sha256=
        
    mkdir -p pkgs
    (cd pkgs
        wget -qN "$url/$tar.asc"
	      wget -N --progress=dot:giga "$url/$tar" 
        gpg --batch --verify "$tar.asc" "$tar" || exit
        rm "$tar.asc"
	      [ -z sha256 ] || echo "$sha256 *$tar" | sha256sum -c - || exit
    )

    command -v gpgconf > /dev/null && gpgconf --kill all || :
    rm -rf "$GNUPGHOME"
}

run() {
    cd pkgs || exit
    mkdir -p "tmp/src"
    tar -xJf "Python-$1.tar.xz" -C "/tmp/src" --strip-components=1
    cd /tmp/src
	  ./configure \
        --build="x86_64-linux-gnu" \
        --enable-loadable-sqlite-extensions \
        --enable-optimizations \
        --enable-option-checking=fatal \
        --enable-shared \
        --with-system-expat \
        --with-system-ffi \
        --without-ensurepip
	  make -j "$(nproc)"
		LDFLAGS="-Wl,--strip-all" && make install
	  find /usr/local -depth \
        \( \
          \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
          -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
        \) -exec rm -rf '{}' + \
	  ldconfig
    python3 --version
    (cd /usr/local/bin
	      ln -s idle3 idle
	      ln -s pydoc3 pydoc
	      ln -s python3 python
	      ln -s python3-config python-config
    )
}

clean() {
    rm -rf pkgs
}

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 20.3.3
# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/5f38681f7f5872e4032860b54e9cc11cf0374932/get-pip.py
ENV PYTHON_GET_PIP_SHA256 6a0b13826862f33c13b614a921d36253bfa1ae779c5fbf569876f3585057e9d2

RUN set -ex; \
	\
	wget -O get-pip.py "$PYTHON_GET_PIP_URL"; \
	echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum --check --strict -; \
	\
	python get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==$PYTHON_PIP_VERSION" \
	; \
	pip --version; \
	\
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +; \
	rm -f get-pip.py

CMD ["python3"]
