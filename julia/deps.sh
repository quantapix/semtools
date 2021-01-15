#!/bin/bash

set -eux

init() {
    CURL_BRANCH=curl-7_73_0
    LAPACK_BRANCH=v3.9.0
    LIBGIT2_BRANCH=v1.1.0
    LIBSSH2_BRANCH=libssh2-1.9.0
    LIBUV_BRANCH=julia-uv2-1.39.0
    LIBWHICH_BRANCH=master
    OPENBLAS_BRANCH=v0.3.10 
    OPENLIBM_BRANCH=v0.7.3
    UTF8PROC_BRANCH=v2.6.1
    ZLIB_BRANCH=v1.2.11

    CLANG_JLL=Clang
    CLANG_VER=11.0.0
    CURL_JLL=LibCURL
    DSFMT_JLL=dSFMT
    DSFMT_VER=2.2.4
    GMP_JLL=GMP
    GMP_VER=6.2.0
    LIBGIT2_JLL=LibGit2
    LIBSSH2_JLL=LibSSH2
    LIBUV_JLL=LibUV
    LLVM_JLL=libLLVM
    LLVM_TOOLS_JLL=LLVM
    LLVM_VER=11.0.0
    MBEDTLS_JLL=MbedTLS
    MBEDTLS_VER=2.24.0
    MOZILLA_CACERT_VERSION=2020-10-14
    MPFR_JLL=MPFR
    MPFR_VER=4.1.0
    NGHTTP2_JLL=nghttp2
    NGHTTP2_VER=1.41.0
    OBJCONV_JLL=Objconv
    OBJCONV_VER=2.49.1
    OPENBLAS_JLL=OpenBLAS
    OPENLIBM_JLL=OpenLibm
    OSXUNWIND_JLL=LibOSXUnwind
    OSXUNWIND_VER=0.0.6
    P7ZIP_JLL=p7zip
    P7ZIP_VER=16.2.0
    PATCHELF_VER=0.9
    PCRE_JLL=PCRE2
    PCRE_VER=10.35
    SUITESPARSE_JLL=SuiteSparse
    SUITESPARSE_VER=5.4.0
    UNWIND_JLL=LibUnwind
    UNWIND_VER=1.3.2
    ZLIB_JLL=Zlib

    cd deps
    if [ ! -e upstream ]; then
        mkdir upstream
        (cd upstream
      	    git clone http://github.com/libgit2/libgit2.git
            git clone git://github.com/vtjnash/libwhich.git
            git clone https://github.com/curl/curl.git
            git clone https://github.com/JuliaLang/libuv.git
            git clone https://github.com/JuliaLang/utf8proc.git
            git clone https://github.com/JuliaMath/openlibm.git
            git clone https://github.com/libssh2/libssh2.git
            git clone https://github.com/madler/zlib.git
            git clone https://github.com/Reference-LAPACK/lapack.git
            git clone https://github.com/xianyi/OpenBLAS.git
        )
    fi
    rm -rf srcs
    if [ $1 == "pull" ]; then
        (cd upstream
          git checkout qnew
          git pull
        )
    else
        mkdir srcs
        cd srcs
        git clone -b $CURL_BRANCH --depth 1 ../upstream/curl
        git clone -b $LAPACK_BRANCH --depth 1 ../upstream/lapack
        git clone -b $LIBGIT2_BRANCH --depth 1 ../upstream/libgit2
        git clone -b $LIBSSH2_BRANCH --depth 1 ../upstream/libssh2
        git clone -b $LIBUV_BRANCH --depth 1 ../upstream/libuv
        git clone -b $LIBWHICH_BRANCH --depth 1 ../upstream/libwhich
        git clone -b $OPENBLAS_BRANCH --depth 1 ../upstream/OpenBLAS
        git clone -b $OPENLIBM_BRANCH --depth 1 ../upstream/openlibm
        git clone -b $UTF8PROC_BRANCH --depth 1 ../upstream/utf8proc
        git clone -b $ZLIB_BRANCH --depth 1 ../upstream/zlib
    fi
}

