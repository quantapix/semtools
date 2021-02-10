
package(default_visibility=["//visibility:public"])

licenses(["notice"])

cc_library(name="stl")
cc_library(name="malloc")

filegroup(name="empty", srcs=[])
filegroup(name="tools", srcs=glob(["tools/**"]))

%{content}

cc_toolchain_suite(
    name="toolchain",
    toolchains={
%{mapping}
    },
)

load("@bazel_tools//tools/cpp:compiler_flag.bzl", "compiler_flag")

compiler_flag(name="compiler")
