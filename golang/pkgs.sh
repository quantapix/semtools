# golang

init() {
    v=$GOLANG_VER
    fetch \
        "EB4C1BFD4F042F6DDDCCEC917721F63BD38B4796" \
        "https://storage.googleapis.com/golang" \
        "go$v.linux-amd64.tar.gz" \
		    "3918e6cc85e7eaaa6f859f1bdbaac772e7a825b0eb423c63d3ae68b21f84b844"
}

run() {
    v=$GOLANG_VER
    d=$2
    mkdir -p $d
    tar -xzf "go$v.linux-amd64.tar.gz" -C $d
}

clean() {
    rm -rf pkgs
}
