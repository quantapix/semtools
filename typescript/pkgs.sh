# typescript

init() {
    v=$TS_VER
    fetch \
        "" \
        "https://github.com/microsoft/TypeScript/releases/download/$v" \
        "typescript-$(echo $v | cut -c2-).tgz" \
        ""
}

run() {
    v=$1
    d=$2
    mkdir -p $d
    tar -xzf "typescript-$v.tgz" -C $d
}

clean() {
    rm -rf pkgs
}
