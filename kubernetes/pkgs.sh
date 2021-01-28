# kubernetes

init() {
    v=$K8S_VER
    url="https://dl.k8s.io/$v"
    fetch \
        "" \
        $url \
        "kubernetes.tar.gz" \
        ""
}

run() {
    v=$K8S_VER
    d=$2
    mkdir -p $d
}

clean() {
    rm -rf pkgs
}
