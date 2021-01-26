# bazel/libs

init() {
    if [ $1 == "pull" ]; then
        if [ ! -e upstream ]; then
            mkdir upstream
            (cd upstream || exit
                git clone -q https://github.com/bazelbuild/rules_docker.git
                git clone -q https://github.com/bazelbuild/rules_k8s.git
                git clone -q https://github.com/bazelbuild/rules_rust.git
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
            git clone -qb $BZL_RULES_DOCKER_TAG ../upstream/cmake
            git clone -qb $BZL_RULES_K8S_TAG ../upstream/cmake
            git clone -qb $BZL_RULES_RUST_TAG ../upstream/cmake
        )
    fi
}

run() {
    echo "run"
}

clean() {
    rm -rf srcs
}
