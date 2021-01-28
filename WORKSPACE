workspace(name = "semtools")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file",)
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

local_repository(name = "bazel_gazelle", path = "./bazel/libs/srcs/gazelle",)
local_repository(name = "bazel_skylib", path = "./bazel/libs/srcs/skylib",)
local_repository(name = "bazel_toolchains", path = "./bazel/libs/srcs/toolchains",)
local_repository(name = "io_bazel_rules_docker", path = "./bazel/libs/srcs/rules_docker",)
local_repository(name = "io_bazel_rules_go", path = "./bazel/libs/srcs/rules_go",)
local_repository(name = "io_bazel_rules_k8s", path = "./bazel/libs/srcs/rules_k8s",)
local_repository(name = "io_bazel_rules_rust", path = "./bazel/libs/srcs/rules_rust",)

load("@io_bazel_rules_docker//repositories:repositories.bzl", container_repositories = "repositories",)
container_repositories()

load("@io_bazel_rules_docker//repositories:deps.bzl", container_deps = "deps")
container_deps()

load("@io_bazel_rules_docker//repositories:pip_repositories.bzl", "pip_deps")
pip_deps()

load("@io_bazel_rules_docker//container:container.bzl", "container_pull",)

load("@io_bazel_rules_go//go:deps.bzl", "go_download_sdk", "go_register_toolchains", "go_rules_dependencies")
go_rules_dependencies()
go_register_toolchains()

load("@io_bazel_rules_rust//rust:repositories.bzl", "rust_repositories")
rust_repositories()

load("@io_bazel_rules_rust//:workspace.bzl", "bazel_version")
bazel_version(name = "bazel_version")

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
gazelle_dependencies()

load("@io_bazel_rules_docker//python:image.bzl", _py_image_repos = "repositories",)
_py_image_repos()

load("@io_bazel_rules_docker//java:image.bzl", _java_image_repos = "repositories",)
_java_image_repos()

load("@io_bazel_rules_docker//go:image.bzl", _go_image_repos = "repositories",)
_go_image_repos()

load(":deps.bzl", "deps")
deps()

http_file(
    name = "gcloud_gpg",
    downloaded_file_path = "gcloud_gpg",
    urls = ["https://packages.cloud.google.com/apt/doc/apt-key.gpg"],
)

http_file(
    name = "docker_gpg",
    downloaded_file_path = "docker_gpg",
    sha256 = "1500c1f56fa9e26b9b8f42452a553675796ade0807cdce11975eb98170b3a570",
    urls = ["https://download.docker.com/linux/ubuntu/gpg"],
)

http_file(
    name = "bazel_gpg",
    sha256 = "30af2ca7abfb65987cd61802ca6e352aadc6129dfb5bfc9c81f16617bc3a4416",
    urls = ["https://bazel.build/bazel-release.pub.gpg"],
)

http_file(
    name = "launchpad_openjdk_gpg",
    sha256 = "54b6274820df34a936ccc6f5cb725a9b7bb46075db7faf0ef7e2d86452fa09fd",
    urls = ["http://keyserver.ubuntu.com/pks/lookup?op=get&fingerprint=on&search=0xEB9B1D8886F44E2A"],
)

http_archive(
    name = "docker_credential_gcr",
    build_file_content = """package(default_visibility = ["//visibility:public"])
exports_files(["docker-credential-gcr"])""",
    sha256 = "3f02de988d69dc9c8d242b02cc10d4beb6bab151e31d63cb6af09dd604f75fce",
    type = "tar.gz",
    url = "https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v1.4.3/docker-credential-gcr_linux_amd64-1.4.3.tar.gz",
)

git_repository(
    name = "subpar",
    commit = "07ff5feb7c7b113eea593eb6ec50b51099cf0261",
    remote = "https://github.com/google/subpar",
)

load("@distroless//package_manager:package_manager.bzl", "package_manager_repositories",)
package_manager_repositories()

load("@distroless//package_manager:dpkg.bzl", "dpkg_list", "dpkg_src",)


