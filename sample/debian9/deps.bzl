load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load(":revisions.bzl", "DEBIAN9_TAR")

def deps():
    """Download dependencies required to use this layer."""
    excludes = native.existing_rules().keys()

    # Base Ubuntu1604 tarball.
    if "debian9_tar" not in excludes:
        http_file(
            name = "debian9_tar",
            downloaded_file_path = DEBIAN9_TAR.revision + "_rootfs.tar.gz",
            sha256 = DEBIAN9_TAR.sha256,
            urls = [
                "https://storage.googleapis.com/container-deps/debian9/tar/" + DEBIAN9_TAR.revision + "_rootfs.tar.gz",
            ],
        )
