#!/bin/bash

set -eux

init() {
    makedir -p pkgs
}

build() {

}

reset() {

}

show_usage() {
    echo "Usage: $(basename "$0") [-i] [-b] [-r] ver"
}

main() {
    local OPTIND=1
    local INIT=
    local BUILD=
    local RESET=
    while getopts "ibrh" opt; do
              case $opt in
                  i) INIT=true;;
                  b) BUILD=true;;
                  r) RESET=true;;
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
    if [[ -n "$RESET" ]]; then
          reset
    fi
}

main "$@"
