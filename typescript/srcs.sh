# typescript

init() {
    if [ ! -e upstream ]; then
        git clone -q https://github.com/microsoft/TypeScript.git upstream
    fi
    if [ $1 == "pull" ]; then
        (cd upstream || exit
            git branch -f qold v4.1.3
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
    yarn install -g gulp
    yarn ci
    gulp local
    gulp runtests-parallel
}

clean() {
    rm -rf srcs
}
