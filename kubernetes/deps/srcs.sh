# kubernetes

init() {
    v=$K8S_VER
    if [ $1 == "pull" ]; then
        [ -e upstream ] || git clone -q https://github.com/kubernetes/kubernetes.git upstream
        (cd upstream || exit
            git branch -f qold $v
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
    v=$K8S_VER
    d=$2/bin
    mkdir -p $d
}

clean() {
    rm -rf srcs
}
