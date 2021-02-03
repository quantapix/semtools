#!/bin/bash

set -x

set -e -u -o pipefail

main() {
    (cd ~/clone/qtools || exit

     (cd bazel || exit
      (cd upstream || exit
       git checkout -q master; git pull)
      (cd rules || exit
       (cd closure/upstream || exit
        git checkout -q master; git pull)
       (cd python/upstream || exit
        git checkout -q master; git pull))
      (cd skylib/upstream || exit
       git checkout -q master; git pull)
      (cd toolchains/upstream || exit
       git checkout -q master; git pull))

     (cd benchmark/upstream || exit
      git checkout -q master; git pull)
     (cd clang/upstream || exit
      git checkout -q release_70; git pull)
     (cd clang/clang-tools-extra || exit
      git checkout -q release_70; git pull)
     (cd cython/upstream || exit
      git checkout -q 0.28.x; git pull)
     (cd eigen/upstream || exit
      git checkout -q master; git pull)
     (cd flatbuffers/upstream || exit
      git checkout -q master; git pull)
     (cd gcc/upstream || exit
      git checkout -q gcc-8-branch; git pull)
     (cd googleapis/upstream || exit
      git checkout -q master; git pull)
     (cd googletest/upstream || exit
      git checkout -q master; git pull)
     (cd julia/upstream || exit
      git checkout -q master; git pull)
     (cd llvm/upstream || exit
      git checkout -q release_70; git pull)
     (cd llvm/compiler-rt || exit
      git checkout -q release_70; git pull)
     (cd mkl/upstream || exit
      git checkout -q master; git pull)
     (cd nsync/upstream || exit
      git checkout -q master; git pull)
     (cd numpy/upstream || exit
      git checkout -q maintenance/1.15.x; git pull)
     (cd nvidia/upstream || exit
      git checkout -q master; git pull)
     (cd pandas/upstream || exit
      git checkout -q 0.23.x; git pull)
     (cd protobuf/upstream || exit
      git checkout -q master; git pull)
     (cd python/upstream || exit
      git checkout -q 3.7; git pull)
     (cd tensorboard/upstream || exit
      git checkout -q master; git pull)
     (cd tensorflow/upstream || exit
      git checkout -q master; git pull)
    )
}

main "$@"
