# python

init() {
    if [ $1 == "pull" ]; then
        [ -e upstream ] || git clone -q https://github.com/python/cpython.git upstream
        (cd upstream || exit
            git branch -f qold $PYTHON_VER
            git checkout -q --track -B qnew master
            git reset -q --hard
            git clean -qxfd
            git pull -q
        )
    else
        mv srcs/qpx.sh .
        rm -rf srcs
        git clone -qb $1 ./upstream srcs
        mv qpx.sh srcs/
    fi
}

run() {
    v=$1
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
	  find $2 -depth \
        \( \
          \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
          -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
        \) -exec rm -rf '{}' + \
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
    rm -rf srcs
}
