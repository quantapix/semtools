load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

GO_INSTALLER = struct(
    revision = "1.15.5",
    sha256 = "9a58494e8da722c3aef248c9227b0e9c528c7318309827780f16220998180a0d",
)

def deps():
    """Download dependencies required to use this layer."""
    excludes = native.existing_rules().keys()

    if "go_release" not in excludes:
        http_file(
            name = "go_release",
            downloaded_file_path = "go" + GO_INSTALLER.revision + ".linux-amd64.tar.gz",
            sha256 = GO_INSTALLER.sha256,
            urls = ["https://storage.googleapis.com/golang/go" + GO_INSTALLER.revision + ".linux-amd64.tar.gz"],
        )
