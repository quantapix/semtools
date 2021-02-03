#!/bin/bash

set -x

set -e -u -o pipefail


qpx_build() {
    if [ "$1" ]; then
        rm -rf qpx_work qpx_dest
    fi
    if [ ! -e qpx_work ]; then
        mkdir qpx_work qpx_dest
    fi
    (cd upstream || exit
     git reset --hard
     git clean -xfd
     (cd tools || exit
      ln -s ../../../clang/upstream clang)
     (cd projects || exit
      ln -s ../../compiler-rt .))
    (cd ../clang/upstream || exit
     git reset --hard
     git clean -xfd
     (cd tools || exit
      ln -s ../../clang-tools-extra .))
    (cd ../clang/clang-tools-extra || exit
      git reset --hard
      git clean -xfd)
    (cd compiler-rt || exit
     git reset --hard
     git clean -xfd)
    (cd qpx_work || exit
     if [ ! -e .qpx.flag ]; then
         # patch -Np1 -i ../enable-SSP-and-PIE-by-default.patch
         # -DLLVM_BINUTILS_INCDIR=/home/qpix/clone/qtools/llvm/qpx_dest/include
         cmake ../upstream -G Ninja \
               -DCMAKE_BUILD_TYPE=Release \
               -DCMAKE_INSTALL_PREFIX=/home/qpix/clone/qtools/llvm/qpx_dest \
               -DPYTHON_EXECUTABLE=/usr/bin/python \
               -DLLVM_HOST_TRIPLE="x86_64-unknown-linux_gnu" \
               -DBUILD_SHARED_LIBS=ON \
               -DLLVM_BUILD_LLVM_DYLIB=ON \
               -DLLVM_LINK_LLVM_DYLIB=ON \
               -DLLVM_INSTALL_UTILS=ON \
               -DLLVM_ENABLE_RTTI=ON \
               -DLLVM_ENABLE_FFI=ON \
               -DFFI_INCLUDE_DIR=$(pkg-config --variable=includedir libffi) \
               -DLLVM_EXTERNAL_LIT=/usr/bin/lit \
               -DLLVM_BUILD_TESTS=ON
         touch .qpx.flag
     fi
     ninja
     # ninja check
     ninja check-clang{,-tools}
     ninja install
    )
}

show_usage() {
    echo "Usage: $(basename "$0") [-c]"
}

main() {
    local OPTIND=1
    local CFG=

    while getopts "ch" opt; do
	      case $opt in
	          c) CFG=true;;
	          *) show_usage; return 1;;
	      esac
    done
    shift $((OPTIND-1))

	  qpx_build "$CFG"
}

main "$@"
