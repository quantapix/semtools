# bazel

init() {
    v=4.0.0
    if [ $1 == "pull" ]; then
        if [ ! -e upstream ]; then
            git clone -q https://github.com/bazelbuild/bazel.git upstream
        fi
        (cd upstream || exit
            git branch -f qold $v
            git checkout -q --track -B qnew master
            git reset -q --hard
            git clean -qxfd
            git pull -q
        )
    else
        rm -rf srcs
        git clone -qb $1 ./upstream srcs
        mkdir -p srcs/qpx
        cd srcs/qpx
        fetch \
            "" \
            "https://github.com/bazelbuild/bazel/releases/download/$v" \
            "bazel-$v-dist.zip" \
            ""
            # d350f80e70654932db252db380d2ec0144a00e86f8d9f2b4c799ffdb48e9cdd1"
    fi
}

run() {
    (cd qpx
        unzip bazel-$1-dist.zip
        env EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk" bash ./compile.sh
        cp output/bazel $2/bin/
    )
    export SOURCE_DATE_EPOCH=$(git log -1 --pretty=%ct)
    bazel build //src:bazel --compilation_mode=opt
    cp bazel-bin/src/bazel $2/bin/
}

clean() {
    rm -rf srcs
}
