#!/bin/bash
set -Eeuo pipefail

init() {
	  mkdir -p srcs
}

build() {
    echo "build"
}

clean() {
    rm -rf srcs
}

show_usage() {
    echo "Usage: $(basename "$0") [-i] [-b] [-c] {old|new|pull}"
}

main() {
    local OPTIND=1
    local INIT=
    local BUILD=
    local CLEAN=
    while getopts "ibch" opt; do
        case $opt in
            i) INIT=true;;
            b) BUILD=true;;
            c) CLEAN=true;;
            *) show_usage; return 1;;
        esac
    done
    shift $((OPTIND-1))
    if [[ -n "$INIT" ]]; then
        case "$1" in
            old) init "qold";;
            new) init "qnew";;
            pull) init $1;;
            *) show_usage; exit 1;;
        esac
    fi
    if [[ -n "$BUILD" ]]; then
        build
    fi
    if [[ -n "$CLEAN" ]]; then
        clean
    fi
}

main "$@"
