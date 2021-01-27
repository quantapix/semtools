load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")
load(
    ":revisions.bzl",
    "CLANG_INSTALLER",
    "DEBS_TARBALL",
    "LIBCXX_INSTALLER",
)

CLANG_INSTALLER = struct(
    revision = "88c9162c9d47ef43a505bc5301dc626f3cd4f437",
    sha256 = "c85551b78e9ebd95bf67969a7e0c8a3387d870c508106e84d8c11208afe6922b",
)

LIBCXX_INSTALLER = struct(
    revision = "88c9162c9d47ef43a505bc5301dc626f3cd4f437",
    sha256 = "5e4fea90da1d2187f998f458a989a2db2b39d32e5e9396e99cd8d7f0efa1cdfb",
)

DEBS_TARBALL = struct(
    revision = "1605051103",
    sha256 = "caf9d75ef67494390ac85374485ee58e5621b4a5715beefce6c16a8f8462ede0",
)

def deps():
    """Download dependencies required to use this layer."""
    excludes = native.existing_rules().keys()

    # Clang
    if "ubuntu1604_clang_release" not in excludes:
        http_file(
            name = "ubuntu1604_clang_release",
            downloaded_file_path = "clang_r" + CLANG_INSTALLER.revision + ".tar.gz",
            sha256 = CLANG_INSTALLER.sha256,
            urls = ["https://storage.googleapis.com/clang-builds-stable/clang-ubuntu16_04/clang_r" + CLANG_INSTALLER.revision + ".tar.gz"],
        )

    # libcxx
    if "ubuntu1604_libcxx_release" not in excludes:
        http_file(
            name = "ubuntu1604_libcxx_release",
            downloaded_file_path = "libcxx-msan_r" + LIBCXX_INSTALLER.revision + ".tar.gz",
            sha256 = LIBCXX_INSTALLER.sha256,
            urls = ["https://storage.googleapis.com/clang-builds-stable/clang-ubuntu16_04/libcxx-msan_r" + LIBCXX_INSTALLER.revision + ".tar.gz"],
        )

    if "ubuntu1604_clang_debs" not in excludes:
        http_file(
            name = "ubuntu1604_clang_debs",
            downloaded_file_path = DEBS_TARBALL.revision + "_clang_debs.tar",
            sha256 = DEBS_TARBALL.sha256,
            urls = [
                "https://storage.googleapis.com/layer-deps/ubuntu1604/clang/debs/" + DEBS_TARBALL.revision + "_clang_debs.tar",
            ],
        )
