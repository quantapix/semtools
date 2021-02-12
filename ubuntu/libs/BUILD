load("@rules_foreign_cc//for_workspace:make_build.bzl", "make_tool")
load("@rules_foreign_cc//for_workspace:ninja_build.bzl", "ninja_tool")
load("@rules_foreign_cc//for_workspace:cmake_build.bzl", "cmake_tool")

load("@rules_foreign_cc//tools/build_defs:configure.bzl", "configure_make")
load("@rules_foreign_cc//tools/build_defs:cmake.bzl", "cmake_external")
load("@rules_foreign_cc//tools/build_defs/native_tools:native_tools_toolchain.bzl", "native_tool_toolchain")

make_tool(
    name = "make_tool",
    make_srcs = "@make//:files",
    tags = ["manual"],
)

genrule(
    name="start_fifos",
    srcs = [],
    outs = ["read", "write"],
    cmd = "\n".join([
        "set -euxo pipefail",
        "rm -f $(location {}) $(location {})".format(":read", ":write"),
        "mkfifo $(location {}) $(location {})".format(":read", ":write"),
        "(",
        " cat >$(location {}) <&3 &".format(":read") +
        " (while true; do cat <$(location {}); sleep 0.1; done) >&4 &".format(":write", ":write"),
        ")",
    ]),
)

genrule(
    name="stop_fifos",
    srcs = [],
    outs = [],
    cmd = "rm -f $(location {}) $(location {})".format(":read", ":write"),
    tools = [":read", ":write"],
)

genrule(
    name = "make_wrap",
    srcs = ["fifo_r", "fifo_w"],
    outs = ["make_wrap.sh"],
    cmd = "\n".join([
        "cat << EOF > make_wrap.sh",
        "#!/bin/bash",
        "set -euxo pipefail",
        "exec 3<$(location {})".format("fifo_r"),
        "exec 4>$(location {})".format("fifo_w"),
        "MAKEFLAGS=\" -j --jobserver-fds=3,4\" $(location {}) \"$$@\"".format(":make_tool"),
        "EOF"
    ]),
    tools = [":make_tool"],
)

native_tool_toolchain(
    name = "built_make",
    # path = "make/bin/make",
    # target = ":make_tool",
    path = "make_wrap.sh",
    target = ":make_wrap",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "make_chain",
    # exec_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64",],
    toolchain = ":built_make",
    toolchain_type = "@rules_foreign_cc//tools/build_defs:make_toolchain",
)

cmake_tool(
    name = "cmake_tool",
    cmake_srcs = "@cmake//:files",
    tags = ["manual"],
)

native_tool_toolchain(
    name = "built_cmake",
    path = "cmake/bin/cmake",
    target = ":cmake_tool",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "cmake_chain",
    # exec_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64",],
    toolchain = ":built_cmake",
    toolchain_type = "@rules_foreign_cc//tools/build_defs:cmake_toolchain",
)

ninja_tool(
    name = "ninja_tool",
    ninja_srcs = "@ninja//:files",
    tags = ["manual"],
    visibility = ["//ubuntu/libs/test:__pkg__"],
)

native_tool_toolchain(
    name = "built_ninja",
    path = "ninja/ninja",
    target = ":ninja_tool",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "ninja_chain",
    # exec_compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64",],
    toolchain = ":built_ninja",
    toolchain_type = "@rules_foreign_cc//tools/build_defs:ninja_toolchain",
)

configure_make(
    name = "libz",
    lib_source = "@zlib//:files",
    visibility = ["//visibility:public"],
)

cmake_external(
    name = "libz_cmake",
    cache_entries = {
        "CMAKE_PREFIX_PATH": "/qpx",
    },
    lib_source = "@zlib//:files",
    visibility = ["//visibility:public"],
)

cmake_external(
    name = "nghttp2",
    cache_entries = {
        "ENABLE_LIB_ONLY": "on",
        "ENABLE_STATIC_LIB": "on",
    },
    cmake_options = ["-GNinja"],
    lib_source = "@nghttp2//:files",
    make_commands = [
        "ninja",
        "ninja install",
    ],
    static_libraries = ["libnghttp2.a"],
    visibility = ["//visibility:public"],
)

configure_make(
    name = "libunwind",
    autogen = True,
    configure_in_place = True,
    configure_options = [
        "--disable-coredump",
        "--disable-ptrace",
        "--disable-setjmp",
        "--disable-documentation",
        "--disable-weak-backtrace",
    ],
    lib_source = "@libunwind//:files",
    shared_libraries = ["libunwind.so"],
    static_libraries = ["libunwind.a"],
    visibility = ["//visibility:public"],
)
