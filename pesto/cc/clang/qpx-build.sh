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
     git clean -xfd)
    (cd qpx_work || exit
     if [ ! -e .qpx.flag ]; then
         # patch -Np1 -i ../enable-SSP-and-PIE-by-default.patch
         ln -s ../../llvm/upstream llvm
         touch .qpx.flag
     fi
     cmake ../upstream -G Ninja \
           -DCMAKE_BUILD_TYPE=Release \
           -DCMAKE_INSTALL_PREFIX=/home/qpix/clone/qtools/clang/qpx_dest \
           -DPYTHON_EXECUTABLE=/usr/bin/python \
           -DBUILD_SHARED_LIBS=ON \
           -DLLVM_LINK_LLVM_DYLIB=ON \
           -DLLVM_ENABLE_RTTI=ON \
           -DLLVM_BUILD_TESTS=ON \
           -DLLVM_INCLUDE_DOCS=ON \
           -DLLVM_BUILD_DOCS=ON \
           -DLLVM_ENABLE_SPHINX=ON \
           -DSPHINX_WARNINGS_AS_ERRORS=OFF \
           -DLLVM_EXTERNAL_LIT=/usr/bin/lit \
           -DLLVM_MAIN_SRC_DIR=llvm
     ninja
     ninja check-clang{,-tools}
     ninja install
     for _py in 2.7 3.7; do
         install -d "$pkgdir/usr/lib/python$_py/site-packages"
         cp -a ../bindings/python/clang "$pkgdir/usr/lib/python$_py/site-packages/"
         _python${_py%%.*}_optimize "$pkgdir/usr/lib/python$_py"
     done
    )
}

show_usage() {
    echo "Usage: $(basename "$0") [-c] [-g]"
}

main() {
    local OPTIND=1
    local CFG=
    local GPU=

    while getopts "cgh" opt; do
	      case $opt in
	          c) CFG=true;;
	          g) GPU=true;;
	          *) show_usage; return 1;;
	      esac
    done
    shift $((OPTIND-1))

	  qpx_build "$CFG" "$GPU"
}

main "$@"
