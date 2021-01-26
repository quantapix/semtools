load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load(":revisions.bzl", "DEBIAN10_TAR")

def deps():
    """Download dependencies required to use this layer."""
    excludes = native.existing_rules().keys()

    # Base Ubuntu1604 tarball.
    if "debian10_tar" not in excludes:
        http_file(
            name = "debian10_tar",
            downloaded_file_path = DEBIAN10_TAR.revision + "_rootfs.tar.gz",
            sha256 = DEBIAN10_TAR.sha256,
            urls = [
                "https://storage.googleapis.com/container-deps/debian10/tar/" + DEBIAN10_TAR.revision + "_rootfs.tar.gz",
            ],
        )
