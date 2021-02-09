load("@io_bazel_rules_docker//docker/package_managers:download_pkgs.bzl", "download_pkgs",)
load("@io_bazel_rules_docker//docker/package_managers:install_pkgs.bzl", "install_pkgs")
load("@io_bazel_rules_docker//container:container.bzl", "container_image", "container_push")

load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

load("@io_bazel_rules_docker//contrib:repro_test.bzl", "container_repro_test",)
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test",)
load("@io_bazel_rules_docker//contrib/automatic_container_release:metadata_merge.bzl", "metadata_merge",)
load("@io_bazel_rules_docker//contrib/automatic_container_release:packages_metadata.bzl", "packages_metadata",)
load("@io_bazel_rules_docker//docker/security:security_check.bzl", "security_check",)
load("@io_bazel_rules_docker//docker/toolchain_container:toolchain_container.bzl", "toolchain_container",)
load("@io_bazel_rules_docker//docker/util:run.bzl", "container_run_and_extract")

# load("@rules_python//python:defs.bzl", xxx)

load("//bzls:dockerfile_build.bzl", "dockerfile_build",)

licenses(["notice"])

package(default_visibility = ["//visibility:public"])

download_pkgs(
    name = "debs",
    image_tar = "@focal//image",
    packages = [
        "ca-certificates",
        "curl",
        "netbase",
        "tzdata",
        "wget",
    ],
)

install_pkgs(
    name = "base",
    image_tar = "@focal//image",
    installables_tar = ":debs.tar",
    installation_cleanup_commands = "rm -rf /var/lib/apt/lists/*",
    output_image_name = "base",
)

UBU_ENV = {
    "DEBIAN_FRONTEND": "noninteractive",
    "LANG": "C.UTF-8",
    "LANGUAGE": "C.UTF-8",
    "LC_ALL": "C.UTF-8",
    "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

container_image(
    name = "image",
    base = ":base.tar",
    env = UBU_ENV,
)

container_test(
    name = "image_test",
    configs = ["//test:bootstrap.yaml"],
    image = ":image",
)

dockerfile_build(
    name = "%s_dkr" % s,
    base = ":%s" % s,
    dockerfile = ":Dockerfile.ubuntu",
)

container_test(
    name = "docker_test",
    configs = ["//test:bootstrap.yaml"],
    driver = "tar",
    image = "@extended_alpine_dockerfile//image:dockerfile_image",
)

REG = "localhost:5000"
# REG = "qpx.reg"
TAG = "bzl"

container_push(
    name = "boot",
    image = ":image",
    format = "Docker",
    registry = REG,
    repository = "boot",
    tag = TAG,
)

container_run_and_extract(
    name = "rootfs",
    commands = [
        " ".join([
            "/mkimage.sh",
            "minbase",
            "stretch",
        ]),
    ],
    docker_run_flags = ["--privileged"],
    extract_file = "/workspace/rootfs.tar.gz",
    image = ":builder.tar",
)


[
  toolchain_container(
      name = "%s_tlc" % n,
      base = ":%s" % n,
      cmd = [
          "/bin/sh",
          "-c",
          "/bin/bash",
      ],
      env = UBU_ENV,
      installables_tar = ":%s_debs",
      installation_cleanup_commands = "apt-get clean",
      # installation_cleanup_commands = "rm -f /etc/init.d/.depend.boot /etc/init.d/.depend.start /etc/init.d/.depend.stop",
      language_layers = [
        # "@//clang:clang-ltl",
        # "@//java:java11-ltl",
        # "@//python:python-ltl",
        # "@//bazel:bazel-ltl",
        # "@//docker:docker-ltl",
      ],
  ) for n, _ in UBUS
]

[
  container_image(
      name = "%s_dev" % n,
      base = ":%s_tlc" % n,
      cmd = None,
      entrypoint = ["/usr/local/bin/bazel"],
  ) for n, _ in UBUS
]

[
]


toolchain_container(
    name = "builder",
    base = "@debian_base//image",
    files = [":mkimage.sh"],
    packages = ["debootstrap"],
)
