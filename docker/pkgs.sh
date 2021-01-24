# docker

init() {
    v=$DOCKER_VER
    fetch \
        "" \
        "https://download.docker.com/linux/static/stable/x86_64" \
        "docker-$v.tgz" \
        ""
    fetch \
        "" \
        "https://download.docker.com/linux/static/stable/x86_64" \
        "docker-rootless-extras-$v.tgz" \
        ""
}

run() {
    v=$1
    d=$2/bin
    mkdir -p $d
	  tar -xzf docker-$v.tgz -C $d --strip-components 1
    dockerd --version
	  docker --version
}

clean() {
    rm -rf pkgs
}