libgit2() {
  source upstream/deps/libgit2.version
  cd deps/upstream/libgit2 || (git clone http://github.com/libgit2/libgit2.git && cd deps/upstream/libgit2)
  git checkout
}

build() {

}

clean() {

}

show_usage() {
    echo "Usage: $(basename "$0") [-i] [-b] [-c] ver"
}

main() {
    local OPTIND=1
    local INIT=
    local BUILD=
    local CLEAN=
    while getopts "ibrh" opt; do
              case $opt in
                  i) INIT=true;;
                  b) BUILD=true;;
                  c) CLEAN=true;;
                  *) show_usage; return 1;;
              esac
    done
    shift $((OPTIND-1))
    if [[ -n "$INIT" ]]; then
          init
    fi
    if [[ -n "$BUILD" ]]; then
          build $1
    fi
    if [[ -n "$CLEAN" ]]; then
          clean
    fi
}

main "$@"


curl() {
    ifeq ($(USE_SYSTEM_LIBSSH2), 0)
    $(BUILDDIR)/curl-$(CURL_VER)/build-configured: | $(build_prefix)/manifest/libssh2
    endif

    ifeq ($(USE_SYSTEM_ZLIB), 0)
    $(BUILDDIR)/curl-$(CURL_VER)/build-configured: | $(build_prefix)/manifest/zlib
    endif

    ifeq ($(USE_SYSTEM_NGHTTP2), 0)
    $(BUILDDIR)/curl-$(CURL_VER)/build-configured: | $(build_prefix)/manifest/nghttp2
    endif

    CURL_LDFLAGS := $(RPATH_ESCAPED_ORIGIN)
    CURL_LDFLAGS += -lpthread

    CURL_TLS_CONFIGURE_FLAGS := --with-mbedtls=$(build_prefix)

    $(BUILDDIR)/curl-$(CURL_VER)/build-configured: $(SRCCACHE)/curl-$(CURL_VER)/source-extracted
      mkdir -p $(dir $@)
      cd $(dir $@) && \
      $(dir $<)/configure $(CONFIGURE_COMMON) --includedir=$(build_includedir) \
        --without-ssl --without-gnutls --without-gssapi --disable-ares \
        --without-libidn --without-libidn2 --without-libmetalink --without-librtmp \
        --without-nss --without-polarssl --without-spnego --without-libpsl \
        --disable-ldap --disable-ldaps --without-zsh-functions-dir --disable-static \
        --with-libssh2=$(build_prefix) --with-zlib=$(build_prefix) --with-nghttp2=$(build_prefix) \
        $(CURL_TLS_CONFIGURE_FLAGS) \
        CFLAGS="$(CFLAGS) $(CURL_CFLAGS)" LDFLAGS="$(LDFLAGS) $(CURL_LDFLAGS)"
      echo 1 > $@

    $(BUILDDIR)/curl-$(CURL_VER)/build-compiled: $(BUILDDIR)/curl-$(CURL_VER)/build-configured
      $(MAKE) -C $(dir $<) $(LIBTOOL_CCLD)
      echo 1 > $@

    $(BUILDDIR)/curl-$(CURL_VER)/build-checked: $(BUILDDIR)/curl-$(CURL_VER)/build-compiled
      $(MAKE) -C $(dir $@) check

    $(eval $(call staged-install, \
      curl,curl-$$(CURL_VER), \
      MAKE_INSTALL,$$(LIBTOOL_CCLD),, \
      $$(INSTALL_NAME_CMD)libcurl.$$(SHLIB_EXT) $$(build_shlibdir)/libcurl.$$(SHLIB_EXT)))
}

