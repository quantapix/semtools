# bazel

init() {
    if [ ! -e upstream ]; then
        git clone -q https://github.com/bazelbuild/bazel.git upstream
    fi
    if [ $1 == "pull" ]; then
        (cd upstream || exit
            git branch -f qold 4.0.0
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
    cd srcs || exit
    export SOURCE_DATE_EPOCH=$(git log -1 --pretty=%ct)
    bazel build //src:bazel --compilation_mode=opt
    cp bazel-bin/src/bazel $2/bin/
}

clean() {
    rm -rf srcs
}
