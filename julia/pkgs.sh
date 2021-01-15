#!/bin/bash

set -eux

init() {
    mkdir -p pkgs
}

load() {
    aptMark="$(apt-mark showmanual)"
    if ! command -v gpg > /dev/null; then 
        apt-get update
        apt-get install -y --no-install-recommends gnupg dirmngr
        rm -rf /var/lib/apt/lists/*
    fi; 

    JULIA_VERSION=$1
    mkdir -p pkgs/$JULIA_VERSION
    cd pkgs/$JULIA_VERSION
    if [ ! -f julia.tar.gz ]; then
        tarArch='x86_64'; dirArch='x64'; folder="$(echo "$JULIA_VERSION" | cut -d. -f1-2)"
        curl -fL -o julia.tar.gz.asc "https://julialang-s3.julialang.org/bin/linux/${dirArch}/${folder}/julia-${JULIA_VERSION}-linux-${tarArch}.tar.gz.asc"
        curl -fL -o julia.tar.gz     "https://julialang-s3.julialang.org/bin/linux/${dirArch}/${folder}/julia-${JULIA_VERSION}-linux-${tarArch}.tar.gz"
    fi

    sha256_1='f190c938dd6fed97021953240523c9db448ec0a6760b574afd4e9924ab5615f1' # 1.5.3
    sha256_2='30b214c7f544c6589a20104eaa6764eb368cadac5fa834b7454b747043e5a2b8' # 1.6.0-beta1
    echo "${sha256_1} *julia.tar.gz" | sha256sum -c - || echo "${sha256_2} *julia.tar.gz" | sha256sum -c -

    export GNUPGHOME="$(mktemp -d)"
    JULIA_GPG=3673DF529D9049477F76B37566E3C7DC03D6E495
    gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$JULIA_GPG"
    gpg --batch --verify julia.tar.gz.asc julia.tar.gz
    command -v gpgconf > /dev/null && gpgconf --kill all
    rm -rf "$GNUPGHOME"
    # rm julia.tar.gz.asc

    JULIA_PATH=$2
    mkdir -p "$JULIA_PATH"
    tar -xzf julia.tar.gz -C "$JULIA_PATH" --strip-components 1
    # rm julia.tar.gz
      
    apt-mark auto '.*' > /dev/null
    [ -z "$aptMark" ] || apt-mark manual $aptMark
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
}

reset() {
    rm -rf pkgs/*
}

show_usage() {
    echo "Usage: $(basename "$0") [-i] [-l] [-r] ver dst"
}

main() {
    local OPTIND=1
    local INIT=
    local LOAD=
    local RESET=
    while getopts "ilrh" opt; do
              case $opt in
                  i) INIT=true;;
                  l) LOAD=true;;
                  r) RESET=true;;
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
    if [[ -n "$RESET" ]]; then
          reset
    fi
}

main "$@"
