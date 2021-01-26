# bazel/libs

init() {
    if [ $1 == "pull" ]; then
        if [ ! -e upstream ]; then
            mkdir upstream
            (cd upstream || exit
                git clone -q https://github.com/bazelbuild/bazel-gazelle.git gazelle
                git clone -q https://github.com/bazelbuild/bazel-skylib.git skylib
                git clone -q https://github.com/bazelbuild/rules_docker.git
                git clone -q https://github.com/bazelbuild/rules_go.git
                git clone -q https://github.com/bazelbuild/rules_k8s.git
                git clone -q https://github.com/bazelbuild/rules_rust.git
                git clone -q https://github.com/GoogleContainerTools/distroless.git
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
            git clone -qb $BZL_DISTROLESS ../upstream/distroless
            git clone -qb $BZL_GAZELLE ../upstream/gazelle
            git clone -qb $BZL_RULES_DOCKER_TAG ../upstream/rules_docker
            git clone -qb $BZL_RULES_GO_TAG ../upstream/rules_go
            git clone -qb $BZL_RULES_K8S_TAG ../upstream/rules_k8s
            git clone -qb $BZL_RULES_RUST_TAG ../upstream/rules_rust
            git clone -qb $BZL_SKYLIB ../upstream/skylib
        )
    fi
}

run() {
    echo "run"
}

clean() {
    rm -rf srcs
}