libgit2() {
    ifeq ($(USE_SYSTEM_LIBSSH2), 0)
    $(BUILDDIR)/$(LIBGIT2_SRC_DIR)/build-configured: | $(build_prefix)/manifest/libssh2
    endif

    ifeq ($(USE_SYSTEM_MBEDTLS), 0)
    $(BUILDDIR)/$(LIBGIT2_SRC_DIR)/build-configured: | $(build_prefix)/manifest/mbedtls
    endif

    LIBGIT2_OPTS := $(CMAKE_COMMON) -DCMAKE_BUILD_TYPE=Release -DTHREADSAFE=ON -DUSE_BUNDLED_ZLIB=ON
    LIBGIT2_OPTS += -DUSE_HTTPS="mbedTLS" -DSHA1_BACKEND="CollisionDetection" -DCMAKE_INSTALL_RPATH="\$$ORIGIN"
    LIBGIT2_SRC_PATH := $(SRCCACHE)/$(LIBGIT2_SRC_DIR)

    $(LIBGIT2_SRC_PATH)/libgit2-agent-nonfatal.patch-applied: $(LIBGIT2_SRC_PATH)/source-extracted
      cd $(LIBGIT2_SRC_PATH) && \
        patch -p1 -f < $(SRCDIR)/patches/libgit2-agent-nonfatal.patch
      echo 1 > $@

    $(LIBGIT2_SRC_PATH)/libgit2-mbedtls-incdir.patch-applied: $(LIBGIT2_SRC_PATH)/libgit2-agent-nonfatal.patch-applied
      cd $(LIBGIT2_SRC_PATH) && \
        patch -p1 -f < $(SRCDIR)/patches/libgit2-mbedtls-incdir.patch
      echo 1 > $@

    $(BUILDDIR)/$(LIBGIT2_SRC_DIR)/build-configured: $(LIBGIT2_SRC_PATH)/source-extracted
      mkdir -p $(dir $@)
      cd $(dir $@) && \
      $(CMAKE) $(dir $<) $(LIBGIT2_OPTS)
      echo 1 > $@

    $(BUILDDIR)/$(LIBGIT2_SRC_DIR)/build-compiled: $(BUILDDIR)/$(LIBGIT2_SRC_DIR)/build-configured
      $(MAKE) -C $(dir $<)
      echo 1 > $@

    $(BUILDDIR)/$(LIBGIT2_SRC_DIR)/build-checked: $(BUILDDIR)/$(LIBGIT2_SRC_DIR)/build-compiled
      $(MAKE) -C $(dir $@) test

    define LIBGIT2_INSTALL
    $(call MAKE_INSTALL,$1,$2,$3)
    endef

    $(eval $(call staged-install, \
      libgit2,$(LIBGIT2_SRC_DIR), \
      LIBGIT2_INSTALL,,, \
      $$(INSTALL_NAME_CMD)libgit2.$$(SHLIB_EXT) $$(build_shlibdir)/libgit2.$$(SHLIB_EXT)))
}

zlib() {
    $(BUILDDIR)/$(ZLIB_SRC_DIR)/build-configured: $(SRCCACHE)/$(ZLIB_SRC_DIR)/source-extracted
      mkdir -p $(dir $@)
      cd $(dir $@) && $(CMAKE) -DCMAKE_INSTALL_PREFIX=$(abspath $(build_prefix)) -DCMAKE_BUILD_TYPE=Release -DUNIX=true $(dir $<)
      echo 1 > $@

    $(BUILDDIR)/$(ZLIB_SRC_DIR)/build-compiled: $(BUILDDIR)/$(ZLIB_SRC_DIR)/build-configured
      $(MAKE) -C $(dir $<) $(MAKE_COMMON)
      echo 1 > $@

    $(eval $(call staged-install, \
      zlib,$(ZLIB_SRC_DIR), \
      MAKE_INSTALL,,, \
      $(INSTALL_NAME_CMD)libz.$(SHLIB_EXT) $(build_shlibdir)/libz.$(SHLIB_EXT)))
}

