JULIA_PRECOMPILE ?= 1

FORCE_ASSERTIONS ?= 0

# OPENBLAS build options
OPENBLAS_TARGET_ARCH:=
OPENBLAS_SYMBOLSUFFIX:=
OPENBLAS_LIBNAMESUFFIX:=

# If OPENBLAS_TARGET_ARCH is set, we default to disabling OPENBLAS_DYNAMIC_ARCH
ifneq ($(OPENBLAS_TARGET_ARCH),)
OPENBLAS_DYNAMIC_ARCH:=0
else
OPENBLAS_DYNAMIC_ARCH:=1
endif
OPENBLAS_USE_THREAD:=1

JULIA_THREADS := 1

INSTALL_F := $(JULIAHOME)/contrib/install.sh 644
INSTALL_M := $(JULIAHOME)/contrib/install.sh 755

JLDOWNLOAD := $(JULIAHOME)/deps/tools/jldownload
JLCHECKSUM := $(JULIAHOME)/deps/tools/jlchecksum

JULIACODEGEN := LLVM

ifeq ($(origin LLVM_CONFIG), undefined)
ifeq ($(USE_SYSTEM_LLVM), 1)
LLVM_CONFIG := llvm-config$(EXE)
else
LLVM_CONFIG := $(build_depsbindir)/llvm-config$(EXE)
endif
endif # LLVM_CONFIG undefined

ifeq ($(USE_SYSTEM_LLVM), 1)
JCPPFLAGS+=-DSYSTEM_LLVM
endif # SYSTEM_LLVM

# Windows builds need a little help finding the LLVM libraries for llvm-config
LLVM_CONFIG_PATH_FIX :=
ifeq ($(OS),WINNT)
LLVM_CONFIG_PATH_FIX := PATH="$(PATH):$(build_bindir)"
endif

ifeq ($(BUILD_OS),$(OS))
LLVM_CONFIG_HOST := $(LLVM_CONFIG)
else
LLVM_CONFIG_HOST := $(basename $(LLVM_CONFIG))-host$(BUILD_EXE)
ifeq (exists, $(shell [ -f '$(LLVM_CONFIG_HOST)' ] && echo exists ))
ifeq ($(shell $(LLVM_CONFIG_PATH_FIX) $(LLVM_CONFIG_HOST) --version),3.3)
# llvm-config-host <= 3.3 is broken, use llvm-config instead (in an emulator)
# use delayed expansion (= not :=) because spawn isn't defined until later
LLVM_CONFIG_HOST = $(LLVM_CONFIG_PATH_FIX) $(call spawn,$(LLVM_CONFIG))
endif
else
# llvm-config-host does not exist (cmake build)
LLVM_CONFIG_HOST = $(LLVM_CONFIG_PATH_FIX) $(call spawn,$(LLVM_CONFIG))
endif
endif

ifeq ($(USE_SYSTEM_PCRE), 1)
PCRE_CONFIG := pcre2-config
else
PCRE_CONFIG := $(build_depsbindir)/pcre2-config
endif

ifeq ($(USE_SYSTEM_PATCHELF), 1)
PATCHELF := patchelf
else
PATCHELF := $(build_depsbindir)/patchelf
endif

# Use ILP64 BLAS interface when building openblas from source on 64-bit architectures
ifeq ($(BINARY), 64)
ifeq ($(USE_SYSTEM_BLAS), 1)
ifeq ($(USE_INTEL_MKL), 1)
USE_BLAS64 ?= 1
else # non MKL system blas is most likely LP64
USE_BLAS64 ?= 0
endif
else
USE_BLAS64 ?= 1
endif
endif

ifeq ($(USE_SYSTEM_BLAS), 1)
ifeq ($(OS), Darwin)
USE_BLAS64 := 0
USE_SYSTEM_LAPACK := 0
LIBBLAS := -L$(build_libdir) -lgfortblas
LIBBLASNAME := libgfortblas
else
LIBBLAS ?= -lblas
LIBBLASNAME ?= libblas
endif
else
LIBBLAS := -L$(build_shlibdir) -lopenblas
LIBBLASNAME := libopenblas
endif

# OpenBLAS builds LAPACK as part of its build.
# We only need to build LAPACK if we are not using OpenBLAS.
ifeq ($(USE_SYSTEM_BLAS), 0)
LIBLAPACK := $(LIBBLAS)
LIBLAPACKNAME := $(LIBBLASNAME)
else
ifeq ($(USE_SYSTEM_LAPACK), 1)
LIBLAPACK ?= -llapack
LIBLAPACKNAME ?= liblapack
else
LIBLAPACK := -L$(build_shlibdir) -llapack $(LIBBLAS)
LIBLAPACKNAME := liblapack
endif
endif

ifeq ($(USE_SYSTEM_LIBM), 1)
LIBM := -lm
LIBMNAME := libm
else
LIBM := -lopenlibm
LIBMNAME := libopenlibm
endif

