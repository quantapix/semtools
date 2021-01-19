#!/bin/bash

set -Eeuxo pipefail

setup() {
		mkdir -p $1
		cat $2 $1.sh > $1/run.sh
		chmod u+x $1/run.sh
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
    while getopts "i:rcsh" opt; do
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
