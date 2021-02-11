"""Ubuntu libs deps"""

load("@rules_foreign_cc//:workspace_definitions.bzl", foreign_cc_deps = "rules_foreign_cc_dependencies")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

_files = """
filegroup(
    name = "files", 
    srcs = glob(["**"]), 
    visibility = ["//visibility:public"])
"""

# buildifier: disable=unnamed-macro
def ubu_libs_deps():
    """Ubuntu libs deps"""

    maybe(
        http_archive,
        name = "make",
        build_file_content = _files,
        sha256 = "e05fdde47c5f7ca45cb697e973894ff4f5d79e13b750ed57d7b66d8defc78e19",
        strip_prefix = "make-4.3",
        urls = ["http://mirror.rit.edu/gnu/make/make-4.3.tar.gz",],
    )

    maybe(
        new_git_repository,
        name = "ninja_build",
        remote = "/Users/qpix/clone/semtools/ubuntu/libs/upstream/ninja",
        tag = "v1.10.2",
        build_file_content = _files,
    )

    maybe(
        new_git_repository,
        name = "cmake",
        remote = "/Users/qpix/clone/semtools/ubuntu/libs/upstream/cmake",
        tag = "v3.19.4",
        build_file_content = _files,
    )

    maybe(
        new_git_repository,
        name = "nghttp2",
        remote = "/Users/qpix/clone/semtools/ubuntu/libs/upstream/nghttp2",
        tag = "v3.19.4",
        build_file_content = _files,
        # patch_args = ["-p1"],
        # patch_cmds = ["find . -name '*.sh' -exec sed -i.orig '1s|#!/usr/bin/env sh\\$|/bin/sh\\$|' {} +"],
        # patches = ["@rules_foreign_cc_tests//:nghttp2.patch"],
    )


    foreign_cc_deps([
        "//:built_ninja_toolchain_osx",
        "//:built_ninja_toolchain_linux",
    ])


    load("//deps:repositories.bzl", "repositories")

    repositories()



load(
    "//tools/build_defs/shell_toolchain/toolchains:ws_defs.bzl",
    shell_toolchain_workspace_initalization = "workspace_part",
)

