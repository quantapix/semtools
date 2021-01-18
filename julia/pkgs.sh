#!/bin/bash
set -Eeuxo pipefail

init() {
    export GNUPGHOME="$(mktemp -d)"
    GPG=3673DF529D9049477F76B37566E3C7DC03D6E495
    gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG"
    
    sha256_1='f190c938dd6fed97021953240523c9db448ec0a6760b574afd4e9924ab5615f1' # 1.5.3
    sha256_2='30b214c7f544c6589a20104eaa6764eb368cadac5fa834b7454b747043e5a2b8' # 1.6.0-beta1

    for v in 1.5.3 1.6.0-beta1; do
        mkdir -p pkgs/$v
        (cd pkgs/$v
            if [ ! -f julia.tar.gz ]; then
                t='x86_64'; d='x64'; f="$(echo "$v" | cut -d. -f1-2)"
                curl -fL -o julia.tar.gz.asc "https://julialang-s3.julialang.org/bin/linux/${d}/${f}/julia-${v}-linux-${t}.tar.gz.asc"
                curl -fL -o julia.tar.gz     "https://julialang-s3.julialang.org/bin/linux/${d}/${f}/julia-${v}-linux-${t}.tar.gz"
            fi
            gpg --batch --verify julia.tar.gz.asc julia.tar.gz || exit
            echo "${sha256_1} *julia.tar.gz" | sha256sum -c - || echo "${sha256_2} *julia.tar.gz" | sha256sum -c - || exit
        )
    done

    command -v gpgconf > /dev/null && gpgconf --kill all
    rm -rf "$GNUPGHOME"
}

load() {
    cd pkgs/$1 || exit
    DST=$2
    mkdir -p "$DST"
    tar -xzf julia.tar.gz -C "$DST" --strip-components 1
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
