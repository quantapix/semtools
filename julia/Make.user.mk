ARCH=x86_64
MARCH=native
JULIA_CPU_TARGET=native
# JULIA_CPU_TARGET="haswell"

prefix=/usr/local/julia

# julia julia-common libdsfmt-19937-1 libgit2-28 libhttp-parser2.9 
# libjulia1 libllvm8 libmbedcrypto3 libmbedtls12 libmbedx509-0
# libopenlibm3 libssh2-1 libutf8proc2

USE_BINARYBUILDER=0
USE_BLAS64=1
USE_INTEL_MKL=0
USE_LLVM_SHLIB=1
USE_SYSTEM_BLAS=0
USE_SYSTEM_CSL:=0
USE_SYSTEM_CURL=1
SHLIBDEPS += -lcurl
USE_SYSTEM_DSFMT=1
SHLIBDEPS += -ldSFMT
USE_SYSTEM_GMP=1
SHLIBDEPS += -lgmp
USE_SYSTEM_LAPACK=0
USE_SYSTEM_LIBGIT2=1
SHLIBDEPS += -lgit2
USE_SYSTEM_LIBM=0
USE_SYSTEM_LIBSSH2=1
SHLIBDEPS += -lssh2
USE_SYSTEM_LIBUNWIND=1
USE_SYSTEM_LIBUV=0
USE_SYSTEM_LLVM=1
SHLIBDEPS += -lLLVM -L/usr/lib/llvm-$(LLVM_VER)/lib/
USE_SYSTEM_MBEDTLS=1
SHLIBDEPS += -lmbedtls -lmbedcrypto -lmbedx509
USE_SYSTEM_MPFR=1
SHLIBDEPS += -lmpfr
USE_SYSTEM_NGHTTP2:=0
USE_SYSTEM_OPENLIBM=1
USE_SYSTEM_OPENSPECFUN=1
USE_SYSTEM_P7ZIP=1
USE_SYSTEM_PATCHELF=1
USE_SYSTEM_PCRE=1
SHLIBDEPS += -lpcre2-8
USE_SYSTEM_SUITESPARSE=0
USE_SYSTEM_UTF8PROC=1
SHLIBDEPS += -lutf8proc
USE_SYSTEM_ZLIB=1

LLVM_VER = $(shell grep -e 'llvm-.*-dev' debian/control | cut -d- -f2)

COMMON_FLAGS = \
	sysconfdir=/etc \
	LLVM_CONFIG=/usr/bin/llvm-config-$(LLVM_VER) \
	LLVM_VER=$(LLVM_VER)

ifeq ($(USE_INTEL_MKL),1)
	COMMON_FLAGS += LIBBLAS=-lmkl_rt LIBBLASNAME=libmkl_rt \
                	LIBLAPACK=-lmkl_rt LIBLAPACKNAME=libmkl_rt \
									MKLROOT=/usr MKLLIB=/usr/lib/$(DEB_HOST_MULTIARCH)
endif

COMMON_FLAGS += LIBBLAS=-lblas LIBBLASNAME=libblas \
                LIBLAPACK=-llapack LIBLAPACKNAME=liblapack

export LC_ALL=C.UTF-8
export HOME=/tmp



