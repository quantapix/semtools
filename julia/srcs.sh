#!/bin/bash

set -eux

init() {
    if [ ! -e srcs ]; then
      	git clone https://github.com/JuliaLang/julia.git srcs
        cd srcs
        git branch qold v1.6.0-beta1
        git branch --track qnew master
    else
        cd srcs
        git checkout master
        git pull
    fi
    git checkout $1
}

build() {
  echo $(pwd)
  echo $(ls)
  cd srcs
  make -j $(nproc)
  make install prefix=$1
}

reset() {
  cd srcs
  git clean -xfd
  git reset --hard
  git checkout master
}

show_usage() {
    echo "Usage: $(basename "$0") [-i] [-b] [-r] {old|new} dst"
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
        case "$1" in
            old) init "qold";;
            new) init "qnew";;
            *) show_usage; exit 1;;
        esac
    fi
    if [[ -n "$BUILD" ]]; then
        build $2
    fi
    if [[ -n "$RESET" ]]; then
        reset
    fi
}

main "$@"
