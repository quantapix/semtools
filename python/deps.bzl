load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

DEBS_TARBALL = struct(
    revision = "1605051103",
    sha256 = "05d9d72b6519a36e0972306601d4a3866608da32b0c4a80e23070f61ad057481",
)

def deps():
    """Download dependencies required to use this layer."""
    excludes = native.existing_rules().keys()

    if "ubuntu1604_python_debs" not in excludes:
        http_file(
            name = "ubuntu1604_python_debs",
            downloaded_file_path = DEBS_TARBALL.revision + "_python_debs.tar",
            sha256 = DEBS_TARBALL.sha256,
            urls = [
                "https://storage.googleapis.com/layer-deps/ubuntu1604/python/debs/" + DEBS_TARBALL.revision + "_python_debs.tar",
            ],
        )
