
load("@bazel_tools//tools/cpp:compiler_flag.bzl", "compiler_flag")


def prep_toolchain(name):
    native.constraint_value(
        name=name,
        constraint_setting="@bazel_tools//tools/cpp:cc_compiler",
    )

    # native.cc_libc_top_alias(name="current_libc_top")
    # native.cc_toolchain_alias(name="current_cc_toolchain")
    # native.cc_host_toolchain_alias(name="current_cc_host_toolchain")

    # native.cc_library(name="malloc")
    # native.cc_library(name="stl")

    native.filegroup(
        name="cc_wrapper",
        srcs=["bin/cc_wrapper.sh"],
    )
    native.filegroup(
        name="compiler_deps",
        srcs=native.glob(["tools/**"]) + [":empty"],
    )


def create_links(pkg, links, pre=""):
    s = "@" + pkg + "//:bin/"
    pkg += "_"
    for n, t in links.items():
        t = t if t else (pre + n)
        native.filegroup(name=pkg + n, srcs=[s + t])


def create_lists(pkg, lists):
    pkg += "_"
    for n, v in lists.items():
        native.filegroup(name=pkg + n, srcs=v)


def create_toolchain(pkg, name):
    pkg += "_"
    p = ":" + pkg
    native.filegroup(
        name=pkg + "compiler_files",
        srcs=[
            p + "as",
            p + "gcc",
            p + "includes",
            "compiler_deps",
        ])

    native.filegroup(
        name=pkg + "linker_files",
        srcs=[
            p + "ar",
            p + "drivers",
            p + "ld",
            p + "libraries",
            "compiler_deps",
        ])

    native.filegroup(
        name=pkg + "all_files",
        srcs=[
            p + "compiler_files",
            p + "dwp",
            p + "gcov",
            p + "linker_files",
            p + "nm",
            p + "objcopy",
            p + "objdump",
            p + "profdata",
            p + "strip",
            p + "xray",
        ],
    )

    native.cc_toolchain(
        name="cc_" + pkg + name,
        all_files=p + "all_files",
        compiler_files=p + "compiler_files",
        cpu="k8",
        dwp_files=p + "dwp",
        dynamic_runtime_libs=[":empty"],
        linker_files=p + "linker_files",
        objcopy_files=p + "objcopy",
        static_runtime_libs=[":empty"],
        strip_files=p + "strip",
        supports_param_files=1,
    )

    native.toolchain(
        name=pkg + name + "_toolchain",
        toolchain=":cc_" + pkg + name,
        toolchain_type="@bazel_tools//tools/cpp:toolchain_type",
        exec_compatible_with=[
            "@bazel_tools//platforms:x86_64",
            "@bazel_tools//platforms:linux",
            "@//" + pkg + "tools",
        ],
        target_compatible_with=[
            "@bazel_tools//platforms:x86_64",
            "@bazel_tools//platforms:linux",
            "@//" + pkg + "tools",
        ],
    )

    native.cc_toolchain_suite(
        name="toolchain",
        toolchains={"k8|" + name: ":cc_" + pkg + name},
    )

    compiler_flag(name="compiler")
