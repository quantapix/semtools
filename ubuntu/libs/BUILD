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

native_tool_toolchain(
    name = "built_make",
    path = "make/bin/make",
    target = ":make_tool",
)

toolchain(
    name = "make_chain",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
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
)

toolchain(
    name = "cmake_chain",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":built_cmake",
    toolchain_type = "@rules_foreign_cc//tools/build_defs:cmake_toolchain",
)

ninja_tool(
    name = "ninja_tool",
    ninja_srcs = "@ninja//:files",
    tags = ["manual"],
)

native_tool_toolchain(
    name = "built_ninja",
    path = "ninja/ninja",
    target = ":ninja_tool",
)

toolchain(
    name = "ninja_chain",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":built_ninja",
    toolchain_type = "@rules_foreign_cc//tools/build_defs:ninja_toolchain",
)

cmake_external(
    name = "libz",
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
