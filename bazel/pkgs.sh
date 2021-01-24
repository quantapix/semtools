# bazel

init() {
    v=4.0.0
    fetch \
        "" \
        "https://github.com/bazelbuild/bazel/releases/download/$v" \
        "bazel-$v-installer-linux-x86_64.sh" \
        ""
        # "bd7a3a583a18640f58308c26e654239d412adaa833b6b6a7b57a216ab62fabc2"
}

run() {
    chmod u+x bazel-$1-installer-linux-x86_64.sh
    ./bazel-$1-installer-linux-x86_64.sh --prefix=$2
}

clean() {
    rm -rf pkgs
}
