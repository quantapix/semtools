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
         # local datestamp basever _pkgver
         # basever=$(< gcc-r${_svnrev}/gcc/BASE-VER)
         # datestamp=$(< gcc-r${_svnrev}/gcc/DATESTAMP)
         # _pkgver=${basever}-${datestamp}
         #(cd ../upstream; autoconf)
         (cd ../upstream; ln -s ../isl-0.19 isl)
         # sed -i 's@\./fixinc\.sh@-c true@' gcc/Makefile.in
         # sed -i '/m64=/s/lib64/lib/' gcc/config/i386/t-linux64
         # sed -i "/ac_cpp=/s/\$CPPFLAGS/\$CPPFLAGS -O2/" {libiberty,gcc}/configure
         # CFLAGS=${CFLAGS/-pipe/}
         # CXXFLAGS=${CXXFLAGS/-pipe/}
         ../upstream/configure --prefix=/home/qpix/clone/qtools/gcc/qpx_dest \
                               --with-bugurl=https://bugs.archlinux.org/ \
                               --enable-languages=c,c++,fortran,lto, \
                               --enable-shared \
                               --enable-threads=posix \
                               --enable-libmpx \
                               --with-system-zlib \
                               --with-isl \
                               --enable-__cxa_atexit \
                               --disable-libunwind-exceptions \
                               --enable-clocale=gnu \
                               --disable-libstdcxx-pch \
                               --disable-libssp \
                               --enable-gnu-unique-object \
                               --enable-linker-build-id \
                               --enable-lto \
                               --enable-plugin \
                               --enable-install-libiberty \
                               --with-linker-hash-style=gnu \
                               --enable-gnu-indirect-function \
                               --disable-multilib \
                               --disable-werror \
                               --enable-checking=release \
                               --enable-default-pie \
                               --enable-default-ssp \
                               --enable-cet=auto
         touch .qpx.flag
     fi
     # export CFLAGS="-march=native -O2 -fstack-protector-strong -fno-plt"
     make "-j$(nproc)"
     make -k check || true
     "$srcdir/gcc/contrib/test_summary"

     # make install
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

: <<'end_long_comment'
package_gcc-libs() {
  pkgdesc='Runtime libraries shipped by GCC'
  groups=(base)
  depends=('glibc>=2.27')
  options+=(!strip)
  provides=($pkgname-multilib libgo.so libgfortran.so libubsan.so libasan.so
            libtsan.so liblsan.so)
  replaces=($pkgname-multilib)

  cd gcc-build
  make -C $CHOST/libgcc DESTDIR="$pkgdir" install-shared
  rm -f "$pkgdir/$_libdir/libgcc_eh.a"

  for lib in libatomic \
             libgfortran \
             libgo \
             libgomp \
             libitm \
             libquadmath \
             libsanitizer/{a,l,ub,t}san \
             libstdc++-v3/src \
             libvtv; do
    make -C $CHOST/$lib DESTDIR="$pkgdir" install-toolexeclibLTLIBRARIES
  done

  make -C $CHOST/libobjc DESTDIR="$pkgdir" install-libs
  make -C $CHOST/libstdc++-v3/po DESTDIR="$pkgdir" install
  make -C $CHOST/libmpx DESTDIR="$pkgdir" install
  rm -f "$pkgdir/usr/lib/libmpx.spec"

  for lib in libgomp \
             libitm \
             libquadmath; do
    make -C $CHOST/$lib DESTDIR="$pkgdir" install-info
  done

  # remove files provided by lib32-gcc-libs
  rm -rf "$pkgdir"/usr/lib32/

  # Install Runtime Library Exception
  install -Dm644 "$srcdir/gcc/COPYING.RUNTIME" \
    "$pkgdir/usr/share/licenses/gcc-libs/RUNTIME.LIBRARY.EXCEPTION"
}

