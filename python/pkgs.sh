# python

init() {
    v=$PYTHON_VER
    fetch \
        "E3FF2839C048B25C084DEBE9B26995E310250568" \
        "https://www.python.org/ftp/python/$v" \
        "Python-$v.tar.xz" \
        ""
    fetch \
        "" \
        "https://github.com/pypa/get-pip/raw/5f38681f7f5872e4032860b54e9cc11cf0374932"
        "get-pip.py" \
        "6a0b13826862f33c13b614a921d36253bfa1ae779c5fbf569876f3585057e9d2"
}

run() {
    v=$PYTHON_VER
    d=$2/python
    mkdir -p $d "tmp/src"
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
    export PYTHON_PIP_VERSION 20.3.3
    python get-pip.py \
        --disable-pip-version-check \
        --no-cache-dir \
        "pip==$PYTHON_PIP_VERSION"
  	pip --version
  	find $2 -depth \
		    \( \
			      \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			      -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
		    \) -exec rm -rf '{}' +
	  ldconfig
    python3 --version
    (cd $2/bin
	      ln -s idle3 idle
	      ln -s pydoc3 pydoc
	      ln -s python3 python
	      ln -s python3-config python-config
    )
}

clean() {
    rm -rf pkgs
}
