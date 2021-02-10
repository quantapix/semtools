
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")


def create_cc_gcc_repos():

    http_archive(
        name="cc_gcc_isl",
        urls=["http://isl.gforge.inria.fr/isl-0.20.tar.xz"],
        sha256=
        "a5596a9fb8a5b365cb612e4b9628735d6e67e9178fae134a816ae195017e77aa",
        strip_prefix="isl-0.20",
        build_file_content="""
package(default_visibility=["//visibility:public"])
licenses(["notice"])
load("@std//:rule_defs.bzl", "sources")
sources()
""")