package_gcc() {
  pkgdesc="The GNU Compiler Collection - C and C++ frontends"
  depends=("gcc-libs=$pkgver-$pkgrel" 'binutils>=2.28' libmpc)
  groups=('base-devel')
  optdepends=('lib32-gcc-libs: for generating code for 32-bit ABI')
  provides=($pkgname-multilib)
  replaces=($pkgname-multilib)
  options+=(staticlibs)

  cd gcc-build

  make -C gcc DESTDIR="$pkgdir" install-driver install-cpp install-gcc-ar \
    c++.install-common install-headers install-plugin install-lto-wrapper

  install -m755 -t "$pkgdir/usr/bin/" gcc/gcov{,-tool}
  install -m755 -t "$pkgdir/${_libdir}/" gcc/{cc1,cc1plus,collect2,lto1}

  make -C $CHOST/libgcc DESTDIR="$pkgdir" install
  make -C $CHOST/32/libgcc DESTDIR="$pkgdir" install
  rm -f "$pkgdir"/usr/lib{,32}/libgcc_s.so*

  make -C $CHOST/libstdc++-v3/src DESTDIR="$pkgdir" install
  make -C $CHOST/libstdc++-v3/include DESTDIR="$pkgdir" install
  make -C $CHOST/libstdc++-v3/libsupc++ DESTDIR="$pkgdir" install
  make -C $CHOST/libstdc++-v3/python DESTDIR="$pkgdir" install
  make -C $CHOST/32/libstdc++-v3/src DESTDIR="$pkgdir" install
  make -C $CHOST/32/libstdc++-v3/include DESTDIR="$pkgdir" install
  make -C $CHOST/32/libstdc++-v3/libsupc++ DESTDIR="$pkgdir" install

  make DESTDIR="$pkgdir" install-libcc1
  install -d "$pkgdir/usr/share/gdb/auto-load/usr/lib"
  mv "$pkgdir"/usr/lib/libstdc++.so.6.*-gdb.py \
    "$pkgdir/usr/share/gdb/auto-load/usr/lib/"
  rm "$pkgdir"/usr/lib{,32}/libstdc++.so*

  make DESTDIR="$pkgdir" install-fixincludes
  make -C gcc DESTDIR="$pkgdir" install-mkheaders

  make -C lto-plugin DESTDIR="$pkgdir" install
  install -dm755 "$pkgdir"/usr/lib/bfd-plugins/
  ln -s /${_libdir}/liblto_plugin.so \
    "$pkgdir/usr/lib/bfd-plugins/"

  make -C $CHOST/libgomp DESTDIR="$pkgdir" install-nodist_{libsubinclude,toolexeclib}HEADERS
  make -C $CHOST/libitm DESTDIR="$pkgdir" install-nodist_toolexeclibHEADERS
  make -C $CHOST/libquadmath DESTDIR="$pkgdir" install-nodist_libsubincludeHEADERS
  make -C $CHOST/libsanitizer DESTDIR="$pkgdir" install-nodist_{saninclude,toolexeclib}HEADERS
  make -C $CHOST/libsanitizer/asan DESTDIR="$pkgdir" install-nodist_toolexeclibHEADERS
  make -C $CHOST/libsanitizer/tsan DESTDIR="$pkgdir" install-nodist_toolexeclibHEADERS
  make -C $CHOST/libsanitizer/lsan DESTDIR="$pkgdir" install-nodist_toolexeclibHEADERS
  make -C $CHOST/libmpx DESTDIR="$pkgdir" install-nodist_toolexeclibHEADERS
  make -C $CHOST/32/libgomp DESTDIR="$pkgdir" install-nodist_toolexeclibHEADERS
  make -C $CHOST/32/libitm DESTDIR="$pkgdir" install-nodist_toolexeclibHEADERS
  make -C $CHOST/32/libsanitizer DESTDIR="$pkgdir" install-nodist_{saninclude,toolexeclib}HEADERS
  make -C $CHOST/32/libsanitizer/asan DESTDIR="$pkgdir" install-nodist_toolexeclibHEADERS
  make -C $CHOST/32/libmpx DESTDIR="$pkgdir" install-nodist_toolexeclibHEADERS

  make -C libiberty DESTDIR="$pkgdir" install
  install -m644 libiberty/pic/libiberty.a "$pkgdir/usr/lib"

  make -C gcc DESTDIR="$pkgdir" install-man install-info
  rm "$pkgdir"/usr/share/man/man1/{gccgo,gfortran}.1
  rm "$pkgdir"/usr/share/info/{gccgo,gfortran,gnat-style,gnat_rm,gnat_ugn}.info

  make -C libcpp DESTDIR="$pkgdir" install
  make -C gcc DESTDIR="$pkgdir" install-po

  # many packages expect this symlink
  ln -s gcc "$pkgdir"/usr/bin/cc

  # POSIX conformance launcher scripts for c89 and c99
  install -Dm755 "$srcdir/c89" "$pkgdir/usr/bin/c89"
  install -Dm755 "$srcdir/c99" "$pkgdir/usr/bin/c99"

  # install the libstdc++ man pages
  make -C $CHOST/libstdc++-v3/doc DESTDIR="$pkgdir" doc-install-man

  # remove files provided by lib32-gcc-libs
  rm -f "$pkgdir"/usr/lib32/lib{stdc++,gcc_s}.so

  # byte-compile python libraries
  python -m compileall "$pkgdir/usr/share/gcc-${pkgver%%+*}/"
  python -O -m compileall "$pkgdir/usr/share/gcc-${pkgver%%+*}/"

  # Install Runtime Library Exception
  install -d "$pkgdir/usr/share/licenses/$pkgname/"
  ln -s /usr/share/licenses/gcc-libs/RUNTIME.LIBRARY.EXCEPTION \
    "$pkgdir/usr/share/licenses/$pkgname/"
}

package_gcc-fortran() {
  pkgdesc='Fortran front-end for GCC'
  depends=("gcc=$pkgver-$pkgrel")
  provides=($pkgname-multilib)
  replaces=($pkgname-multilib)

  cd gcc-build
  make -C $CHOST/libgfortran DESTDIR="$pkgdir" install-cafexeclibLTLIBRARIES \
    install-{toolexeclibDATA,nodist_fincludeHEADERS}
  make -C $CHOST/32/libgfortran DESTDIR=$pkgdir install-cafexeclibLTLIBRARIES \
    install-{toolexeclibDATA,nodist_fincludeHEADERS}
  make -C $CHOST/libgomp DESTDIR="$pkgdir" install-nodist_fincludeHEADERS
  make -C gcc DESTDIR="$pkgdir" fortran.install-{common,man,info}
  install -Dm755 gcc/f951 "$pkgdir/${_libdir}/f951"

  ln -s gfortran "$pkgdir/usr/bin/f95"

  # Install Runtime Library Exception
  install -d "$pkgdir/usr/share/licenses/$pkgname/"
  ln -s /usr/share/licenses/gcc-libs/RUNTIME.LIBRARY.EXCEPTION \
    "$pkgdir/usr/share/licenses/$pkgname/"
}
end_long_comment
