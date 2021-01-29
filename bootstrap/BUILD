load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

load("@io_bazel_rules_docker//container:container.bzl", "container_image",)
load("@io_bazel_rules_docker//contrib:repro_test.bzl", "container_repro_test",)
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test",)
load("@io_bazel_rules_docker//contrib/automatic_container_release:metadata_merge.bzl", "metadata_merge",)
load("@io_bazel_rules_docker//contrib/automatic_container_release:packages_metadata.bzl", "packages_metadata",)
load("@io_bazel_rules_docker//docker/package_managers:download_pkgs.bzl", "download_pkgs",)
load("@io_bazel_rules_docker//docker/security:security_check.bzl", "security_check",)
load("@io_bazel_rules_docker//docker/toolchain_container:toolchain_container.bzl", "toolchain_container",)
load("@io_bazel_rules_docker//docker/util:run.bzl", "container_run_and_extract")

# load("@rules_python//python:defs.bzl", xxx)

load("//bzls:dockerfile_build.bzl", "dockerfile_build",)

licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])

bzl_library(
    name = "lib",
    srcs = glob(["*.bzl"]),
)

pkg_tar(
    name = "overlay",
    srcs = glob(["overlay/**/*"]),
    package_dir = "/",
    strip_prefix = "overlay/",
)

UBUS = [
  ("old", "focal"), 
  ("new", "hirsute"),
]

[
  genrule(
    name = "%s_tar" % n,
    srcs = ["@%s_tar//:ubuntu-%s-core-cloudimg-amd64-root.tar.gz"] % (u, u),
    outs = ["%s.tar" % n],
    cmd = "cp $< temp.tar.gz && gunzip temp.tar.gz && tar --delete var/log/dpkg.log var/cache/ldconfig/aux-cache -f temp.tar && mv temp.tar $@",
  ) for n, u in UBUS
]

UBU_ENV = {
    "LANG": "C.UTF-8",
    "LANGUAGE": "C.UTF-8",
    "LC_ALL": "C.UTF-8",
    "DEBIAN_FRONTEND": "noninteractive",
    "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

[
  container_image(
    name = "%s" % n,
    env = UBU_ENV,
    tars = [
      ":overlay.tar",
      ":%s_tar" % n,
    ],
    # cmd = "/bin/bash",
  ) for n, _ in UBUS
]

[
  download_pkgs(
      name = "%s_debs" % n,
      image_tar = ":%s_tar" % n,
      packages = [
          "ca-certificates",
          "curl",
          "libc-bin",
          "netbase",
      ],
  ) for n, _ in UBUS
]

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
  dockerfile_build(
      name = "%s_dkr" % s,
      base = ":%s" % s,
      dockerfile = ":Dockerfile.ubuntu",
  ) for n, _ in UBUS
]

security_check(
    name = "security_metadata",
    image = "gcr.io/gcp-runtimes/ubuntu_18_0_4:latest",
)

packages_metadata(
    name = "debs_metadata",
    metadata_csv = ":debs_metadata.csv",
)

metadata_merge(
    name = "metadata",
    srcs = [
        ":debs_metadata.yaml",
        ":security_metadata.yaml",
    ],
)

container_test(
    name = "image-test",
    configs = [":tests.yaml"],
    image = ":image",
    verbose = True,
)

container_repro_test(
    name = "img_repro_test",
    image = ":image",
    workspace_file = "//:WORKSPACE",
)



toolchain_container(
    name = "builder",
    base = "@debian_base//image",
    files = [":mkimage.sh"],
    packages = ["debootstrap"],
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

container_test(
    name = "image-test",
    configs = [
        ":tests.yaml",
        "@layer_definitions//layers/ubuntu1604/base:tests.yaml",
        "@layer_definitions//layers/ubuntu1604/bazel:tests.yaml",
        "@layer_definitions//layers/ubuntu1604/clang:tests.yaml",
        "@layer_definitions//layers/ubuntu1604/docker:tests.yaml",
        "@layer_definitions//layers/ubuntu1604/java:tests.yaml",
        "@layer_definitions//layers/ubuntu1604/python:tests.yaml",
    ],
    image = ":image",
    verbose = True,
)