utf8proc() {
    UTF8PROC_OBJ_LIB    := $(build_libdir)/libutf8proc.a
    UTF8PROC_OBJ_HEADER := $(build_includedir)/utf8proc.h
    UTF8PROC_CFLAGS     := -O2
    UTF8PROC_MFLAGS     := CC="$(CC)" CFLAGS="$(CFLAGS) $(UTF8PROC_CFLAGS)" PICFLAG="$(fPIC)" AR="$(AR)"
    UTF8PROC_BUILDDIR   := $(BUILDDIR)/$(UTF8PROC_SRC_DIR)

    $(UTF8PROC_BUILDDIR)/build-compiled: $(UTF8PROC_BUILDDIR)/source-extracted
      $(MAKE) -C $(dir $<) $(UTF8PROC_MFLAGS) libutf8proc.a
      echo 1 > $@

    $(UTF8PROC_BUILDDIR)/build-checked: $(UTF8PROC_BUILDDIR)/build-compiled
    ifeq ($(OS),$(BUILD_OS))
      $(MAKE) -C $(dir $@) $(UTF8PROC_MFLAGS) check
    endif
      echo 1 > $@

    define UTF8PROC_INSTALL
      mkdir -p $2/$$(build_includedir) $2/$$(build_libdir)
      cp $1/utf8proc.h $2/$$(build_includedir)
      cp $1/libutf8proc.a $2/$$(build_libdir)
    endef
    $(eval $(call staged-install, \
      utf8proc,$(UTF8PROC_SRC_DIR), \
      UTF8PROC_INSTALL,,,))
}

openlibm() {
    OPENLIBM_FLAGS := ARCH="$(ARCH)" REAL_ARCH="$(MARCH)" CC="$(CC)" FC="$(FC)" AR="$(AR)" OS="$(OS)" USECLANG=$(USECLANG) USEGCC=$(USEGCC)
    $(BUILDDIR)/$(OPENLIBM_SRC_DIR)/build-compiled: $(BUILDDIR)/$(OPENLIBM_SRC_DIR)/source-extracted
      $(MAKE) -C $(dir $<) $(OPENLIBM_FLAGS) $(MAKE_COMMON)
      echo 1 > $@
    $(eval $(call staged-install, \
      openlibm,$$(OPENLIBM_SRC_DIR), \
      MAKE_INSTALL,$$(OPENLIBM_FLAGS),, \
      $(INSTALL_NAME_CMD)libopenlibm.$(SHLIB_EXT) $(build_shlibdir)/libopenlibm.$(SHLIB_EXT)))
}