#container_pull(
#    name = "debian_base",
#    digest = "sha256:00109fa40230a081f5ecffe0e814725042ff62a03e2d1eae0563f1f82eaeae9b",
#    registry = "gcr.io",
#    repository = "google-appengine/debian10",
#)
container_pull(
    name = "debian_base",
    digest = "sha256:00109fa40230a081f5ecffe0e814725042ff62a03e2d1eae0563f1f82eaeae9b",
    registry = "gcr.io",
    repository = "google-appengine/debian9",
)
container_pull(
    name = "debian_base",
    registry = "index.docker.io",
    repository = "library/debian",
    tag = "10",
)

DEB_SNAPSHOT = "20190708T153325Z"

dpkg_src(
    name = "debian_stretch",
    arch = "amd64",
    distro = "jessie",
    sha256 = "7240a1c6ce11c3658d001261e77797818e610f7da6c2fb1f98a24fdbf4e8d84c",
    snapshot = DEB_SNAPSHOT,
    url = "http://snapshot.debian.org/archive",
)
# These are needed to install debootstrap.
dpkg_list(
    name = "package_bundle",
    packages = [
        "ca-certificates",
        "debootstrap",
        "libffi6",
        "libgmp10",
        "libgnutls-deb0-28",
        "libhogweed2",
        "libicu52",
        "libidn11",
        "libnettle4",
        "libp11-kit0",
        "libpsl0",
        "libtasn1-6",
        "wget",
    ],
    sources = [
        "@debian_stretch//file:Packages.json",
    ],
)

go_download_sdk(
    name = "go_sdk",
    sdks = {
        "linux_amd64": (
            "go1.11.4.linux-amd64.tar.gz",
            "fb26c30e6a04ad937bbc657a1b5bba92f80096af1e8ee6da6430c045a8db3a5b",
        ),
    },
)

UBUNTU_MAP = {
    "16_0_4": {
        "sha256": "20c151c26c5a057a85d43bcc3dbee1d1fc536f76b84c550a1c2faa88af7727b6",
        "url": "https://storage.googleapis.com/ubuntu_tar/20190708/ubuntu-xenial-core-cloudimg-amd64-root.tar.gz",
    },
    "18_0_4": {
        "sha256": "600f663706aa8e7cb30d114daee117536545b5a580bca6a97b3cb73d72acdcee",
        "url": "https://storage.googleapis.com/ubuntu_tar/20190704/ubuntu-bionic-core-cloudimg-amd64-root.tar.gz",
    },
}

[http_file(
    name = "ubuntu_%s_tar_download" % version,
    sha256 = map["sha256"],
    urls = [map["url"]],
) for version, map in UBUNTU_MAP.items()]


http_file(
    name = "ubuntu1604_tar_latest",
    downloaded_file_path = "ubuntu1604.tar.gz",
    urls = ["https://partner-images.canonical.com/core/xenial/current/ubuntu-xenial-core-cloudimg-amd64-root.tar.gz"],
)

http_file(
    name = "ubuntu1804_tar_latest",
    downloaded_file_path = "ubuntu1804.tar.gz",
    urls = ["https://partner-images.canonical.com/core/bionic/current/ubuntu-bionic-core-cloudimg-amd64-root.tar.gz"],
)

load(":centos_rpm.bzl", "centos_rpm")
centos_rpm(
    name = "centos7_latest",
    version = 7,
)


load("//ubuntu/layers/base:deps.bzl", base_deps = "deps")
base_deps()

load("//ubuntu/layers/bazel:deps.bzl", bazel_deps = "deps")
bazel_deps()

load("//ubuntu/layers/clang:deps.bzl", clang_deps = "deps")
clang_deps()

load("//ubuntu/layers/docker:deps.bzl", docker_deps = "deps")
docker_deps()

load("//ubuntu/layers/java:deps.bzl", java_deps = "deps")
java_deps()

load("//ubuntu/layers/python:deps.bzl", python_deps = "deps")
python_deps()

load("//ubuntu/layers/go:deps.bzl", go_deps = "deps")
go_deps()


http_archive(
    name = "jetty",
    build_file = "//java:BUILD.jetty",
    sha256 = "1b9ec532cd9b94550fad655e066a1f9cc2d350a1c79daea85d5c56fdbcd9aaa8",
    strip_prefix = "jetty-distribution-9.4.22.v20191022/",
    type = "tar.gz",
    urls = ["https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/9.4.22.v20191022/jetty-distribution-9.4.22.v20191022.tar.gz"],
)