ifeq ($(USE_SYSTEM_LIBUV), 1)
  LIBUV := $(LOCALBASE)/lib/libuv-julia.a
  LIBUV_INC := $(LOCALBASE)/include
else
  LIBUV := $(build_libdir)/libuv.a
  LIBUV_INC := $(build_includedir)
endif

ifeq ($(USE_SYSTEM_UTF8PROC), 1)
  LIBUTF8PROC := -lutf8proc
  UTF8PROC_INC := $(LOCALBASE)/include
else
  LIBUTF8PROC := $(build_libdir)/libutf8proc.a
  UTF8PROC_INC := $(build_includedir)
endif

# BinaryBuilder options.  We default to "on" for all the projects listed in BB_PROJECTS,
# but only if contrib/normalize_triplet.py works for our requested triplet.
ifeq ($(shell $(call invoke_python,$(JULIAHOME)/contrib/normalize_triplet.py) $(or $(XC_HOST),$(XC_HOST),$(BUILD_MACHINE)) >/dev/null 2>/dev/null; echo $$?),0)
USE_BINARYBUILDER ?= 1
else
ifneq ($(shell $(call invoke_python,$(JULIAHOME)/contrib/normalize_triplet.py) x86_64-linux-gnu),x86_64-linux-gnu)
$(warning normalize_triplet.py appears to be non-functional (used python interpreter "$(PYTHON)"), so BinaryBuilder disabled)
endif
USE_BINARYBUILDER ?= 0
endif

# Auto-detect triplet once, create different versions that we use as defaults below for each BB install target
BB_TRIPLET_LIBGFORTRAN_CXXABI := $(shell $(call invoke_python,$(JULIAHOME)/contrib/normalize_triplet.py) $(or $(XC_HOST),$(XC_HOST),$(BUILD_MACHINE)) "$(shell $(FC) --version | head -1)" "$(or $(shell echo '\#include <string>' | $(CXX) $(CXXFLAGS) -x c++ -dM -E - | grep _GLIBCXX_USE_CXX11_ABI | awk '{ print $$3 }' ),1)")
BB_TRIPLET_LIBGFORTRAN := $(subst $(SPACE),-,$(filter-out cxx%,$(subst -,$(SPACE),$(BB_TRIPLET_LIBGFORTRAN_CXXABI))))
BB_TRIPLET_CXXABI := $(subst $(SPACE),-,$(filter-out libgfortran%,$(subst -,$(SPACE),$(BB_TRIPLET_LIBGFORTRAN_CXXABI))))
BB_TRIPLET := $(subst $(SPACE),-,$(filter-out cxx%,$(filter-out libgfortran%,$(subst -,$(SPACE),$(BB_TRIPLET_LIBGFORTRAN_CXXABI)))))

# This is the set of projects that BinaryBuilder dependencies are hooked up for.
BB_PROJECTS := OPENBLAS LLVM SUITESPARSE OPENLIBM GMP MBEDTLS LIBSSH2 NGHTTP2 MPFR CURL LIBGIT2 PCRE LIBUV LIBUNWIND DSFMT OBJCONV ZLIB P7ZIP CSL
define SET_BB_DEFAULT
# First, check to see if BB is disabled on a global setting
ifeq ($$(USE_BINARYBUILDER),0)
USE_BINARYBUILDER_$(1) ?= 0
else
# If it's not, check to see if it's disabled by a USE_SYSTEM_xxx flag
ifeq ($$(USE_SYSTEM_$(1)),1)
USE_BINARYBUILDER_$(1) ?= 0
else
USE_BINARYBUILDER_$(1) ?= 1
endif
endif
endef
$(foreach proj,$(BB_PROJECTS),$(eval $(call SET_BB_DEFAULT,$(proj))))



# Use the Assertions build
BINARYBUILDER_LLVM_ASSERTS ?= 0


# ATLAS

# ATLAS must have been previously  installed to usr/lib/libatlas
# (built as a shared library, for your platform, single threaded)
USE_ATLAS := 0
ATLAS_LIBDIR := $(build_libdir)
#or ATLAS_LIBDIR := /path/to/system/atlas/lib

ifeq ($(USE_ATLAS), 1)
USE_BLAS64 := 0
USE_SYSTEM_BLAS := 1
USE_SYSTEM_LAPACK := 1
LIBBLAS := -L$(ATLAS_LIBDIR) -lsatlas
LIBLAPACK := $(LIBBLAS)
LIBBLASNAME := libsatlas
LIBLAPACKNAME := $(LIBBLASNAME)
endif

