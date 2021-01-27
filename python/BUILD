load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("@io_bazel_rules_docker//contrib/automatic_container_release:packages_metadata.bzl", "packages_metadata")
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")
load("@io_bazel_rules_docker//docker/package_managers:download_pkgs.bzl", "download_pkgs")
load(
    "@io_bazel_rules_docker//docker/toolchain_container:toolchain_container.bzl",
    "language_tool_layer",
)

licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])

exports_files(glob(["*.yaml"]))

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

# Transform the packages metadata csv produced by download_pkgs into a YAML
# file.
packages_metadata(
    name = "metadata",
    metadata_csv = ":python_debs_metadata.csv",
)

# Clean up commands to run at the end of container generation to remove any
# build specific files.
PYTHON_CLEANUP_COMMANDS = (
    "find /usr/lib/python* -name __pycache__ -exec rm -rf {} +"
)

language_tool_layer(
    name = "python-ltl",
    base = "@ubuntu1604//image",
    installables_tar = "@ubuntu1604_python_debs//file",
    installation_cleanup_commands = PYTHON_CLEANUP_COMMANDS,
    symlinks = {
        "/usr/bin/python": "/usr/bin/python2.7",
    },
)

container_test(
    name = "test",
    configs = [
        ":tests.yaml",
    ],
    image = ":python-ltl",
    verbose = True,
)
