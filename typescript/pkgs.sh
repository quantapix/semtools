# typescript

init() {
    mkdir -p pkgs
    cd pkgs
    v=v4.1.3
    fetch \
        "" \
        "https://github.com/microsoft/TypeScript/releases/download/$v" \
        "typescript-$v.tgz" \
        ""
}

run() {
    cd pkgs || exit
    mkdir -p "$2"
    tar -xzf "typescript-$v.tgz" -C "$2"
}

clean() {
    rm -rf pkgs
}
