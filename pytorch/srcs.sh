# pytorch

init() {
    if [ $1 == "pull" ]; then
        if [ ! -e upstream ]; then
            git clone -q https://github.com/pytorch/pytorch.git upstream
        fi
        (cd upstream || exit
            git branch -f qold $PYTORCH_VER
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
    echo "run"
}

clean() {
    rm -rf srcs
}
