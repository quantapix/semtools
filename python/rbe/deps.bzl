load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load("@io_bazel_rules_docker//container:container.bzl", "container_pull")

PY3_IMAGE = struct(
    sha256 = "sha256:fc9d9f429bf75b8369f7894b7eb24098418050557b889f4b02aa4c93fdb5e161",
)

DEBS_TARBALL = struct(
    revision = "1605051103",
    sha256 = "6e325925ec4ba5995526fded174a7ed684aa22230f1c773fa3f87c03ab37270d",
)

def deps():
    """Download dependencies required to use this layer."""
    excludes = native.existing_rules().keys()

    if "ubuntu1604_python3" not in excludes:
        container_pull(
            name = "ubuntu1604_python3",
            digest = PY3_IMAGE.sha256,
            registry = "l.gcr.io",
            repository = "google/python",
        )

    if "ubuntu1604_python_rbe_debs" not in excludes:
        http_file(
            name = "ubuntu1604_python_rbe_debs",
            downloaded_file_path = DEBS_TARBALL.revision + "_python_rbe_debs.tar",
            sha256 = DEBS_TARBALL.sha256,
            urls = [
                "https://storage.googleapis.com/layer-deps/ubuntu1604/python_rbe/debs/" + DEBS_TARBALL.revision + "_python_rbe_debs.tar",
            ],
        )
