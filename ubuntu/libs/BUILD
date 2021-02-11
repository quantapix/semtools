load("@rules_foreign_cc//for_workspace:make_build.bzl", "make_tool")
load("@rules_foreign_cc//for_workspace:ninja_build.bzl", "ninja_tool")
load("@rules_foreign_cc//for_workspace:cmake_build.bzl", "cmake_tool")

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
    visibility = ["//visibility:public"],
)

toolchain(
    name = "make_toolchain",
    exec_compatible_with = [
        #"@platforms//os:linux",
        "@platforms//os:macos",
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
    visibility = ["//visibility:public"],
)

toolchain(
    name = "cmake_toolchain",
    exec_compatible_with = [
        #"@platforms//os:linux",
        "@platforms//os:macos",
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
    visibility = ["//visibility:public"],
)

toolchain(
    name = "ninja_toolchain",
    exec_compatible_with = [
        #"@platforms//os:linux",
        "@platforms//os:macos",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":built_ninja",
    toolchain_type = "@rules_foreign_cc//tools/build_defs:ninja_toolchain",
)

cmake_external(
    name = "libz",
    cache_entries = {
        # fictive prefix to test prefix merging
        "CMAKE_PREFIX_PATH": "/bac/def",
    },
    lib_source = "@zlib//:files",
)
