# bazel/libs

init() {
    if [ $1 == "pull" ]; then
        mkdir -p upstream
        (cd upstream || exit
            [ -e buildtools ] || git clone -q https://github.com/bazelbuild/buildtools.git
            [ -e gazelle ] || git clone -q https://github.com/bazelbuild/bazel-gazelle.git gazelle
            [ -e rules_docker ] || git clone -q https://github.com/bazelbuild/rules_docker.git
            [ -e rules_go ] || git clone -q https://github.com/bazelbuild/rules_go.git
            [ -e rules_k8s ] || git clone -q https://github.com/bazelbuild/rules_k8s.git
            [ -e rules_pkg ] || git clone -q https://github.com/bazelbuild/rules_pkg.git
            [ -e rules_python ] || git clone -q https://github.com/bazelbuild/rules_python.git
            [ -e rules_rust ] || git clone -q https://github.com/bazelbuild/rules_rust.git
            [ -e skylib ] || git clone -q https://github.com/bazelbuild/bazel-skylib.git skylib
            [ -e toolchains ] || git clone -q https://github.com/bazelbuild/bazel-toolchains.git toolchains
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
            git clone -qb $BZL_BUILDTOOLS ../upstream/buildtools
            git clone -qb $BZL_GAZELLE ../upstream/gazelle
            git clone -qb $BZL_RULES_DOCKER_TAG ../upstream/rules_docker
            git clone -qb $BZL_RULES_GO_TAG ../upstream/rules_go
            git clone -qb $BZL_RULES_K8S_TAG ../upstream/rules_k8s
            git clone -qb $BZL_RULES_PKG_TAG ../upstream/rules_pkg
            git clone -qb $BZL_RULES_PY_TAG ../upstream/rules_python
            git clone -qb $BZL_RULES_RUST_TAG ../upstream/rules_rust
            git clone -qb $BZL_SKYLIB ../upstream/skylib
            git clone -qb $BZL_TOOLCHAINS ../upstream/toolchains
        )
    fi
}

run() {
    echo "run"
}

clean() {
    rm -rf srcs
}
