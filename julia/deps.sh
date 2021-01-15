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
    local LOAD=
    local RESET=
    while getopts "ilrh" opt; do
              case $opt in
                  l) INIT=true;;
                  o) LOAD=true;;
                  r) RESET=true;;
                  *) show_usage; return 1;;
              esac
    done
    shift $((OPTIND-1))
    if [[ -n "$INIT" ]]; then
          init
    fi
    if [[ -n "$LOAD" ]]; then
          build $1
    fi
    if [[ -n "$RESET" ]]; then
          reset
    fi
}

main "$@"
