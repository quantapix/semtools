#!/bin/bash

set -x

set -e -u -o pipefail

# diff -ura BUILD BUILD.new > BUILD.qpx.patch

build() {
    (cd ~/clone/qtools || exit
     if [ "$2" ]; then
         bazel clean --expunge
         rm -rf ~/.cache/bazel
     elif [ "$1" ]; then
         bazel clean
     fi
     # cp -r numpy/patches/* numpy/upstream/
     # bazel build @org_numpy//:setup
     # bazel build @org_cython//:cython
     # bazel build @org_python//Objects
     # bazel build @org_python//:Modules
     # bazel build @com_google_protobuf//:protoc
     bazel build @org_tensorflow//tensorflow/tools/pip_package:build_pip_package
    )
}

show_usage() {
    echo "Usage: $(basename "$0") [-c] [-x]"
}

main() {
    local OPTIND=1
    local CLEAN=
    local EXPUNGE=

    while getopts "cxh" opt; do
	      case $opt in
	          c) CLEAN=true;;
	          x) EXPUNGE=true;;
	          *) show_usage; return 1;;
	      esac
    done
    shift $((OPTIND-1))

	  build "$CLEAN" "$EXPUNGE"
}

main "$@"
