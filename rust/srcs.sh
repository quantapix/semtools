# rust

init() {
    if [ $1 == "pull" ]; then
        [ -e upstream ] || git clone -q https://github.com/rust-lang/rust.git upstream
        (cd upstream || exit
            git branch -f qold $RUST_VER
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
    d=$2
    # cp config.toml srcs/config.toml
    ./x.py build && ./x.py install
}

clean() {
    rm -rf srcs
}
