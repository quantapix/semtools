# kubernetes/libs

init() {
    if [ $1 == "pull" ]; then
        mkdir -p upstream
        (cd upstream || exit
            [ -e minikube ] || git clone -q https://github.com/kubernetes/minikube.git
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
