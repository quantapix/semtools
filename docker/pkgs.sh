# docker

init() {
    v=$DOCKER_VER
    fetch \
        "3673DF529D9049477F76B37566E3C7DC03D6E495" \
        "https://download.docker.com/linux/static/stable/x86_64" \
        "docker-$v.tgz" \
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
