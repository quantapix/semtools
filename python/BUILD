# load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
# load("@io_bazel_rules_docker//contrib/automatic_container_release:packages_metadata.bzl", "packages_metadata")
# load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")
# load("@io_bazel_rules_docker//docker/package_managers:download_pkgs.bzl", "download_pkgs")
# load("@io_bazel_rules_docker//docker/toolchain_container:toolchain_container.bzl", "language_tool_layer",)
load("@rules_python//python:defs.bzl", "py_runtime", "py_runtime_pair", "py_binary", "py_test")

package(default_visibility=["//visibility:public"])
licenses(["notice"])

exports_files(glob(["*.bzl"]) + glob(["*.yaml"]))

py_runtime(
    name = "py2_runtime",
    files = ["@python2//:files"],
    interpreter = "@python2//:qpx_bin",
    python_version = "PY2",
)

py_runtime(
    name = "py3_runtime",
    files = ["@python3//:files"],
    interpreter = "@python3//:qpx_bin",
    python_version = "PY3",
)

py_runtime_pair(
    name = "runtime_pair",
    py2_runtime = ":py2_runtime",
    py3_runtime = ":py3_runtime",
)

toolchain(
    name = "py_toolchain",
    toolchain = ":runtime_pair",
    toolchain_type = "@bazel_tools//tools/python:toolchain_type",
)

"""
bzl_library(
    name = "lib",
    srcs = glob(["*.bzl"]),
)

download_pkgs(
    name = "python_debs",
    image_tar = "@ubuntu1604//image",
    packages = [
        "python-dev",
        "python-setuptools",
        "python3-dev",
        "software-properties-common",
    ],
)

packages_metadata(
    name = "metadata",
    metadata_csv = ":python_debs_metadata.csv",
)

PYTHON_CLEANUP_COMMANDS = (
    "find /usr/lib/python* -name __pycache__ -exec rm -rf {} +"
)

language_tool_layer(
    name = "py_layer",
    base = "@ubuntu1604//image",
    installables_tar = "@ubuntu1604_python_debs//file",
    installation_cleanup_commands = PYTHON_CLEANUP_COMMANDS,
    symlinks = {
        "/usr/bin/python": "/usr/bin/python2.7",
    },
)

container_test(
    name = "test",
    configs = [":tests.yaml",],
    image = ":py_layer",
    verbose = True,
)

# load("@//:run_defs.bzl", "repo")
# repo(root="/home/qpix/clone/pesto", name="python",)
"""