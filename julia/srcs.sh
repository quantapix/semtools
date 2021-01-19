#!/bin/bash
set -Eeuo pipefail

init() {
    if [ ! -e upstream ]; then
        git clone -q https://github.com/JuliaLang/julia.git upstream
    fi
    if [ $1 == "pull" ]; then
        (cd upstream || exit
            git branch -f qold v1.6.0-beta1
            git checkout -q --track -B qnew master
            git reset -q --hard
            git clean -qxfd
            git pull -q
        )
    else
        rm -rf srcs
        git clone -qb $1 ./upstream srcs
    fi
}

build() {
    cd srcs
    make -j $(nproc)
    make install prefix=$1
}

clean() {
    rm -rf srcs
}

show_usage() {
    echo "Usage: $(basename "$0") [-i] [-b] [-c] {old|new|pull} dst"
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
        build $2
    fi
    if [[ -n "$CLEAN" ]]; then
        clean
    fi
}

main "$@"
