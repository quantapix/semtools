# pytorch

init() {
    if [ ! -e upstream ]; then
        git clone -q https://github.com/pytorch/pytorch.git upstream
    fi
    if [ $1 == "pull" ]; then
        (cd upstream || exit
            git branch -f qold v1.7.1
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
    cp config.toml srcs/config.toml
    cd srcs
    ./x.py build && ./x.py install
}

clean() {
    rm -rf srcs
}