# buildifier: disable=unnamed-macro
def rules_foreign_cc_dependencies(
        native_tools_toolchains = [],
        register_default_tools = True,
        additional_shell_toolchain_mappings = [],
        additional_shell_toolchain_package = None):
    """Call this function from the WORKSPACE file to initialize rules_foreign_cc \
    dependencies and let neccesary code generation happen \
    (Code generation is needed to support different variants of the C++ Starlark API.).

    Args:
        native_tools_toolchains: pass the toolchains for toolchain types
            '@rules_foreign_cc//tools/build_defs:cmake_toolchain' and
            '@rules_foreign_cc//tools/build_defs:ninja_toolchain' with the needed platform constraints.
            If you do not pass anything, registered default toolchains will be selected (see below).

        register_default_tools: If True, the cmake and ninja toolchains, calling corresponding
            preinstalled binaries by name (cmake, ninja) will be registered after
            'native_tools_toolchains' without any platform constraints. The default is True.

        additional_shell_toolchain_mappings: Mappings of the shell toolchain functions to
            execution and target platforms constraints. Similar to what defined in
            @rules_foreign_cc//tools/build_defs/shell_toolchain/toolchains:toolchain_mappings.bzl
            in the TOOLCHAIN_MAPPINGS list. Please refer to example in @rules_foreign_cc//toolchain_examples.

        additional_shell_toolchain_package: A package under which additional toolchains, referencing
            the generated data for the passed additonal_shell_toolchain_mappings, will be defined.
            This value is needed since register_toolchains() is called for these toolchains.
            Please refer to example in @rules_foreign_cc//toolchain_examples.
    """
    repositories()

    shell_toolchain_workspace_initalization(
        additional_shell_toolchain_mappings,
        additional_shell_toolchain_package,
    )

    native.register_toolchains(*native_tools_toolchains)
    if register_default_tools:
        native.register_toolchains(
            "@rules_foreign_cc//tools/build_defs:preinstalled_cmake_toolchain",
            "@rules_foreign_cc//tools/build_defs:preinstalled_ninja_toolchain",
            "@rules_foreign_cc//tools/build_defs:preinstalled_make_toolchain",
        )


    http_archive(
        name = "libevent",
        build_file_content = _files,
        strip_prefix = "libevent-2.1.8-stable",
        urls = [
            "https://mirror.bazel.build/github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz",
            "https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz",
        ],
        sha256 = "965cc5a8bb46ce4199a47e9b2c9e1cae3b137e8356ffdad6d94d3b9069b71dc2",
    )

    http_archive(
        name = "zlib",
        build_file_content = _files,
        sha256 = "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1",
        strip_prefix = "zlib-1.2.11",
        urls = [
            "https://mirror.bazel.build/zlib.net/zlib-1.2.11.tar.gz",
            "https://zlib.net/zlib-1.2.11.tar.gz",
        ],
    )

    http_archive(
        name = "libpng",
        build_file_content = _files,
        sha256 = "2f1e960d92ce3b3abd03d06dfec9637dfbd22febf107a536b44f7a47c60659f6",
        strip_prefix = "libpng-1.6.34",
        urls = [
            "https://mirror.bazel.build/ftp-osl.osuosl.org/pub/libpng/src/libpng16/libpng-1.6.34.tar.xz",
            "http://ftp-osl.osuosl.org/pub/libpng/src/libpng16/libpng-1.6.34.tar.xz",
        ],
    )

    http_archive(
        name = "freetype",
        build_file_content = _files,
        sha256 = "e6ffba3c8cef93f557d1f767d7bc3dee860ac7a3aaff588a521e081bc36f4c8a",
        strip_prefix = "freetype-2.9",
        urls = [
            "https://mirror.bazel.build/download.savannah.gnu.org/releases/freetype/freetype-2.9.tar.bz2",
            "https://download.savannah.gnu.org/releases/freetype/freetype-2.9.tar.bz2",
        ],
    )

    http_archive(
        name = "libgd",
        build_file_content = _files,
        sha256 = "8c302ccbf467faec732f0741a859eef4ecae22fea2d2ab87467be940842bde51",
        strip_prefix = "libgd-2.2.5",
        urls = [
            "https://mirror.bazel.build/github.com/libgd/libgd/releases/download/gd-2.2.5/libgd-2.2.5.tar.xz",
            "https://github.com/libgd/libgd/releases/download/gd-2.2.5/libgd-2.2.5.tar.xz",
        ],
    )

    http_archive(
        name = "pybind11",
        build_file_content = _files,
        strip_prefix = "pybind11-2.2.3",
        urls = [
            "https://mirror.bazel.build/github.com/pybind/pybind11/archive/v2.2.3.tar.gz",
            "https://github.com/pybind/pybind11/archive/v2.2.3.tar.gz",
        ],
        sha256 = "3a3b7b651afab1c5ba557f4c37d785a522b8030dfc765da26adc2ecd1de940ea",
    )

    http_archive(
        name = "cares",
        build_file_content = _files,
        sha256 = "62dd12f0557918f89ad6f5b759f0bf4727174ae9979499f5452c02be38d9d3e8",
        strip_prefix = "c-ares-cares-1_14_0",
        urls = [
            "https://mirror.bazel.build/github.com/c-ares/c-ares/archive/cares-1_14_0.tar.gz",
            "https://github.com/c-ares/c-ares/archive/cares-1_14_0.tar.gz",
        ],
    )


    http_archive(
        name = "eigen",
        build_file_content = _files,
        strip_prefix = "eigen-git-mirror-3.3.5",
        urls = [
            "https://mirror.bazel.build/github.com/eigenteam/eigen-git-mirror/archive/3.3.5.tar.gz",
            "https://github.com/eigenteam/eigen-git-mirror/archive/3.3.5.tar.gz",
        ],
        sha256 = "992855522dfdd0dea74d903dcd082cdb01c1ae72be5145e2fe646a0892989e43",
    )

    http_archive(
        name = "openblas",
        build_file_content = _files,
        strip_prefix = "OpenBLAS-0.3.2",
        urls = [
            "https://mirror.bazel.build/github.com/xianyi/OpenBLAS/archive/v0.3.2.tar.gz",
            "https://github.com/xianyi/OpenBLAS/archive/v0.3.2.tar.gz",
        ],
        sha256 = "e8ba64f6b103c511ae13736100347deb7121ba9b41ba82052b1a018a65c0cb15",
    )

    http_archive(
        name = "flann",
        build_file_content = _files,
        strip_prefix = "flann-1.9.1",
        urls = [
            "https://mirror.bazel.build/github.com/mariusmuja/flann/archive/1.9.1.tar.gz",
            "https://github.com/mariusmuja/flann/archive/1.9.1.tar.gz",
        ],
        sha256 = "b23b5f4e71139faa3bcb39e6bbcc76967fbaf308c4ee9d4f5bfbeceaa76cc5d3",
    )

    http_archive(
        name = "pcl",
        build_file_content = _files,
        strip_prefix = "pcl-pcl-1.8.1",
        urls = [
            "https://mirror.bazel.build/github.com/PointCloudLibrary/pcl/archive/pcl-1.8.1.tar.gz",
            "https://github.com/PointCloudLibrary/pcl/archive/pcl-1.8.1.tar.gz",
        ],
        sha256 = "5a102a2fbe2ba77c775bf92c4a5d2e3d8170be53a68c3a76cfc72434ff7b9783",
    )

    http_archive(
        name = "boost",
        build_file_content = _files,
        strip_prefix = "boost_1_68_0",
        sha256 = "da3411ea45622579d419bfda66f45cd0f8c32a181d84adfa936f5688388995cf",
        urls = [
            "https://mirror.bazel.build/dl.bintray.com/boostorg/release/1.68.0/source/boost_1_68_0.tar.gz",
            "https://dl.bintray.com/boostorg/release/1.68.0/source/boost_1_68_0.tar.gz",
        ],
    )

    http_archive(
        name = "bison",
        build_file_content = _files,
        strip_prefix = "bison-3.3",
        urls = [
            "https://mirror.bazel.build/ftp.gnu.org/gnu/bison/bison-3.3.tar.gz",
            "http://ftp.gnu.org/gnu/bison/bison-3.3.tar.gz",
        ],
        sha256 = "fdeafb7fffade05604a61e66b8c040af4b2b5cbb1021dcfe498ed657ac970efd",
    )

    http_archive(
        name = "apache_httpd",
        build_file_content = _files,
        strip_prefix = "httpd-2.4.39",
        urls = [
            "https://mirror.bazel.build/www-us.apache.org/dist/httpd/httpd-2.4.39.tar.gz",
            "https://www-us.apache.org/dist/httpd/httpd-2.4.39.tar.gz",
        ],
        sha256 = "8b95fe249f3a6c50aad3ca125eef3e02d619116cde242e1bc3c266b7b5c37c30",
    )

    http_archive(
        name = "pcre",
        build_file_content = _files,
        strip_prefix = "pcre-8.43",
        urls = [
            "https://mirror.bazel.build/ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz",
            "https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz",
        ],
        sha256 = "0b8e7465dc5e98c757cc3650a20a7843ee4c3edf50aaf60bb33fd879690d2c73",
    )

    http_archive(
        name = "apr",
        build_file_content = _files,
        strip_prefix = "apr-1.6.5",
        urls = [
            "https://mirror.bazel.build/www-eu.apache.org/dist//apr/apr-1.6.5.tar.gz",
            "https://www-eu.apache.org/dist//apr/apr-1.6.5.tar.gz",
        ],
        sha256 = "70dcf9102066a2ff2ffc47e93c289c8e54c95d8dda23b503f9e61bb0cbd2d105",
    )

    http_archive(
        name = "apr_util",
        build_file_content = _files,
        strip_prefix = "apr-util-1.6.1",
        urls = [
            "https://mirror.bazel.build/www-us.apache.org/dist//apr/apr-util-1.6.1.tar.gz",
            "https://www-us.apache.org/dist//apr/apr-util-1.6.1.tar.gz",
        ],
    )

    http_archive(
        name = "cmake_hello_world_variant_src",
        build_file_content = """filegroup(name = "all", srcs = glob(["**"]), visibility = ["//visibility:public"])""",
        strip_prefix = "cmake-hello-world-master",
        urls = [
            "https://mirror.bazel.build/github.com/jameskbride/cmake-hello-world/archive/master.zip",
            "https://github.com/jameskbride/cmake-hello-world/archive/master.zip",
        ],
        sha256 = "d613cf222bbb05b8cff7a1c03c37345ed33744a4ebaf3a8bfd5f56a76e25ca08",
    )

    http_archive(
        name = "gmp",
        build_file_content = _files,
        strip_prefix = "gmp-6.2.1",
        urls = [
            "https://mirror.bazel.build/gmplib.org/download/gmp/gmp-6.2.1.tar.xz",
            "https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz",
        ],
        sha256 = "fd4829912cddd12f84181c3451cc752be224643e87fac497b69edddadc49b4f2",
    )

    http_archive(
        name = "mpfr",
        build_file_content = _files,
        strip_prefix = "mpfr-4.1.0",
        urls = [
            "https://mirror.bazel.build/www.mpfr.org/mpfr-current/mpfr-4.1.0.tar.gz",
            "https://www.mpfr.org/mpfr-current/mpfr-4.1.0.tar.gz",
        ],
        sha256 = "3127fe813218f3a1f0adf4e8899de23df33b4cf4b4b3831a5314f78e65ffa2d6",
    )

    http_archive(
        name = "mpc",
        build_file_content = _files,
        strip_prefix = "mpc-1.1.0",
        urls = [
            "https://mirror.bazel.build/ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz",
            "https://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz",
        ],
        sha256 = "6985c538143c1208dcb1ac42cedad6ff52e267b47e5f970183a3e75125b43c2e",
    )

    http_archive(
        name = "libunwind",
        build_file_content = _files,
        strip_prefix = "libunwind-9165d2a150d707d3037c2045f2cdc0fabd5fee98",
        urls = [
            "https://mirror.bazel.build/github.com/libunwind/libunwind/archive/9165d2a150d707d3037c2045f2cdc0fabd5fee98.zip",
            "https://github.com/libunwind/libunwind/archive/9165d2a150d707d3037c2045f2cdc0fabd5fee98.zip",
        ],
        sha256 = "f83c604cde80a49af91345a1ff3f4558958202989fb768e6508963e24ea2524c",
    )
