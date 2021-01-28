# kubernetes/libs

init() {
    if [ $1 == "pull" ]; then
        if [ ! -e upstream ]; then
            mkdir upstream
            (cd upstream || exit
                git clone -q https://github.com/kubernetes/minikube.git
            )
        fi
        (cd upstream || exit
            for r in *; do
                (cd $r || exit; git pull -q)
            done
        )
    else
        mv srcs/qpx.sh .
        rm -rf srcs
        mkdir srcs
        mv qpx.sh srcs/
        (cd srcs
            git clone -qb $MINIKUBE_TAG ../upstream/minikube
        )
    fi
}

run() {
    echo "run"
}

clean() {
    rm -rf srcs
}
