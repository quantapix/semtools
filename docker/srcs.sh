# julia

init() {
    if [ ! -e upstream ]; then
        git clone -q https://github.com/JuliaLang/julia.git upstream
    fi
    if [ $1 == "pull" ]; then
        (cd upstream || exit
            git branch -f qold v1.6.0-beta1
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