# Renaming OpenBLAS symbols, see #4923 and #8734
ifeq ($(USE_SYSTEM_BLAS), 0)
ifeq ($(USE_BLAS64), 1)
OPENBLAS_SYMBOLSUFFIX := 64_
OPENBLAS_LIBNAMESUFFIX := 64_
LIBBLAS := -L$(build_shlibdir) -lopenblas$(OPENBLAS_LIBNAMESUFFIX)
LIBLAPACK := $(LIBBLAS)
LIBBLASNAME := $(LIBBLASNAME)$(OPENBLAS_LIBNAMESUFFIX)
LIBLAPACKNAME := $(LIBBLASNAME)
endif
endif


# Some special restrictions on BB usage:
ifeq ($(USE_SYSTEM_BLAS),1)
# Since the names don't line up (`BLAS` vs. `OPENBLAS`), manually gate:
USE_BINARYBUILDER_OPENBLAS := 0
# Disable BB SuiteSparse if we're using system BLAS
USE_BINARYBUILDER_SUITESPARSE := 0
endif

ifeq ($(USE_SYSTEM_LIBM),1)
# If we're using system libm, disable BB OpenLibm
USE_BINARYBUILDER_OPENLIBM := 0
endif

# Make tricks

define dir_target
$$(abspath $(1)):
	@mkdir -p $$@
endef

define symlink_target # (from, to-dir, to-name)
CLEAN_TARGETS += clean-$$(abspath $(2)/$(3))
clean-$$(abspath $(2)/$(3)):
ifeq ($(BUILD_OS), WINNT)
	-cmd //C rmdir $$(call mingw_to_dos,$(2)/$(3),cd $(2) &&)
else
	-rm -r $$(abspath $(2)/$(3))
endif
$$(abspath $(2)/$(3)): | $$(abspath $(2))
ifeq ($$(BUILD_OS), WINNT)
	@cmd //C mklink //J $$(call mingw_to_dos,$(2)/$(3),cd $(2) &&) $$(call mingw_to_dos,$(1),)
else ifneq (,$$(findstring CYGWIN,$$(BUILD_OS)))
	@cmd /C mklink /J $$(call cygpath_w,$(2)/$(3)) $$(call cygpath_w,$(1))
else ifdef JULIA_VAGRANT_BUILD
	@rm -r $$@
	@cp -R $$(abspath $(1)) $$@.tmp
	@mv $$@.tmp $$@
else
	@ln -sf $$(abspath $(1)) $$@
endif
endef

LIBGCC_BUILD_DEPLIB := $(call dep_lib_path,$(build_libdir),$(build_shlibdir)/$(LIBGCC_NAME))
LIBGCC_INSTALL_DEPLIB := $(call dep_lib_path,$(libdir),$(private_shlibdir)/$(LIBGCC_NAME))

# USE_SYSTEM_LIBM and USE_SYSTEM_OPENLIBM causes it to get symlinked into build_private_shlibdir
ifeq ($(USE_SYSTEM_LIBM),1)
LIBM_BUILD_DEPLIB := $(call dep_lib_path,$(build_libdir),$(build_private_shlibdir)/$(LIBMNAME).$(SHLIB_EXT))
else ifeq ($(USE_SYSTEM_OPENLIBM),1)
LIBM_BUILD_DEPLIB := $(call dep_lib_path,$(build_libdir),$(build_private_shlibdir)/$(LIBMNAME).$(SHLIB_EXT))
else
LIBM_BUILD_DEPLIB := $(call dep_lib_path,$(build_libdir),$(build_shlibdir)/$(LIBMNAME).$(SHLIB_EXT))
endif
LIBM_INSTALL_DEPLIB := $(call dep_lib_path,$(libdir),$(private_shlibdir)/$(LIBMNAME).$(SHLIB_EXT))

# We list:
#  * libgcc_s, because FreeBSD needs to load ours, not the system one.
#  * libopenlibm, because Windows has an untrustworthy libm, and we want to use ours more than theirs
#  * libjulia, which must always come last.
#
# We need these four separate variables because:
#  * debug builds must link against libjuliadebug, not libjulia
#  * install time relative paths are not equal to build time relative paths (../lib vs. ../lib/julia)
# That second point will no longer be true for most deps once they are placed within Artifacts directories.
LOADER_BUILD_DEP_LIBS = $(LIBGCC_BUILD_DEPLIB):$(LIBM_BUILD_DEPLIB):$(LIBJULIAINTERNAL_BUILD_DEPLIB)
LOADER_DEBUG_BUILD_DEP_LIBS = $(LIBGCC_BUILD_DEPLIB):$(LIBM_BUILD_DEPLIB):$(LIBJULIAINTERNAL_DEBUG_BUILD_DEPLIB)
LOADER_INSTALL_DEP_LIBS = $(LIBGCC_INSTALL_DEPLIB):$(LIBM_INSTALL_DEPLIB):$(LIBJULIAINTERNAL_INSTALL_DEPLIB)
LOADER_DEBUG_INSTALL_DEP_LIBS = $(LIBGCC_INSTALL_DEPLIB):$(LIBM_INSTALL_DEPLIB):$(LIBJULIAINTERNAL_DEBUG_INSTALL_DEPLIB)
