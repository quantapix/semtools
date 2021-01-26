load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_file")

RULES_DOCKER = struct(
    commit = "a8b3c6c528271c406ab353de49c45e54a299e023",
    sha256 = "7e054932f044a2e1a3d1df9b4cdd457e18f3619bd72b03d0b3693d18ab3ea997",
)

CENTOS7_TAR = struct(
    revision = "1611257615",
    sha256 = "1295e147d86845530de9e97288d0e27264c09a55cf8b40564e9f838feb15ebba",
)

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

DEBIAN9_TAR = struct(
    revision = "1611257499",
    sha256 = "064a0a75d44fc7608b73847fca8eeba33a578719fe59ad387f4206bcb869271b",
)

def deps():
    """Download deps"""
    excludes = native.existing_rules().keys()
    if "debian9_tar" not in excludes:
        http_file(
            name = "debian9_tar",
            downloaded_file_path = DEBIAN9_TAR.revision + "_rootfs.tar.gz",
            sha256 = DEBIAN9_TAR.sha256,
            urls = [
                "https://storage.googleapis.com/container-deps/debian9/tar/" + DEBIAN9_TAR.revision + "_rootfs.tar.gz",
            ],
        )

DEBIAN10_TAR = struct(
    revision = "1611257700",
    sha256 = "882bc04fccb4888f0e0d10e37f4420b9375961f4981b1701a401936887625408",
)

def deps():
    """Download deps"""
    excludes = native.existing_rules().keys()
    if "debian10_tar" not in excludes:
        http_file(
            name = "debian10_tar",
            downloaded_file_path = DEBIAN10_TAR.revision + "_rootfs.tar.gz",
            sha256 = DEBIAN10_TAR.sha256,
            urls = [
                "https://storage.googleapis.com/container-deps/debian10/tar/" + DEBIAN10_TAR.revision + "_rootfs.tar.gz",
            ],
        )

UBUNTU1604_TAR = struct(
    revision = "1610641890",
    sha256 = "eff380c088d67af63bf85e2ee042746f4cb4134b5cba57f129503f9585e8a985",
)

DEBS_TARBALL = struct(
    revision = "1609871490",
    sha256 = "ca779575a952ac40642c40af55137dbcac096e085d34d61a3743f4d1553f20df",
)

def deps():
    """Download deps"""
    excludes = native.existing_rules().keys()
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

UBUNTU1804_TAR = struct(
    revision = "1611005600",
    sha256 = "905a6318b7d8d4ae95f7a6c51b7f45f4802d7d4f4216b47d9e80a1835c22b263",
)

DEBS_TARBALL = struct(
    revision = "1610022687",
    sha256 = "20aac14f7f4b8e3bf544fe4363f2d0118136741d9f5b8795e2fd745ac411c6d6",
)

def deps():
    """Download deps"""
    excludes = native.existing_rules().keys()
    if "ubuntu1804_tar" not in excludes:
        http_file(
            name = "ubuntu1804_tar",
            downloaded_file_path = UBUNTU1804_TAR.revision + "_ubuntu1804.tar.gz",
            sha256 = UBUNTU1804_TAR.sha256,
            urls = [
                "https://storage.googleapis.com/container-deps/ubuntu1804/tar/" + UBUNTU1804_TAR.revision + "_ubuntu1804.tar.gz",
            ],
        )
    if "ubuntu1804_debs" not in excludes:
        http_file(
            name = "ubuntu1804_debs",
            downloaded_file_path = DEBS_TARBALL.revision + "_debs.tar",
            sha256 = DEBS_TARBALL.sha256,
            urls = [
                "https://storage.googleapis.com/container-deps/ubuntu1804/debs/" + DEBS_TARBALL.revision + "_debs.tar",
            ],
        )
