#!/bin/bash

set -eux

init() {
    NINJA_BRANCH=v1.10.2

    cd deps
    if [ ! -e upstream ]; then
        mkdir upstream
        (cd upstream
      	    git clone https://github.com/ninja-build/ninja.git
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
        git clone -b $NINJA_BRANCH --depth 1 ../upstream/ninja
    fi
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

unwind() {
    LIBUNWIND_CFLAGS := -U_FORTIFY_SOURCE $(fPIC)
    LIBUNWIND_CPPFLAGS :=

    $(SRCCACHE)/libunwind-$(UNWIND_VER)/source-extracted: $(SRCCACHE)/libunwind-$(UNWIND_VER).tar.gz
      $(JLCHECKSUM) $<
      cd $(dir $<) && $(TAR) xfz $<
      touch -c $(SRCCACHE)/libunwind-$(UNWIND_VER)/configure # old target
      echo 1 > $@

    $(SRCCACHE)/libunwind-$(UNWIND_VER)/libunwind-prefer-extbl.patch-applied: $(SRCCACHE)/libunwind-$(UNWIND_VER)/source-extracted
      cd $(SRCCACHE)/libunwind-$(UNWIND_VER) && patch -p1 -f < $(SRCDIR)/patches/libunwind-prefer-extbl.patch
      echo 1 > $@

    $(SRCCACHE)/libunwind-$(UNWIND_VER)/libunwind-static-arm.patch-applied: $(SRCCACHE)/libunwind-$(UNWIND_VER)/libunwind-prefer-extbl.patch-applied
      cd $(SRCCACHE)/libunwind-$(UNWIND_VER) && patch -p1 -f < $(SRCDIR)/patches/libunwind-static-arm.patch
      echo 1 > $@

    $(BUILDDIR)/libunwind-$(UNWIND_VER)/build-configured: $(SRCCACHE)/libunwind-$(UNWIND_VER)/source-extracted $(SRCCACHE)/libunwind-$(UNWIND_VER)/libunwind-static-arm.patch-applied
      mkdir -p $(dir $@)
      cd $(dir $@) && \
      $(dir $<)/configure $(CONFIGURE_COMMON) CPPFLAGS="$(CPPFLAGS) $(LIBUNWIND_CPPFLAGS)" CFLAGS="$(CFLAGS) $(LIBUNWIND_CFLAGS)" --disable-shared --disable-minidebuginfo --disable-tests
      echo 1 > $@

    $(BUILDDIR)/libunwind-$(UNWIND_VER)/build-compiled: $(BUILDDIR)/libunwind-$(UNWIND_VER)/build-configured
      $(MAKE) -C $(dir $<)
      echo 1 > $@

    $(BUILDDIR)/libunwind-$(UNWIND_VER)/build-checked: $(BUILDDIR)/libunwind-$(UNWIND_VER)/build-compiled
      $(MAKE) -C $(dir $@) check

    $(eval $(call staged-install, \
      unwind,libunwind-$(UNWIND_VER), \
      MAKE_INSTALL,,,))
}

csl() {
    STD_LIB_PATH := $(shell LANG=C $(FC) -print-search-dirs | grep '^programs: =' | sed -e "s/^programs: =//")
    STD_LIB_PATH += :$(shell LANG=C $(FC) -print-search-dirs | grep '^libraries: =' | sed -e "s/^libraries: =//")

    define pathsearch
    $(firstword $(wildcard $(addsuffix /$(1),$(subst :, ,$(2)))))
    endef

    define copy_csl
    install-csl: | $$(build_shlibdir) $$(build_shlibdir)/$(1)
    $$(build_shlibdir)/$(1): | $$(build_shlibdir)
      -@SRC_LIB=$$(call pathsearch,$(1),$$(STD_LIB_PATH)); \
      [ -n "$$$${SRC_LIB}" ] && cp $$$${SRC_LIB} $$(build_shlibdir)
    endef

    define gen_libname
    $$(if $(2),lib$(1).$(SHLIB_EXT).$(2),lib$(1).$(SHLIB_EXT))
    endef

    $(eval $(call copy_csl,$(call gen_libname,gfortran,3)))
    $(eval $(call copy_csl,$(call gen_libname,gfortran,4)))
    $(eval $(call copy_csl,$(call gen_libname,gfortran,5)))

    $(eval $(call copy_csl,$(call gen_libname,quadmath,0)))
    $(eval $(call copy_csl,$(call gen_libname,stdc++,6)))
    $(eval $(call copy_csl,$(call gen_libname,ssp,0)))
    $(eval $(call copy_csl,$(call gen_libname,atomic,1)))
    $(eval $(call copy_csl,$(call gen_libname,gomp,1)))

    $(eval $(call copy_csl,$(call gen_libname,gcc_s,1)))
    $(eval $(call copy_csl,$(call gen_libname,pthread,0)))
}

dsfmt() {
    DSFMT_CFLAGS := $(CFLAGS) -DNDEBUG -DDSFMT_MEXP=19937 $(fPIC) -DDSFMT_DO_NOT_USE_OLD_NAMES -DDSFMT_SHLIB
    DSFMT_CFLAGS += -O3 -finline-functions -fomit-frame-pointer -fno-strict-aliasing \
        --param max-inline-insns-single=1800 -Wall  -std=c99 -shared
    DSFMT_CFLAGS += -msse2 -DHAVE_SSE2

    $(BUILDDIR)/dsfmt-$(DSFMT_VER)/source-extracted: $(SRCCACHE)/dsfmt-$(DSFMT_VER).tar.gz
      $(JLCHECKSUM) $<
      -rm -r $(dir $@)
      mkdir -p $(dir $@)
      $(TAR) -C $(dir $@) --strip-components 1 -xf $<
      echo 1 > $@

    $(BUILDDIR)/dsfmt-$(DSFMT_VER)/build-compiled: $(BUILDDIR)/dsfmt-$(DSFMT_VER)/source-extracted
      cd $(dir $<) && \
      $(CC) $(CPPFLAGS) $(DSFMT_CFLAGS) $(LDFLAGS) dSFMT.c -o libdSFMT.$(SHLIB_EXT)
      echo 1 > $@

    $(BUILDDIR)/dsfmt-$(DSFMT_VER)/build-checked: $(BUILDDIR)/dsfmt-$(DSFMT_VER)/build-compiled
      $(MAKE) -C $(dir $@) std-check sse2-check

    define DSFMT_INSTALL
      mkdir -p $2/$$(build_includedir)
      mkdir -p $2/$$(build_shlibdir)
      cp $1/dSFMT.h $2/$$(build_includedir)
      cp $1/libdSFMT.$$(SHLIB_EXT) $2/$$(build_shlibdir)
    endef
    $(eval $(call staged-install, \
      dsfmt,dsfmt-$(DSFMT_VER), \
      DSFMT_INSTALL,, \
      $$(DSFMT_OBJ_TARGET), \
      $$(INSTALL_NAME_CMD)libdSFMT.$$(SHLIB_EXT) $$(build_shlibdir)/libdSFMT.$$(SHLIB_EXT)))
}

gmp() {
    ifeq ($(SANITIZE),1)
    GMP_CONFIGURE_OPTS += --disable-assembly
    endif

    $(SRCCACHE)/gmp-$(GMP_VER).tar.bz2: | $(SRCCACHE)
      $(JLDOWNLOAD) $@ https://gmplib.org/download/gmp/$(notdir $@)

    $(SRCCACHE)/gmp-$(GMP_VER)/source-extracted: $(SRCCACHE)/gmp-$(GMP_VER).tar.bz2
      $(JLCHECKSUM) $<
      cd $(dir $<) && $(TAR) -jxf $<
      touch -c $(SRCCACHE)/gmp-$(GMP_VER)/configure # old target
      echo 1 > $@

    $(SRCCACHE)/gmp-$(GMP_VER)/build-patched: $(SRCCACHE)/gmp-$(GMP_VER)/source-extracted
      cd $(dir $@) && patch -p1 < $(SRCDIR)/patches/gmp-exception.patch
      cd $(dir $@) && patch -p1 < $(SRCDIR)/patches/gmp_alloc_overflow_func.patch
      cd $(dir $@) && patch -p1 < $(SRCDIR)/patches/gmp-apple-arm64.patch
      echo 1 > $@

    $(BUILDDIR)/gmp-$(GMP_VER)/build-configured: $(SRCCACHE)/gmp-$(GMP_VER)/source-extracted
      mkdir -p $(dir $@)
      cd $(dir $@) && \
      $(dir $<)/configure $(CONFIGURE_COMMON) F77= --enable-cxx --enable-shared --disable-static $(GMP_CONFIGURE_OPTS)
      echo 1 > $@

    $(BUILDDIR)/gmp-$(GMP_VER)/build-compiled: $(BUILDDIR)/gmp-$(GMP_VER)/build-configured
      $(MAKE) -C $(dir $<) $(LIBTOOL_CCLD)
      echo 1 > $@

    $(BUILDDIR)/gmp-$(GMP_VER)/build-checked: $(BUILDDIR)/gmp-$(GMP_VER)/build-compiled
      $(MAKE) -C $(dir $@) $(LIBTOOL_CCLD) check

    define GMP_INSTALL
      mkdir -p $2/$(build_shlibdir) $2/$(build_includedir)
      $(INSTALL_M) $1/.libs/libgmp*$(SHLIB_EXT)* $2/$(build_shlibdir)
      $(INSTALL_F) $1/gmp.h $2/$(build_includedir)
    endef
    $(eval $(call staged-install, \
      gmp,gmp-$(GMP_VER), \
      GMP_INSTALL,,, \
      $$(INSTALL_NAME_CMD)libgmp.$$(SHLIB_EXT) $$(build_shlibdir)/libgmp.$$(SHLIB_EXT)))
}

mbedtls() {
    MBEDTLS_OPTS := $(CMAKE_COMMON) -DUSE_SHARED_MBEDTLS_LIBRARY=ON \
        -DUSE_STATIC_MBEDTLS_LIBRARY=OFF -DENABLE_PROGRAMS=OFF -DCMAKE_BUILD_TYPE=Release
    MBEDTLS_OPTS += -DENABLE_ZLIB_SUPPORT=OFF
    MBEDTLS_OPTS += -DCMAKE_INSTALL_RPATH="\$$ORIGIN"

    $(SRCCACHE)/$(MBEDTLS_SRC)/source-extracted: $(SRCCACHE)/$(MBEDTLS_SRC).tar.gz
      $(JLCHECKSUM) $<
      mkdir -p $(dir $@) && \
      $(TAR) -C $(dir $@) --strip-components 1 -xf $<
      # Force-enable MD4
      sed -i.org "s|//#define MBEDTLS_MD4_C|#define MBEDTLS_MD4_C|" $(SRCCACHE)/$(MBEDTLS_SRC)/include/mbedtls/config.h
      touch -c $(SRCCACHE)/$(MBEDTLS_SRC)/CMakeLists.txt # old target
      echo 1 > $@

    $(SRCCACHE)/$(MBEDTLS_SRC)/mbedtls-cmake-findpy.patch-applied: $(SRCCACHE)/$(MBEDTLS_SRC)/source-extracted
      # Apply workaround for CMake 3.18.2 bug (https://github.com/ARMmbed/mbedtls/pull/3691).
      # This patch merged upstream shortly after MBedTLS's 2.25.0 minor release, so chances
      # are it will be included at least in their next minor release (2.26.0?).
      cd $(SRCCACHE)/$(MBEDTLS_SRC) && \
        patch -p1 -f < $(SRCDIR)/patches/mbedtls-cmake-findpy.patch
      echo 1 > $@

    $(BUILDDIR)/$(MBEDTLS_SRC)/build-configured: \
      $(SRCCACHE)/$(MBEDTLS_SRC)/mbedtls-cmake-findpy.patch-applied

    $(BUILDDIR)/$(MBEDTLS_SRC)/build-configured: $(SRCCACHE)/$(MBEDTLS_SRC)/source-extracted
      mkdir -p $(dir $@)
      cd $(dir $@) && \
      $(CMAKE) $(dir $<) $(MBEDTLS_OPTS)
      echo 1 > $@

    $(BUILDDIR)/$(MBEDTLS_SRC)/build-compiled: $(BUILDDIR)/$(MBEDTLS_SRC)/build-configured
      $(MAKE) -C $(dir $<)
      echo 1 > $@

    $(BUILDDIR)/$(MBEDTLS_SRC)/build-checked: $(BUILDDIR)/$(MBEDTLS_SRC)/build-compiled
      $(MAKE) -C $(dir $@) test

    define MBEDTLS_INSTALL
      $(call MAKE_INSTALL,$1,$2,)
    endef
    $(eval $(call staged-install, \
      mbedtls,$(MBEDTLS_SRC), \
      MBEDTLS_INSTALL,,, \
      $$(INSTALL_NAME_CMD)libmbedx509.$$(SHLIB_EXT) $$(build_shlibdir)/libmbedx509.$$(SHLIB_EXT) && \
      $$(INSTALL_NAME_CMD)libmbedtls.$$(SHLIB_EXT) $$(build_shlibdir)/libmbedtls.$$(SHLIB_EXT) && \
      $$(INSTALL_NAME_CHANGE_CMD) libmbedx509.0.dylib @rpath/libmbedx509.$$(SHLIB_EXT) $$(build_shlibdir)/libmbedtls.$$(SHLIB_EXT) && \
      $$(INSTALL_NAME_CHANGE_CMD) libmbedcrypto.3.dylib @rpath/libmbedcrypto.$$(SHLIB_EXT) $$(build_shlibdir)/libmbedtls.$$(SHLIB_EXT) && \
      $$(INSTALL_NAME_CHANGE_CMD) libmbedcrypto.3.dylib @rpath/libmbedcrypto.$$(SHLIB_EXT) $$(build_shlibdir)/libmbedx509.$$(SHLIB_EXT) && \
      $$(INSTALL_NAME_CMD)libmbedcrypto.$$(SHLIB_EXT) $$(build_shlibdir)/libmbedcrypto.$$(SHLIB_EXT)))
}

mpfr() {
    ifeq ($(USE_SYSTEM_GMP), 0)
    $(BUILDDIR)/mpfr-$(MPFR_VER)/build-configured: | $(build_prefix)/manifest/gmp
    endif

    MPFR_OPTS := --enable-thread-safe --enable-shared-cache --disable-float128 --disable-decimal-float
    ifeq ($(USE_SYSTEM_GMP), 0)
    MPFR_OPTS += --with-gmp-include=$(abspath $(build_includedir)) --with-gmp-lib=$(abspath $(build_shlibdir))
    endif

    ifeq ($(SANITIZE),1)
    # Force generic C build
    MPFR_OPTS += --host=none-unknown-linux
    endif

    $(SRCCACHE)/mpfr-$(MPFR_VER).tar.bz2: | $(SRCCACHE)
      $(JLDOWNLOAD) $@ https://www.mpfr.org/mpfr-$(MPFR_VER)/$(notdir $@)
    $(SRCCACHE)/mpfr-$(MPFR_VER)/source-extracted: $(SRCCACHE)/mpfr-$(MPFR_VER).tar.bz2
      $(JLCHECKSUM) $<
      cd $(dir $<) && $(TAR) -jxf $<
      cp $(SRCDIR)/patches/config.sub $(SRCCACHE)/mpfr-$(MPFR_VER)/config.sub
      touch -c $(SRCCACHE)/mpfr-$(MPFR_VER)/configure # old target
      echo 1 > $@

    $(BUILDDIR)/mpfr-$(MPFR_VER)/build-configured: $(SRCCACHE)/mpfr-$(MPFR_VER)/source-extracted
      mkdir -p $(dir $@)
      cd $(dir $@) && \
      $(dir $<)/configure $(CONFIGURE_COMMON) $(MPFR_OPTS) F77= --enable-shared --disable-static
      echo 1 > $@

    $(BUILDDIR)/mpfr-$(MPFR_VER)/build-compiled: $(BUILDDIR)/mpfr-$(MPFR_VER)/build-configured
      $(MAKE) -C $(dir $<) $(LIBTOOL_CCLD)
      echo 1 > $@

    $(BUILDDIR)/mpfr-$(MPFR_VER)/build-checked: $(BUILDDIR)/mpfr-$(MPFR_VER)/build-compiled
      $(MAKE) -C $(dir $@) $(LIBTOOL_CCLD) check $(MPFR_CHECK_MFLAGS)

    $(eval $(call staged-install, \
      mpfr,mpfr-$(MPFR_VER), \
      MAKE_INSTALL,$$(LIBTOOL_CCLD),, \
      $$(INSTALL_NAME_CMD)libmpfr.$$(SHLIB_EXT) $$(build_shlibdir)/libmpfr.$$(SHLIB_EXT)))
}

nghttp2() {
    $(SRCCACHE)/nghttp2-$(NGHTTP2_VER)/source-extracted: $(SRCCACHE)/nghttp2-$(NGHTTP2_VER).tar.bz2
      $(JLCHECKSUM) $<
      cd $(dir $<) && $(TAR) -jxf $<
      touch -c $(SRCCACHE)/nghttp2-$(NGHTTP2_VER)/configure # old target
      echo 1 > $@

    $(BUILDDIR)/nghttp2-$(NGHTTP2_VER)/build-configured: $(SRCCACHE)/nghttp2-$(NGHTTP2_VER)/source-extracted
      mkdir -p $(dir $@)
      cd $(dir $@) && \
      $(dir $<)/configure $(CONFIGURE_COMMON) --enable-lib-only
      echo 1 > $@

    $(BUILDDIR)/nghttp2-$(NGHTTP2_VER)/build-compiled: $(BUILDDIR)/nghttp2-$(NGHTTP2_VER)/build-configured
      $(MAKE) -C $(dir $<)
      echo 1 > $@

    $(BUILDDIR)/nghttp2-$(NGHTTP2_VER)/build-checked: $(BUILDDIR)/nghttp2-$(NGHTTP2_VER)/build-compiled
      $(MAKE) -C $(dir $@) check $(NGHTTP2_CHECK_MFLAGS)

    $(eval $(call staged-install, \
      nghttp2,nghttp2-$(NGHTTP2_VER), \
      MAKE_INSTALL,,, \
      $$(INSTALL_NAME_CMD)libnghttp2.$$(SHLIB_EXT) $$(build_shlibdir)/libnghttp2.$$(SHLIB_EXT)))
}

objconv() {
    $(SRCCACHE)/objconv.zip: | $(SRCCACHE)
      $(JLDOWNLOAD) $@ https://www.agner.org/optimize/objconv.zip

    $(BUILDDIR)/objconv/source-extracted: $(SRCCACHE)/objconv.zip
      -rm -r $(dir $@)
      mkdir -p $(BUILDDIR)
      unzip -d $(dir $@) $<
      cd $(dir $@) && unzip source.zip
      echo 1 > $@

    $(BUILDDIR)/objconv/build-compiled: $(BUILDDIR)/objconv/source-extracted
      cd $(dir $<) && $(CXX) -o objconv -O2 *.cpp
      echo 1 > $@

    $(eval $(call staged-install, \
      objconv,objconv, \
      BINFILE_INSTALL,$$(BUILDDIR)/objconv/objconv,,))
}

p7zip() {
    # Force optimization for P7ZIP flags (Issue #11668)
    $(SRCCACHE)/p7zip-$(P7ZIP_VER).tar.bz2: | $(SRCCACHE)
      $(JLDOWNLOAD) $@ https://downloads.sourceforge.net/project/p7zip/p7zip/16.02/p7zip_16.02_src_all.tar.bz2

    $(BUILDDIR)/p7zip-$(P7ZIP_VER)/source-extracted: $(SRCCACHE)/p7zip-$(P7ZIP_VER).tar.bz2
      $(JLCHECKSUM) $<
      mkdir -p $(dir $@)
      cd $(dir $@) && $(TAR) --strip-components 1 -jxf $<
      echo $1 > $@

    checksum-p7zip: $(SRCCACHE)/p7zip-$(P7ZIP_VER).tar.bz2
      $(JLCHECKSUM) $<

    $(BUILDDIR)/p7zip-$(P7ZIP_VER)/p7zip-12-CVE-2016-9296.patch-applied: $(BUILDDIR)/p7zip-$(P7ZIP_VER)/source-extracted
      cd $(dir $@) && patch -p1 -f < $(SRCDIR)/patches/p7zip-12-CVE-2016-9296.patch
      echo 1 > $@

    $(BUILDDIR)/p7zip-$(P7ZIP_VER)/p7zip-13-CVE-2017-17969.patch-applied: $(BUILDDIR)/p7zip-$(P7ZIP_VER)/p7zip-12-CVE-2016-9296.patch-applied
      cd $(dir $@) && patch -p1 -f < $(SRCDIR)/patches/p7zip-13-CVE-2017-17969.patch
      echo 1 > $@

    $(BUILDDIR)/p7zip-$(P7ZIP_VER)/p7zip-15-Enhanced-encryption-strength.patch-applied: $(BUILDDIR)/p7zip-$(P7ZIP_VER)/p7zip-13-CVE-2017-17969.patch-applied
      cd $(dir $@) && patch -p4 -f < $(SRCDIR)/patches/p7zip-15-Enhanced-encryption-strength.patch
      echo 1 > $@

    $(BUILDDIR)/p7zip-$(P7ZIP_VER)/p7zip-Windows_ErrorMsg.patch-applied: $(BUILDDIR)/p7zip-$(P7ZIP_VER)/p7zip-15-Enhanced-encryption-strength.patch-applied
      cd $(dir $@) && patch -p0 -f < $(SRCDIR)/patches/p7zip-Windows_ErrorMsg.patch
      echo 1 > $@

    $(BUILDDIR)/p7zip-$(P7ZIP_VER)/build-configured: $(BUILDDIR)/p7zip-$(P7ZIP_VER)/p7zip-Windows_ErrorMsg.patch-applied
    $(BUILDDIR)/p7zip-$(P7ZIP_VER)/build-compiled: $(BUILDDIR)/p7zip-$(P7ZIP_VER)/build-configured
      $(MAKE) -C $(dir $<) $(MAKE_COMMON) CC="$(CC)" CXX="$(CXX)" 7za
      echo 1 > $@

    define P7ZIP_INSTALL
      mkdir -p $2/$$(build_bindir)
      cp -a $1/bin/7za $2/$$(build_bindir)/7z
    endef
    $(eval $(call staged-install, \
      p7zip,p7zip-$(P7ZIP_VER), \
      P7ZIP_INSTALL,,,))

}

patchelf() {
      $(JLCHECKSUM) $<
      cd $(dir $<) && $(TAR) zxf $<
      touch -c $(SRCCACHE)/patchelf-$(PATCHELF_VER)/configure # old target
      echo 1 > $@

    $(BUILDDIR)/patchelf-$(PATCHELF_VER)/build-configured: $(SRCCACHE)/patchelf-$(PATCHELF_VER)/source-extracted | $(LIBCXX_DEPENDENCY)
      mkdir -p $(dir $@)
      cd $(dir $@) && \
      $(dir $<)/configure $(CONFIGURE_COMMON) LDFLAGS="$(CXXLDFLAGS)" CPPFLAGS="$(CPPFLAGS)"
      echo 1 > $@

    $(BUILDDIR)/patchelf-$(PATCHELF_VER)/build-compiled: $(BUILDDIR)/patchelf-$(PATCHELF_VER)/build-configured
      $(MAKE) -C $(dir $<)
      echo 1 > $@

    $(BUILDDIR)/patchelf-$(PATCHELF_VER)/build-checked: $(BUILDDIR)/patchelf-$(PATCHELF_VER)/build-compiled
    ifeq ($(OS),$(BUILD_OS))
      # disabled due to bug in v0.6
      #$(MAKE) -C $(dir $@) check
    endif
      echo 1 > $@

    $(eval $(call staged-install, \
      patchelf,patchelf-$(PATCHELF_VER), \
      MAKE_INSTALL,$$(LIBTOOL_CCLD),,))
}

pcre() {
    PCRE_CFLAGS := -O3
    PCRE_LDFLAGS := $(RPATH_ESCAPED_ORIGIN)

    $(SRCCACHE)/pcre2-$(PCRE_VER).tar.bz2: | $(SRCCACHE)
      $(JLDOWNLOAD) $@ https://ftp.pcre.org/pub/pcre/pcre2-$(PCRE_VER).tar.bz2

    $(SRCCACHE)/pcre2-$(PCRE_VER)/source-extracted: $(SRCCACHE)/pcre2-$(PCRE_VER).tar.bz2
      $(JLCHECKSUM) $<
      cd $(dir $<) && $(TAR) jxf $(notdir $<)
      cp $(SRCDIR)/patches/config.sub $(SRCCACHE)/pcre2-$(PCRE_VER)/config.sub
      cd $(SRCCACHE)/pcre2-$(PCRE_VER) && patch -p1 -f < $(SRCDIR)/patches/pcre2-cet-flags.patch
      # Fix some old targets modified by the patching
      touch -c $(SRCCACHE)/pcre2-$(PCRE_VER)/Makefile.am
      touch -c $(SRCCACHE)/pcre2-$(PCRE_VER)/Makefile.in
      touch -c $(SRCCACHE)/pcre2-$(PCRE_VER)/aclocal.m4
      touch -c $(SRCCACHE)/pcre2-$(PCRE_VER)/configure
      echo $1 > $@

    checksum-pcre2: $(SRCCACHE)/pcre2-$(PCRE_VER).tar.bz2
      $(JLCHECKSUM) $<

    $(BUILDDIR)/pcre2-$(PCRE_VER)/build-configured: $(SRCCACHE)/pcre2-$(PCRE_VER)/source-extracted
      mkdir -p $(dir $@)
      cd $(dir $@) && \
      $(dir $<)/configure $(CONFIGURE_COMMON) --enable-jit --includedir=$(build_includedir) CFLAGS="$(CFLAGS) $(PCRE_CFLAGS)" LDFLAGS="$(LDFLAGS) $(PCRE_LDFLAGS)"
      echo 1 > $@

    $(BUILDDIR)/pcre2-$(PCRE_VER)/build-compiled: $(BUILDDIR)/pcre2-$(PCRE_VER)/build-configured
      $(MAKE) -C $(dir $<) $(LIBTOOL_CCLD)
      echo 1 > $@

    $(BUILDDIR)/pcre2-$(PCRE_VER)/build-checked: $(BUILDDIR)/pcre2-$(PCRE_VER)/build-compiled
      $(MAKE) -C $(dir $@) check -j1

    $(eval $(call staged-install, \
      pcre,pcre2-$$(PCRE_VER), \
      MAKE_INSTALL,$$(LIBTOOL_CCLD),, \
      rm $$(build_shlibdir)/libpcre2-posix.* && \
      $$(INSTALL_NAME_CMD)libpcre2-8.$$(SHLIB_EXT) $$(build_shlibdir)/libpcre2-8.$$(SHLIB_EXT)))
}

SUITESPARSE() {
    ifeq ($(USE_BLAS64), 1)
    UMFPACK_CONFIG := -DLONGBLAS='long long'
    CHOLMOD_CONFIG := -DLONGBLAS='long long'
    SPQR_CONFIG := -DLONGBLAS='long long'
    ifeq ($(OPENBLAS_SYMBOLSUFFIX), 64_)
    UMFPACK_CONFIG += -DSUN64
    CHOLMOD_CONFIG += -DSUN64
    SPQR_CONFIG += -DSUN64
    endif
    endif

    # Disable trying to link against libmetis
    CHOLMOD_CONFIG += -DNPARTITION

    SUITESPARSE_PROJECTS := AMD BTF CAMD CCOLAMD COLAMD CHOLMOD LDL KLU UMFPACK RBio SPQR
    SUITESPARSE_LIBS := $(addsuffix .*$(SHLIB_EXT)*,suitesparseconfig amd btf camd ccolamd colamd cholmod klu ldl umfpack rbio spqr)

    SUITE_SPARSE_LIB := $(LDFLAGS) -L"$(abspath $(BUILDDIR))/SuiteSparse-$(SUITESPARSE_VER)/lib"
    SUITESPARSE_MFLAGS := CC="$(CC)" CXX="$(CXX)" F77="$(FC)" AR="$(AR)" RANLIB="$(RANLIB)" BLAS="$(LIBBLAS)" LAPACK="$(LIBLAPACK)" \
        LDFLAGS="$(SUITE_SPARSE_LIB)" CFOPENMP="" CUDA=no CUDA_PATH="" \
        UMFPACK_CONFIG="$(UMFPACK_CONFIG)" CHOLMOD_CONFIG="$(CHOLMOD_CONFIG)" SPQR_CONFIG="$(SPQR_CONFIG)"
    SUITESPARSE_MFLAGS += UNAME=$(OS)

    $(BUILDDIR)/SuiteSparse-$(SUITESPARSE_VER)/source-extracted: $(SRCCACHE)/SuiteSparse-$(SUITESPARSE_VER).tar.gz
      $(JLCHECKSUM) $<
      mkdir -p $(dir $@)
      $(TAR) -C $(dir $@) --strip-components 1 -zxf $<
      echo 1 > $@

    $(BUILDDIR)/SuiteSparse-$(SUITESPARSE_VER)/SuiteSparse-winclang.patch-applied: $(BUILDDIR)/SuiteSparse-$(SUITESPARSE_VER)/source-extracted
      cd $(dir $@) && patch -p0 < $(SRCDIR)/patches/SuiteSparse-winclang.patch
      echo 1 > $@
    $(BUILDDIR)/SuiteSparse-$(SUITESPARSE_VER)/SuiteSparse-shlib.patch-applied: $(BUILDDIR)/SuiteSparse-$(SUITESPARSE_VER)/source-extracted
      cd $(dir $@) && patch -p1 < $(SRCDIR)/patches/SuiteSparse-shlib.patch
      echo 1 > $@
    $(BUILDDIR)/SuiteSparse-$(SUITESPARSE_VER)/build-compiled: $(BUILDDIR)/SuiteSparse-$(SUITESPARSE_VER)/SuiteSparse-winclang.patch-applied
    $(BUILDDIR)/SuiteSparse-$(SUITESPARSE_VER)/build-compiled: $(BUILDDIR)/SuiteSparse-$(SUITESPARSE_VER)/SuiteSparse-shlib.patch-applied

    ifeq ($(USE_SYSTEM_BLAS), 0)
    $(BUILDDIR)/SuiteSparse-$(SUITESPARSE_VER)/build-compiled: | $(build_prefix)/manifest/openblas
    else ifeq ($(USE_SYSTEM_LAPACK), 0)
    $(BUILDDIR)/SuiteSparse-$(SUITESPARSE_VER)/build-compiled: | $(build_prefix)/manifest/lapack
    endif

    $(BUILDDIR)/SuiteSparse-$(SUITESPARSE_VER)/build-compiled: $(BUILDDIR)/SuiteSparse-$(SUITESPARSE_VER)/source-extracted
      $(MAKE) -C $(dir $<)SuiteSparse_config library config $(SUITESPARSE_MFLAGS)
      $(INSTALL_NAME_CMD)libsuitesparseconfig.$(SHLIB_EXT) $(dir $<)lib/libsuitesparseconfig.$(SHLIB_EXT)
      for PROJ in $(SUITESPARSE_PROJECTS); do \
        $(MAKE) -C $(dir $<)$${PROJ} library $(SUITESPARSE_MFLAGS) || exit 1; \
        $(INSTALL_NAME_CMD)lib`echo $${PROJ} | tr A-Z a-z`.$(SHLIB_EXT) $(dir $<)lib/lib`echo $${PROJ} | tr A-Z a-z`.$(SHLIB_EXT) || exit 1; \
      done
      echo 1 > $@

    SUITESPARSE_SHLIB_ENV:=LD_LIBRARY_PATH="$(build_shlibdir)"
    $(BUILDDIR)/SuiteSparse-$(SUITESPARSE_VER)/build-checked: $(BUILDDIR)/SuiteSparse-$(SUITESPARSE_VER)/build-compiled
      for PROJ in $(SUITESPARSE_PROJECTS); do \
        $(SUITESPARSE_SHLIB_ENV) $(MAKE) -C $(dir $<)$${PROJ} default $(SUITESPARSE_MFLAGS) || exit 1; \
      done
      echo 1 > $@

    $(build_prefix)/manifest/suitesparse: $(BUILDDIR)/SuiteSparse-$(SUITESPARSE_VER)/build-compiled | $(build_prefix)/manifest $(build_shlibdir)
      for lib in $(SUITESPARSE_LIBS); do \
        cp -a $(dir $<)lib/lib$${lib} $(build_shlibdir) || exit 1; \
      done
      #cp -a $(dir $<)lib/* $(build_shlibdir)
      #cp -a $(dir $<)include/* $(build_includedir)
      echo $(SUITESPARSE_VER) > $@

    # SUITESPARSE WRAPPER

    ifeq ($(USE_SYSTEM_SUITESPARSE), 1)
    SUITESPARSE_INC := -I $(LOCALBASE)/include/suitesparse
    SUITESPARSE_LIB := -lumfpack -lcholmod -lamd -lcamd -lcolamd -lspqr
    else
    SUITESPARSE_INC := -I $(BUILDDIR)/SuiteSparse-$(SUITESPARSE_VER)/CHOLMOD/Include -I $(BUILDDIR)/SuiteSparse-$(SUITESPARSE_VER)/SuiteSparse_config -I $(BUILDDIR)/SuiteSparse-$(SUITESPARSE_VER)/SPQR/Include
    SUITESPARSE_LIB := -L$(build_shlibdir) -lcholmod -lumfpack -lspqr $(RPATH_ORIGIN)
    $(build_shlibdir)/libsuitesparse_wrapper.$(SHLIB_EXT): $(build_prefix)/manifest/suitesparse
    endif

    $(build_shlibdir)/libsuitesparse_wrapper.$(SHLIB_EXT): $(SRCDIR)/SuiteSparse_wrapper.c
      mkdir -p $(build_shlibdir)
      $(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -O2 -shared $(fPIC) $(SUITESPARSE_INC) $< -o $@ $(SUITESPARSE_LIB)
      $(INSTALL_NAME_CMD)libsuitesparse_wrapper.$(SHLIB_EXT) $@
      touch -c $@
}