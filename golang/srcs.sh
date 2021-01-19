# golang

init() {
    if [ ! -e upstream ]; then
        git clone -q https://github.com/golang/go.git upstream
    fi
    if [ $1 == "pull" ]; then
        (cd upstream || exit
            git branch -f qold go1.15.6
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
}

clean() {
    rm -rf srcs
}
