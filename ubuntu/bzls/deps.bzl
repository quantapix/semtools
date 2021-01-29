load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("@io_bazel_rules_docker//container:container.bzl", "container_pull")

IMAGE = struct(
    sha256 = "sha256:172b454f420ecd9efed04c6455ee901225d5809de0bb45dd5a10e5385a904341",
)

def deps():
    """Download deps"""
    excludes = native.existing_rules().keys()

    if "ubuntu1604" not in excludes:
        container_pull(
            name = "ubuntu1604",
            digest = IMAGE.sha256,
            registry = "gcr.io",
            repository = "gcp-runtimes/ubuntu_16_0_4",
        )
