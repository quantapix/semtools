load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

OPENJDK_INSTALLER = struct(
    revision = "11.29.3-ca-jdk11.0.2/zulu11.29.3-ca-jdk11.0.2-linux_x64-allmodules-90755145cb6e6418584d8603cd5fa9afbb30aecc-1549209950",
    sha256 = "460d8a4f0c0204160b48086e341b22943c9cca471b195340e75b38ae9eb33c1c",
)

OPENJDK_SRC = struct(
    revision = "11.31.11-ca-jdk11.0.3/zsrc11.31.11-jdk11.0.3",
    sha256 = "65afc25dd914a094e25b1f804160bb20849f923d9a4b7d989f885558922e8182",
)

DEBS_TARBALL = struct(
    revision = "1605198800",
    sha256 = "75b08ce5db6c4522f6a66d192a1a5a2c4d576f378945c9ff22a46f828122f549",
)

CACERTS = struct(
    revision = "1605198800",
    sha256 = "9f9c04a0d3ba952b0db068a03ac546223a3d8955786cffef5a7fc66fdff5a251",
)

def deps():
    """Download dependencies required to use this layer."""
    excludes = native.existing_rules().keys()

    # ============================ Azul OpenJDK packages ============================
    if "azul_open_jdk" not in excludes:
        http_file(
            name = "azul_open_jdk",
            downloaded_file_path = "zulu-linux.tar.gz",
            sha256 = OPENJDK_INSTALLER.sha256,
            urls = ["https://mirror.bazel.build/openjdk/azul-zulu" + OPENJDK_INSTALLER.revision + ".tar.gz"],
        )

    if "azul_open_jdk_src" not in excludes:
        http_file(
            name = "azul_open_jdk_src",
            downloaded_file_path = OPENJDK_SRC.revision.rpartition("/")[2] + ".zip",
            sha256 = OPENJDK_SRC.sha256,
            urls = ["https://mirror.bazel.build/openjdk/azul-zulu" + OPENJDK_SRC.revision + ".zip"],
        )

    if "ubuntu1604_java_debs" not in excludes:
        http_file(
            name = "ubuntu1604_java_debs",
            downloaded_file_path = DEBS_TARBALL.revision + "_java_debs.tar",
            sha256 = DEBS_TARBALL.sha256,
            urls = [
                "https://storage.googleapis.com/layer-deps/ubuntu1604/java/debs/" + DEBS_TARBALL.revision + "_java_debs.tar",
            ],
        )

    if "ubuntu1604_java_cacerts" not in excludes:
        http_file(
            name = "ubuntu1604_java_cacerts",
            downloaded_file_path = CACERTS.revision + "_cacerts.tar",
            sha256 = CACERTS.sha256,
            urls = [
                "https://storage.googleapis.com/layer-deps/ubuntu1604/java/cacerts/" + CACERTS.revision + "_cacerts.tar",
            ],
        )
