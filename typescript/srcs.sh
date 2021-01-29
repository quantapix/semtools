# typescript

init() {
    if [ $1 == "pull" ]; then
        [ -e upstream ] || git clone -q https://github.com/microsoft/TypeScript.git upstream
        (cd upstream || exit
            git branch -f qold $TS_VER
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
    v=$TS_VER
    d=$2
    yarn install -g gulp
    yarn ci
    gulp local
    gulp runtests-parallel
}

clean() {
    rm -rf srcs
}
