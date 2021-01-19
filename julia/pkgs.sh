#!/bin/bash
set -Eeuxo pipefail

init() {
    export GNUPGHOME="$(mktemp -d)"
    GPG=3673DF529D9049477F76B37566E3C7DC03D6E495
    gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG"
    
    sha256_1='f190c938dd6fed97021953240523c9db448ec0a6760b574afd4e9924ab5615f1' # 1.5.3
    sha256_2='30b214c7f544c6589a20104eaa6764eb368cadac5fa834b7454b747043e5a2b8' # 1.6.0-beta1

    for v in 1.5.3 1.6.0-beta1; do
        tar="julia-$v-linux-x86_64.tar.gz"
        d="$(echo "$v" | cut -d. -f1-2)"
        url="https://julialang-s3.julialang.org/bin/linux/x64/$d"
        
        mkdir -p pkgs
        (cd pkgs
            wget -qN "$url/$tar.asc"
	          wget -N --progress=dot:giga "$url/$tar" 
            gpg --batch --verify "$tar.asc" "$tar" || exit
            echo "${sha256_1} *$tar" | sha256sum -c - || echo "${sha256_2} *$tar" | sha256sum -c - || exit
        )
    done

    command -v gpgconf > /dev/null && gpgconf --kill all
    rm -rf "$GNUPGHOME"
}

load() {
    cd pkgs || exit
    mkdir -p "$2"
    tar -xzf "julia-$1-linux-x86_64.tar.gz" -C "$2" --strip-components 1
}

clean() {
    rm -rf pkgs
}

show_usage() {
    echo "Usage: $(basename "$0") [-i] [-l] [-c] ver dst"
}

main() {
    local OPTIND=1
    local INIT=
    local LOAD=
    local CLEAN=
    while getopts "ilch" opt; do
        case $opt in
            i) INIT=true;;
            l) LOAD=true;;
            c) CLEAN=true;;
            *) show_usage; return 1;;
        esac
    done
    shift $((OPTIND-1))
    if [[ -n "$INIT" ]]; then
        init
    fi
    if [[ -n "$LOAD" ]]; then
        load $1 $2
    fi
    if [[ -n "$CLEAN" ]]; then
        clean
    fi
}

main "$@"