http_archive(
    name = "nodejs",
    build_file = "//nodejs:BUILD.nodejs",
    sha256 = "b51c033d40246cd26e52978125a3687df5cd02ee532e8614feff0ba6c13a774f",
    strip_prefix = "node-v14.15.4-linux-x64/",
    type = "tar.gz",
    urls = ["https://nodejs.org/dist/v14.15.4/node-v14.15.4-linux-x64.tar.gz"],
)

http_file(
    name = "busybox_amd64",
    executable = True,
    sha256 = "51fcb60efbdf3e579550e9ab893730df56b33d0cc928a2a6467bd846cdfef7d8",
    urls = ["https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64"],
)


load("//package_manager:dpkg.bzl", "dpkg_list", "dpkg_src")
load(
    "//:checksums.bzl",
    "ARCHITECTURES",
    "BASE_ARCHITECTURES",
    "DEBIAN_SECURITY_SNAPSHOT",
    "DEBIAN_SNAPSHOT",
    "SHA256s",
    "VERSIONS",
)

[
    dpkg_src(
        name = arch + "_" + name,
        arch = arch,
        distro = distro,
        sha256 = SHA256s[arch][name]["main"],
        snapshot = DEBIAN_SNAPSHOT,
        url = "https://snapshot.debian.org/archive",
    )
    for arch in ARCHITECTURES
    for (name, distro) in VERSIONS
]

[
    dpkg_src(
        name = arch + "_" + name + "_updates",
        arch = arch,
        distro = distro + "-updates",
        sha256 = SHA256s[arch][name]["updates"],
        snapshot = DEBIAN_SNAPSHOT,
        url = "https://snapshot.debian.org/archive",
    )
    for arch in ARCHITECTURES
    for (name, distro) in VERSIONS
]

[
    dpkg_src(
        name = arch + "_" + name + "_security",
        package_prefix = "https://snapshot.debian.org/archive/debian-security/{}/".format(DEBIAN_SECURITY_SNAPSHOT),
        packages_gz_url = "https://snapshot.debian.org/archive/debian-security/{}/dists/{}/updates/main/binary-{}/Packages.gz".format(DEBIAN_SECURITY_SNAPSHOT, distro, arch),
        sha256 = SHA256s[arch][name]["security"],
    )
    for arch in ARCHITECTURES
    for (name, distro) in VERSIONS
    if "security" in SHA256s[arch][name]
]

[
    dpkg_src(
        name = arch + "_" + name + "_backports",
        arch = arch,
        distro = distro + "-backports",
        sha256 = SHA256s[arch][name]["backports"],
        snapshot = DEBIAN_SNAPSHOT,
        url = "https://snapshot.debian.org/archive",
    )
    for arch in ARCHITECTURES
    for (name, distro) in VERSIONS
    if "backports" in SHA256s[arch][name]
]

