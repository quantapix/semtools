# clang

init() {
    if [ $1 == "pull" ]; then
        if [ ! -e upstream ]; then
            git clone -q https://github.com/llvm/llvm-project.git upstream
        fi
        (cd upstream || exit
            git branch -f qold $CLANG_VER
            git checkout -q --track -B qnew main
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
    mkdir -p $d
}

clean() {
    rm -rf srcs
}
