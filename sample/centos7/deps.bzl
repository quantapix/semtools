load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load(":revisions.bzl", "CENTOS7_TAR")

def deps():
    excludes = native.existing_rules().keys()
    if "centos7_tar" not in excludes:
        http_file(
            name = "centos7_tar",
            downloaded_file_path = CENTOS7_TAR.revision + "_layer.tar",
            sha256 = CENTOS7_TAR.sha256,
            urls = [
                "https://storage.googleapis.com/container-deps/centos7/tar/" + CENTOS7_TAR.revision + "_layer.tar",
            ],
        )