[
    dpkg_list(
        name = "package_bundle_" + arch + "_debian9",
        packages = [
            "libc6",
            "base-files",
            "ca-certificates",
            "openssl",
            "libssl1.0.2",
            "libssl1.1",
            "libbz2-1.0",
            "libdb5.3",
            "libffi6",
            "libncursesw5",
            "liblzma5",
            "libexpat1",
            "libreadline7",
            "libtinfo5",
            "libsqlite3-0",
            "mime-support",
            "netbase",
            "readline-common",
            "tzdata",

            #c++
            "libgcc1",
            "libgomp1",
            "libstdc++6",

            #java
            "zlib1g",
            "libjpeg62-turbo",
            "libpng16-16",
            "liblcms2-2",
            "libfreetype6",
            "fonts-dejavu-core",
            "fontconfig-config",
            "libfontconfig1",
            "libuuid1",
            "openjdk-8-jre-headless",
            "openjdk-8-jdk-headless",
            "openjdk-11-jre-headless",
            "openjdk-11-jdk-headless",
            "libc-bin",

            #python
            "libpython2.7-minimal",
            "python2.7-minimal",
            "libpython2.7-stdlib",
            "dash",
            "libc-bin",

            #python3
            "libmpdec2",
            "libpython3.5-minimal",
            "libpython3.5-stdlib",
            "python3.5-minimal",

            #dotnet
            "libcurl3",
            "libgssapi-krb5-2",
            "libicu57",
            "liblttng-ust0",
            "libssl1.0.2",
            "libuuid1",
            "zlib1g",
            "curl",
            "libcomerr2",
            "libidn2-0",
            "libk5crypto3",
            "libkrb5-3",
            "libldap-2.4-2",
            "libldap-common",
            "libsasl2-2",
            "libnghttp2-14",
            "libpsl5",
            "librtmp1",
            "libssh2-1",
            "libkeyutils1",
            "libkrb5support0",
            "libunistring0",
            "libgnutls30",
            "libgmp10",
            "libhogweed4",
            "libidn11",
            "libnettle6",
            "libp11-kit0",
            "libffi6",
            "libtasn1-6",
            "libsasl2-modules-db",
            "libgcrypt20",
            "libgpg-error0",
            "libacl1",
            "libattr1",
            "libselinux1",
            "libpcre3",
            "libbz2-1.0",
            "liblzma5",
        ] + (["libunwind8"] if arch in BASE_ARCHITECTURES else []),
        sources = [
            "@" + arch + "_debian9_updates//file:Packages.json",
            "@" + arch + "_debian9_backports//file:Packages.json",
            "@" + arch + "_debian9//file:Packages.json",
        ] + (["@" + arch + "_debian9_security//file:Packages.json"] if arch in BASE_ARCHITECTURES else []),
    )
    for arch in ARCHITECTURES
]

[
    dpkg_list(
        name = "package_bundle_" + arch + "_debian10",
        packages = [
            "libc6",
            "base-files",
            "ca-certificates",
            "openssl",
            "libssl1.1",
            "libbz2-1.0",
            "libdb5.3",
            "libffi6",
            "liblzma5",
            "libexpat1",
            "libreadline7",
            "libsqlite3-0",
            "mime-support",
            "netbase",
            "readline-common",
            "tzdata",

            #c++
            "libgcc1",
            "libgomp1",
            "libstdc++6",

            #java
            "zlib1g",
            "libjpeg62-turbo",
            "libpng16-16",
            "liblcms2-2",
            "libfreetype6",
            "fonts-dejavu-core",
            "fontconfig-config",
            "libfontconfig1",
            "libuuid1",
            "openjdk-11-jre-headless",
            "openjdk-11-jdk-headless",
            "libc-bin",

            #python
            "dash",
            "libc-bin",
            "libpython2.7-minimal",
            "libpython2.7-stdlib",
            "python2.7-minimal",

            #python3
            "libmpdec2",
            "libpython3.7-minimal",
            "libpython3.7-stdlib",
            "libtinfo6",
            "libuuid1",
            "libncursesw6",
            "python3-distutils",
            "python3.7-minimal",

            #dotnet
            "libcurl4",
            "libgssapi-krb5-2",
            "libicu63",
            "liblttng-ust0",
            "libssl1.1",
            "libuuid1",
            "zlib1g",
            "curl",
            "libcomerr2",
            "libidn2-0",
            "libk5crypto3",
            "libkrb5-3",
            "libldap-2.4-2",
            "libldap-common",
            "libsasl2-2",
            "libnghttp2-14",
            "libpsl5",
            "librtmp1",
            "libssh2-1",
            "libkeyutils1",
            "libkrb5support0",
            "libunistring2",
            "libgnutls30",
            "libgmp10",
            "libhogweed4",
            "libidn11",
            "libnettle6",
            "libp11-kit0",
            "libffi6",
            "libtasn1-6",
            "libsasl2-modules-db",
            "libgcrypt20",
            "libgpg-error0",
            "libacl1",
            "libattr1",
            "libselinux1",
            "libpcre3",
            "libbz2-1.0",
            "liblzma5",
        ] + (["libunwind8"] if arch in BASE_ARCHITECTURES else []),
        sources = [
            "@" + arch + "_debian10_security//file:Packages.json",
            "@" + arch + "_debian10_updates//file:Packages.json",
            "@" + arch + "_debian10//file:Packages.json",
        ],
    )
    for arch in ARCHITECTURES
]

