#!/bin/bash
set -Eeuxo pipefail

init() {
    mkdir -p pkgs
}

load() {
    echo "load"
}

clean() {
    rm -rf pkgs
}

show_usage() {
    echo "Usage: $(basename "$0") [-i] [-l] [-c]"
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
        load
    fi
    if [[ -n "$CLEAN" ]]; then
        clean
    fi
}

main "$@"
