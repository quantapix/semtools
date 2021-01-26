load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load(":revisions.bzl", "DEBS_TARBALL", "UBUNTU1604_TAR")

def deps():
    """Download dependencies required to use this layer."""
    excludes = native.existing_rules().keys()

    # Base Ubuntu1604 tarball.
    if "ubuntu1604_tar" not in excludes:
        http_file(
            name = "ubuntu1604_tar",
            downloaded_file_path = UBUNTU1604_TAR.revision + "_ubuntu1604.tar.gz",
            sha256 = UBUNTU1604_TAR.sha256,
            urls = [
                "https://storage.googleapis.com/container-deps/ubuntu1604/tar/" + UBUNTU1604_TAR.revision + "_ubuntu1604.tar.gz",
            ],
        )

    if "ubuntu1604_debs" not in excludes:
        http_file(
            name = "ubuntu1604_debs",
            downloaded_file_path = DEBS_TARBALL.revision + "_debs.tar",
            sha256 = DEBS_TARBALL.sha256,
            urls = [
                "https://storage.googleapis.com/container-deps/ubuntu1604/debs/" + DEBS_TARBALL.revision + "_debs.tar",
            ],
        )
