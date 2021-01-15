#!/bin/bash

set -eux

init() {
    makedir -p pkgs
}

build() {

}

clean() {

}

show_usage() {
    echo "Usage: $(basename "$0") [-i] [-b] [-c] ver"
}

main() {
    local OPTIND=1
    local INIT=
    local BUILD=
    local CLEAN=
    while getopts "ibrh" opt; do
              case $opt in
                  i) INIT=true;;
                  b) BUILD=true;;
                  c) CLEAN=true;;
                  *) show_usage; return 1;;
              esac
    done
    shift $((OPTIND-1))
    if [[ -n "$INIT" ]]; then
          init
    fi
    if [[ -n "$BUILD" ]]; then
          build $1
    fi
    if [[ -n "$CLEAN" ]]; then
          clean
    fi
}

main "$@"
