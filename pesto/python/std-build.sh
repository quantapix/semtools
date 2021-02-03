#!/bin/bash
# Copyright 2018 Quantapix Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# =============================================================================

set -x -e -u -o pipefail

build() {
    if [ "$1" ]; then
        rm -rf .std.build .std.install
        (cd upstream || exit
         git reset --hard
         git clean -xfd)
    fi
    if [ ! -e .std.build ]; then
        mkdir .std.build .std.install
    fi
    (cd .std.build || exit
     if [ ! -e .qpx.flag ]; then
         (cd ../upstream; autoconf)
         # patch -Np1 -i ../bpo34056-always-return-bytes-from-_HackedGetData.get_data.patch
         # patch -p1 -i ../dont-make-libpython-readonly.patch
         # sed -i -e "s|^#.* /usr/local/bin/python|#!/usr/bin/python|" Lib/cgi.py
         # --with-system-ffi \
         ../upstream/configure --prefix=/home/qpix/clone/qtools/python/.std.install \
                               --enable-shared \
                               --with-computed-gotos \
                               --enable-optimizations \
                               --with-lto \
                               --enable-ipv6 \
                               --with-system-expat \
                               --with-dbmliborder=gdbm:ndbm \
                               --with-system-libmpdec \
                               --enable-loadable-sqlite-extensions \
                               --without-ensurepip
         touch .qpx.flag
     fi
     export CFLAGS="-march=native -O2 -fstack-protector-strong -fno-plt"
     # make "-j$(nproc)"
     make

     LD_LIBRARY_PATH="../upstream":${LD_LIBRARY_PATH}
     # "../upstream/python" -m test.regrtest -v -uall -x test_gdb -x test_idle -x test_tk -x test_ttk_guionly \
     #                      -x test_cmd_line_script -x test_compileall -x test_importlib \
     #                      -x test_multiprocessing_main_handling -x test_py_compile -x test_runpy

     # make install
    )
}

show_usage() {
    echo "Usage: $(basename "$0") [-c]"
}

main() {
    local OPTIND=1
    local CLEAR=

    while getopts "ch" opt; do
	      case $opt in
	          c) CLEAR=true;;
	          *) show_usage; return 1;;
	      esac
    done
    shift $((OPTIND-1))

	  build "$CLEAR"
}

main "$@"
