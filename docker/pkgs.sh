# docker

init() {
    mkdir -p pkgs
    cd pkgs
    v=20.10.2
    fetch \
        "3673DF529D9049477F76B37566E3C7DC03D6E495" \
        "https://download.docker.com/linux/static/stable/x86_64" \
        "docker-$v.tgz" \
        ""
}

run() {
    cd pkgs || exit
    mkdir -p "$2"/bin
	  tar -xzf docker-$1.tgz -C "$2"/bin --strip-components 1
    dockerd --version
	  docker --version
}

clean() {
    rm -rf pkgs
}
