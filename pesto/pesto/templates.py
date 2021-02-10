#!/usr/bin/python


class T:
    COPYRIGHT = """"""
    HEADER = """
workspace(name="org_pesto")

local_repository(
    name="sys",
    path="sys",
)
local_repository(
    name="std",
    path="std",
)
local_repository(
    name="src",
    path="src",
)
local_repository(
    name="pesto",
    path="pesto",
)
local_repository(
    name="nil",
    path="nil",
)
local_repository(
    name="lib_nvidia_nccl",
    path="lib/nvidia/upstream/nccl",
)
local_repository(
    name="lib_nvidia_tensorrt",
    path="lib/nvidia/upstream/tensorrt",
)

"""
    FOOTER = """

load("@bzl_rules_closure//closure:defs.bzl", "closure_repositories")
closure_repositories(omit_clang=True, omit_com_google_protobuf=True)

load("@//cc/gcc:repo_defs.bzl", "create_cc_gcc_repos")
create_cc_gcc_repos()

load("@//cc:repo_defs.bzl", "cc_configure")
cc_configure(
    name="pesto_cc",
    stacks={
        "@sys//:bin/gcc": "sys_gcc",
        "@sys//:bin/clang": "sys_clang",
        # "@std//:bin/gcc": "std_gcc",
        # "@std//:bin/clang": "std_clang",
        # "@src//:bin/gcc": "src_gcc",
        # "@src//:bin/clang": "src_clang",
    },
)

# bind(name="cc_toolchain", actual="@pesto_cc//:toolchain")

# register_toolchains(
#     "@pesto_cc//:all"
    # "//cc/gcc:sys_gcc_toolchain",
    # "//cc/clang:sys_clang_toolchain",
# )

# load("@//:bazel/repo_defs.bzl", "create_bazel_repos")
# create_bazel_repos()

load("@//git:rule_defs.bzl", "git_info")
git_info(name="local_config_git")

load("@//tensorflow:repo_defs.bzl", "create_tensorflow_repos")
create_tensorflow_repos()

# load("@//tensorflow:std_repo_defs.bzl", "create_std_tf_repos")
# create_std_tf_repos()

"""
    REPO = """
package(default_visibility=["//visibility:public"])

licenses(["notice"])

exports_files(glob(["*.bzl"]))

load("@//:run_defs.bzl", "repo")
repo(
    root="{}",
    name="{}",
)
"""
    ROOT = """
package(default_visibility=["//visibility:public"])

licenses(["notice"])

load("@//:run_defs.bzl", "root_repo")
root_repo(root="{}")
"""
