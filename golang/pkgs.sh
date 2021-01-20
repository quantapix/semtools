# golang

init() {
    mkdir -p pkgs
    cd pkgs
    v=1.15.6
    fetch \
        "EB4C1BFD4F042F6DDDCCEC917721F63BD38B4796" \
        "https://storage.googleapis.com/golang" \
        "go$v.linux-amd64.tar.gz" \
		    "3918e6cc85e7eaaa6f859f1bdbaac772e7a825b0eb423c63d3ae68b21f84b844"
}

run() {
    cd pkgs || exit
    mkdir -p "$2"
    tar -xzf "go$1.linux-amd64.tar.gz" -C "$2"
}

clean() {
    rm -rf pkgs
}
