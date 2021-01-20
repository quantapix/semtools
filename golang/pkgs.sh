# golang

init() {
    export GNUPGHOME="$(mktemp -d)"
    GPG=EB4C1BFD4F042F6DDDCCEC917721F63BD38B4796
	  gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG"

    v=1.15.6
    tar="go$v.linux-amd64.tar.gz"
    url="https://storage.googleapis.com/golang"
		sha256="3918e6cc85e7eaaa6f859f1bdbaac772e7a825b0eb423c63d3ae68b21f84b844"
        
    mkdir -p pkgs
    (cd pkgs
        wget -qN "$url/$tar.asc"
	      wget -N --progress=dot:giga "$url/$tar" 
        gpg --batch --verify "$tar.asc" "$tar" || exit
        rm "$tar.asc"
	      echo "$sha256 *$tar" | sha256sum -c - || exit
    )

    command -v gpgconf > /dev/null && gpgconf --kill all || :
    rm -rf "$GNUPGHOME"
}

run() {
    cd pkgs || exit
    mkdir -p "$2"
    tar -xzf "go$1.linux-amd64.tar.gz" -C "$2"
}

clean() {
    rm -rf pkgs
}
