load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

BAZEL_INSTALLER = struct(
    revision = "4.0.0",
    sha256 = "bd7a3a583a18640f58308c26e654239d412adaa833b6b6a7b57a216ab62fabc2",
)

DEBS_TARBALL = struct(
    revision = "1608132805",
    sha256 = "7ed2d4869f19c11d8c39345bd75f908a51410bf4e512e9fc368ad0c2bbf43e28",
)

def deps():
    """Download deps"""
    excludes = native.existing_rules().keys()

    if "ubuntu1604_bazel_installer" not in excludes:
        http_file(
            name = "ubuntu1604_bazel_installer",
            downloaded_file_path = "bazel-installer.sh",
            sha256 = BAZEL_INSTALLER.sha256,
            urls = [
                "https://releases.bazel.build/" + BAZEL_INSTALLER.revision + "/release/bazel-" + BAZEL_INSTALLER.revision + "-installer-linux-x86_64.sh",
                "https://github.com/bazelbuild/bazel/releases/download/" + BAZEL_INSTALLER.revision + "/bazel-" + BAZEL_INSTALLER.revision + "-installer-linux-x86_64.sh",
            ],
        )

    if "ubuntu1604_bazel_debs" not in excludes:
        http_file(
            name = "ubuntu1604_bazel_debs",
            downloaded_file_path = DEBS_TARBALL.revision + "_bazel_debs.tar",
            sha256 = DEBS_TARBALL.sha256,
            urls = [
                "https://storage.googleapis.com/layer-deps/ubuntu1604/bazel/debs/" + DEBS_TARBALL.revision + "_bazel_debs.tar",
            ],
        )
