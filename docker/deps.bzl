load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

DEBS_TARBALL = struct(
    revision = "1600374744",
    sha256 = "d69bc88056ea4a7ce4c5680ca84986281234a31eb0c66d08591614f24e03b432",
)

def deps():
    """Download dependencies required to use this layer."""
    excludes = native.existing_rules().keys()

    if "ubuntu1604_docker_debs" not in excludes:
        http_file(
            name = "ubuntu1604_docker_debs",
            downloaded_file_path = DEBS_TARBALL.revision + "_docker_debs.tar",
            sha256 = DEBS_TARBALL.sha256,
            urls = [
                "https://storage.googleapis.com/layer-deps/ubuntu1604/docker/debs/" + DEBS_TARBALL.revision + "_docker_debs.tar",
            ],
        )
