# python

init() {
    if [ ! -e upstream ]; then
        git clone -q https://github.com/python/cpython.git upstream
    fi
    if [ $1 == "pull" ]; then
        (cd upstream || exit
            git branch -f qold v3.9.1
            git checkout -q --track -B qnew master
            git reset -q --hard
            git clean -qxfd
            git pull -q
        )
    else
        rm -rf srcs
        git clone -qb $1 ./upstream srcs
    fi
}

run() {
    cd srcs
    make -j $(nproc)
    make install prefix=$2
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
    rm -rf srcs
}
