workspace(name = "semtools")

local_repository(name = "bazel_gazelle", path = "./bazel/libs/srcs/gazelle",)
local_repository(name = "bazel_skylib", path = "./bazel/libs/srcs/skylib",)
local_repository(name = "bazel_toolchains", path = "./bazel/libs/srcs/toolchains",)
local_repository(name = "io_bazel_rules_docker", path = "./bazel/libs/srcs/rules_docker",)
local_repository(name = "io_bazel_rules_go", path = "./bazel/libs/srcs/rules_go",)
local_repository(name = "io_bazel_rules_k8s", path = "./bazel/libs/srcs/rules_k8s",)
local_repository(name = "io_bazel_rules_rust", path = "./bazel/libs/srcs/rules_rust",)
local_repository(name = "rules_pkg", path = "./bazel/libs/srcs/rules_pkg",)
local_repository(name = "rules_python", path = "./bazel/libs/srcs/rules_python",)

[
  new_local_repository(
    name = "%s_tar" % u,
    path = "./ubuntu/pkgs/%s" % u,
    build_file_content = """
package(default_visibility = ["//visibility:public"])
exports_files(glob(["*.tar.gz"]))
""",
  ) for u in ["focal", "hirsute"]
]

load("@io_bazel_rules_docker//repositories:repositories.bzl", dkr_repos = "repositories",)
dkr_repos()
load("@io_bazel_rules_docker//repositories:deps.bzl", dkr_deps = "deps")
dkr_deps()
load("@io_bazel_rules_docker//go:image.bzl", go_imgs = "repositories",)
go_imgs()
load("@io_bazel_rules_docker//python3:image.bzl", py_imgs = "repositories",)
py_imgs()
load("@io_bazel_rules_docker//java:image.bzl", java_imgs = "repositories",)
java_imgs()
load("@io_bazel_rules_docker//rust:image.bzl", rust_imgs = "repositories",)
rust_imgs()

load("@io_bazel_rules_rust//rust:repositories.bzl", rust_repos = "rust_repositories")
rust_repos()

load(":deps.bzl", "deps")
deps()

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file",)


go_download_sdk(
    name = "go_sdk",
    sdks = {
        "linux_amd64": (
            "go1.11.4.linux-amd64.tar.gz",
            "fb26c30e6a04ad937bbc657a1b5bba92f80096af1e8ee6da6430c045a8db3a5b",
        ),
    },
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