openblas() {
    OPENBLAS_BUILD_OPTS := CC="$(CC)" FC="$(FC)" LD="$(LD)" RANLIB="$(RANLIB)" TARGET=$(OPENBLAS_TARGET_ARCH) BINARY=$(BINARY)

    ifeq ($(OPENBLAS_USE_THREAD), 1)
    OPENBLAS_BUILD_OPTS += USE_THREAD=1
    OPENBLAS_BUILD_OPTS += GEMM_MULTITHREADING_THRESHOLD=50
    OPENBLAS_BUILD_OPTS += NUM_THREADS=8
    endif

    # don't touch scheduler affinity since we manage this ourselves
    OPENBLAS_BUILD_OPTS += NO_AFFINITY=1

    # Build for all architectures - required for distribution
    ifeq ($(OPENBLAS_DYNAMIC_ARCH), 1)
    OPENBLAS_BUILD_OPTS += DYNAMIC_ARCH=1
    endif

    # 64-bit BLAS interface
    ifeq ($(USE_BLAS64), 1)
    OPENBLAS_BUILD_OPTS += INTERFACE64=1 SYMBOLSUFFIX="$(OPENBLAS_SYMBOLSUFFIX)" LIBPREFIX="libopenblas$(OPENBLAS_LIBNAMESUFFIX)"
    endif

    OPENBLAS_FFLAGS := $(JFFLAGS) $(USE_BLAS_FFLAGS)
    OPENBLAS_CFLAGS := -O2

    OPENBLAS_BUILD_OPTS += CFLAGS="$(CFLAGS) $(OPENBLAS_CFLAGS)"
    OPENBLAS_BUILD_OPTS += FFLAGS="$(FFLAGS) $(OPENBLAS_FFLAGS)"
    OPENBLAS_BUILD_OPTS += LDFLAGS="$(LDFLAGS) $(RPATH_ESCAPED_ORIGIN)"

    # Debug OpenBLAS
    ifeq ($(OPENBLAS_DEBUG), 1)
    OPENBLAS_BUILD_OPTS += DEBUG=1
    endif

    # Allow disabling AVX for older binutils
    ifeq ($(OPENBLAS_NO_AVX), 1)
    OPENBLAS_BUILD_OPTS += NO_AVX=1 NO_AVX2=1 NO_AVX512=1
    else ifeq ($(OPENBLAS_NO_AVX2), 1)
    OPENBLAS_BUILD_OPTS += NO_AVX2=1 NO_AVX512=1
    else ifeq ($(OPENBLAS_NO_AVX512), 1)
    OPENBLAS_BUILD_OPTS += NO_AVX512=1
    endif

    # Do not overwrite the "-j" flag
    OPENBLAS_BUILD_OPTS += MAKE_NB_JOBS=0

    $(BUILDDIR)/$(OPENBLAS_SRC_DIR)/openblas-winexit.patch-applied: $(BUILDDIR)/$(OPENBLAS_SRC_DIR)/source-extracted
      cd $(BUILDDIR)/$(OPENBLAS_SRC_DIR) && \
        patch -p1 -f < $(SRCDIR)/patches/openblas-winexit.patch
      echo 1 > $@

    $(BUILDDIR)/$(OPENBLAS_SRC_DIR)/openblas-ofast-power.patch-applied: $(BUILDDIR)/$(OPENBLAS_SRC_DIR)/openblas-winexit.patch-applied
      cd $(BUILDDIR)/$(OPENBLAS_SRC_DIR) && \
        patch -p1 -f < $(SRCDIR)/patches/openblas-ofast-power.patch
      echo 1 > $@

    $(BUILDDIR)/$(OPENBLAS_SRC_DIR)/build-configured: $(BUILDDIR)/$(OPENBLAS_SRC_DIR)/openblas-ofast-power.patch-applied
      echo 1 > $@

    $(BUILDDIR)/$(OPENBLAS_SRC_DIR)/build-compiled: $(BUILDDIR)/$(OPENBLAS_SRC_DIR)/build-configured
      echo $(MAKE) -C $(dir $<) $(OPENBLAS_BUILD_OPTS) # echo first, so we only print the error message below in a failure case
      @$(MAKE) -C $(dir $<) $(OPENBLAS_BUILD_OPTS) || (echo $(WARNCOLOR)"*** Clean the OpenBLAS build with 'make -C deps clean-openblas'. Rebuild with 'make OPENBLAS_USE_THREAD=0' if OpenBLAS had trouble linking libpthread.so, and with 'make OPENBLAS_TARGET_ARCH=NEHALEM' if there were errors building SandyBridge support. Both these options can also be used simultaneously. ***"$(ENDCOLOR) && false)
      echo 1 > $@

    define OPENBLAS_INSTALL
      $(call SHLIBFILE_INSTALL,$1,$2,$3)
      ln -sf libopenblas$$(OPENBLAS_LIBNAMESUFFIX).$$(SHLIB_EXT) $2/$$(build_libdir)/libopenblas$$(OPENBLAS_LIBNAMESUFFIX).$$(SHLIB_EXT).0
    endef
    $(eval $(call staged-install, \
      openblas,$(OPENBLAS_SRC_DIR), \
      OPENBLAS_INSTALL,$(BUILDDIR)/$(OPENBLAS_SRC_DIR)/$(LIBBLASNAME).$(SHLIB_EXT),, \
      $$(INSTALL_NAME_CMD)libopenblas$$(OPENBLAS_LIBNAMESUFFIX).$$(SHLIB_EXT) $$(build_shlibdir)/libopenblas$$(OPENBLAS_LIBNAMESUFFIX).$$(SHLIB_EXT)))

    LAPACK_MFLAGS := NOOPT="$(FFLAGS) $(JFFLAGS) $(USE_BLAS_FFLAGS) -O0" \
        OPTS="$(FFLAGS) $(JFFLAGS) $(USE_BLAS_FFLAGS)" FORTRAN="$(FC)" \
        LOADER="$(FC)" BLASLIB="$(RPATH_ESCAPED_ORIGIN) $(LIBBLAS)"

    $(BUILDDIR)/lapack-$(LAPACK_VER)/source-extracted: $(SRCCACHE)/lapack-$(LAPACK_VER).tgz
      $(JLCHECKSUM) $<
      mkdir -p $(BUILDDIR)
      cd $(BUILDDIR) && $(TAR) -zxf $<
      cp $(dir $@)INSTALL/make.inc.gfortran $(dir $@)make.inc
      echo 1 > $@

    ifeq ($(USE_SYSTEM_BLAS), 0)
    $(BUILDDIR)/lapack-$(LAPACK_VER)/build-compiled0: | $(build_prefix)/manifest/openblas
    endif
    $(BUILDDIR)/lapack-$(LAPACK_VER)/build-compiled0: $(BUILDDIR)/lapack-$(LAPACK_VER)/source-extracted
      $(MAKE) -C $(dir $@) lapacklib $(LAPACK_MFLAGS)
      echo 1 > $@

    $(BUILDDIR)/lapack-$(LAPACK_VER)/build-checked: $(BUILDDIR)/lapack-$(LAPACK_VER)/build-compiled0
      $(MAKE) -C $(dir $@) lapack_testing $(LAPACK_MFLAGS) -k

    $(BUILDDIR)/lapack-$(LAPACK_VER)/build-compiled: $(BUILDDIR)/lapack-$(LAPACK_VER)/build-compiled0 | $(build_prefix)/manifest
      $(FC) -shared $(FFLAGS) $(JFFLAGS) $(dir $<)/SRC/*.o \
        $(dir $<)/INSTALL/dlamch.o $(dir $<)/INSTALL/dsecnd_INT_ETIME.o \
        $(dir $<)/INSTALL/ilaver.o $(dir $<)/INSTALL/slamch.o $(LIBBLAS) \
        -o $(dir $<)/liblapack.$(SHLIB_EXT)
      echo 1 > $@

    $(eval $(call staged-install, \
      lapack,lapack-$(LAPACK_VER), \
      SHLIBFILE_INSTALL,$(BUILDDIR)/lapack-$(LAPACK_VER)/liblapack.$(SHLIB_EXT),, \
      $$(INSTALL_NAME_CMD)liblapack.$$(SHLIB_EXT) $$(build_shlibdir)/liblapack.$$(SHLIB_EXT)))
}

libssh2() {
    ifeq ($(USE_SYSTEM_MBEDTLS), 0)
    $(BUILDDIR)/$(LIBSSH2_SRC_DIR)/build-configured: | $(build_prefix)/manifest/mbedtls
    endif

    LIBSSH2_OPTS := $(CMAKE_COMMON) -DBUILD_SHARED_LIBS=ON -DBUILD_EXAMPLES=OFF \
        -DCMAKE_BUILD_TYPE=Release

    LIBSSH2_OPTS += -DCRYPTO_BACKEND=mbedTLS -DENABLE_ZLIB_COMPRESSION=OFF

    ifeq ($(LIBSSH2_ENABLE_TESTS), 0)
    LIBSSH2_OPTS += -DBUILD_TESTING=OFF
    endif

    $(BUILDDIR)/$(LIBSSH2_SRC_DIR)/build-configured: $(SRCCACHE)/$(LIBSSH2_SRC_DIR)/source-extracted
      mkdir -p $(dir $@)
      cd $(dir $@) && \
      $(CMAKE) $(dir $<) $(LIBSSH2_OPTS)
      echo 1 > $@

    $(BUILDDIR)/$(LIBSSH2_SRC_DIR)/build-compiled: $(BUILDDIR)/$(LIBSSH2_SRC_DIR)/build-configured
      $(MAKE) -C $(dir $<) libssh2
      echo 1 > $@

    $(BUILDDIR)/$(LIBSSH2_SRC_DIR)/build-checked: $(BUILDDIR)/$(LIBSSH2_SRC_DIR)/build-compiled
      $(MAKE) -C $(dir $@) test

    $(eval $(call staged-install, \
      libssh2,$(LIBSSH2_SRC_DIR), \
      MAKE_INSTALL,,, \
      $$(INSTALL_NAME_CMD)libssh2.$$(SHLIB_EXT) $$(build_shlibdir)/libssh2.$$(SHLIB_EXT)))
}

libuv() {
    UV_CFLAGS := -O2

    UV_FLAGS := LDFLAGS="$(LDFLAGS) $(CLDFLAGS) -v"
    ifneq ($(UV_CFLAGS),)
    UV_FLAGS += CFLAGS="$(CFLAGS) $(UV_CFLAGS)"
    endif

    ifneq ($(VERBOSE), 0)
    UV_MFLAGS += V=1
    endif

    LIBUV_BUILDDIR := $(BUILDDIR)/$(LIBUV_SRC_DIR)

    $(LIBUV_BUILDDIR)/build-configured: $(SRCCACHE)/$(LIBUV_SRC_DIR)/source-extracted
      touch -c $(SRCCACHE)/$(LIBUV_SRC_DIR)/aclocal.m4 # touch a few files to prevent autogen from getting called
      touch -c $(SRCCACHE)/$(LIBUV_SRC_DIR)/Makefile.in
      touch -c $(SRCCACHE)/$(LIBUV_SRC_DIR)/configure
      mkdir -p $(dir $@)
      cd $(dir $@) && \
      $(dir $<)/configure --with-pic $(CONFIGURE_COMMON) $(UV_FLAGS)
      echo 1 > $@

    $(LIBUV_BUILDDIR)/build-compiled: $(LIBUV_BUILDDIR)/build-configured
      $(MAKE) -C $(dir $<) $(UV_MFLAGS)
      echo 1 > $@

    $(LIBUV_BUILDDIR)/build-checked: $(LIBUV_BUILDDIR)/build-compiled
      $(MAKE) -C $(dir $@) check

    $(eval $(call staged-install, \
      libuv,$$(LIBUV_SRC_DIR), \
      MAKE_INSTALL,,, \
      $$(INSTALL_NAME_CMD)libuv.$$(SHLIB_EXT) $$(build_shlibdir)/libuv.$$(SHLIB_EXT)))
}

libwhich() {
    LIBWHICH_OBJ_LIB := $(build_depsbindir)/libwhich
    LIBWHICH_MFLAGS := CC="$(CC)"

    $(BUILDDIR)/$(LIBWHICH_SRC_DIR)/build-compiled: $(BUILDDIR)/$(LIBWHICH_SRC_DIR)/source-extracted
      $(MAKE) -C $(dir $<) $(LIBWHICH_MFLAGS) libwhich
      echo 1 > $@

    $(BUILDDIR)/$(LIBWHICH_SRC_DIR)/build-checked: $(BUILDDIR)/$(LIBWHICH_SRC_DIR)/build-compiled
      $(MAKE) -C $(dir $@) $(LIBWHICH_MFLAGS) check

    define LIBWHICH_INSTALL
      mkdir -p $2/$$(build_depsbindir)
      cp $1/libwhich $2/$$(build_depsbindir)
    endef
    $(eval $(call staged-install, \
      libwhich,$(LIBWHICH_SRC_DIR), \
      LIBWHICH_INSTALL,,,))
}