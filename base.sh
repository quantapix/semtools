#!/bin/bash

set -Eeuxo pipefail

setup() {
		mkdir -p $1
    cat $(dirname $2)/conf.sh $1.sh $2 > $1/qpx.sh
		chmod u+x $1/qpx.sh
}

fetch() {
    key="$1"
    url="$2"
    tar="$3"
    asc="$tar.asc"
    sha="$4"
    if [ -z $sha ] && [ -e $tar ] || echo "$sha *$tar" | sha256sum -c -; then
        rm $tar
    else
	      wget --progress=dot:giga "$url/$tar" 
        if [ ! -z $key ]; then
            export GNUPGHOME="$(mktemp -d)"
            gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"
            wget -q "$url/$asc"
            gpg --batch --verify $asc $tar || exit
            command -v gpgconf > /dev/null && gpgconf --kill all || :
            rm -rf "$GNUPGHOME" $asc
        fi
	      [ -z $sha ] || echo "$sha *$tar" | sha256sum -c - || exit
    fi
}

show_usage() {
    echo "Usage: $(basename "$0") [-i {pkgs|srcs|pull|old|new}] [-r] [-c] [-s {pkgs|srcs}] args..."
}

main() {
    local OPTIND=1
    local INIT=
    local RUN=
    local CLEAN=
    local SETUP=
    while getopts "i:rcs:h" opt; do
        case $opt in
            i) INIT=$OPTARG;;
            r) RUN=true;;
            c) CLEAN=true;;
            s) SETUP=$OPTARG;;
            *) show_usage; return 1;;
        esac
    done
    shift $((OPTIND-1))
    if [[ -n "$INIT" ]]; then
        case "$INIT" in
            pkgs) init;;
            srcs) init "srcs";;
            pull) init "pull";;
            old) init "qold";;
            new) init "qnew";;
            *) show_usage; exit 1;;
        esac
    fi
    if [[ -n "$RUN" ]]; then
        run "$@"
    fi
    if [[ -n "$CLEAN" ]]; then
        clean
    fi
    if [[ -n "$SETUP" ]]; then
        case "$SETUP" in
            pkgs) setup "pkgs" "$0";;
            srcs) setup "srcs" "$0";;
            *) show_usage; exit 1;;
        esac
    fi

}

main "$@"

