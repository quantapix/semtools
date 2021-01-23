# bazel

init() {
    mkdir -p pkgs
    cd pkgs
    fetch \
        "" \
        "https://github.com/bazelbuild/bazel/releases/tag/4.0.0" \
        "bazel-4.0.0-dist.zip" \
        "d350f80e70654932db252db380d2ec0144a00e86f8d9f2b4c799ffdb48e9cdd1"
}

run() {
    cd pkgs || exit
    env EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk" bash ./compile.sh
    cp output/bazel $2/bin/
}

clean() {
    rm -rf pkgs
}
