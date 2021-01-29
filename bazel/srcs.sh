# bazel

init() {
    v=$BAZEL_VER
    if [ $1 == "pull" ]; then
        [ -e upstream ] || git clone -q https://github.com/bazelbuild/bazel.git upstream
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
        mkdir -p srcs/qpx
        cp pkgs/bazel-$v-dist.zip srcs/qpx/
    fi
}

run() {
    v=$BAZEL_VER
    d=$2/bin
    mkdir -p $d
    (cd qpx
        unzip bazel-$v-dist.zip
        env EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk" bash ./compile.sh
        cp output/bazel $d/
    )
    export SOURCE_DATE_EPOCH=$(git log -1 --pretty=%ct)
    bazel build //src:bazel --compilation_mode=opt
    cp bazel-bin/src/bazel $d/
}

clean() {
    rm -rf srcs
}
