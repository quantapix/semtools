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

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
gazelle_dependencies()

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
