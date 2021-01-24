# docker

init() {
    if [ $1 == "pull" ]; then
        if [ ! -e upstream ]; then
            mkdir upstream
        fi
        (cd upstream || exit
        )
    else
        mv srcs/qpx.sh .
        rm -rf srcs
        mkdir srcs
        mv qpx.sh srcs/
    fi
}

run() {
    v=$1
    d=$2
    mkdir -p $d
}

clean() {
    rm -rf srcs
}
