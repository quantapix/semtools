#!/bin/bash

set -x

set -e -u -o pipefail

main() {
    (cd ~/clone/qtools || exit
     # cp -r numpy/patches/* numpy/upstream/
     bazel test @com_google_protobuf//:protobuf_test
    )
}

main "$@"
