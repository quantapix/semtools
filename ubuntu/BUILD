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
load("//bzls:bootstrap_image.bzl", "bootstrap_image_macro",)

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
    "DEBIAN_FRONTEND": "noninteractive",
    "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

[
  container_image(
    name = "%s" % n,
    env = UBU_ENV,
    tars = [":%s_tar" % n],
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
      ],
      env = UBU_ENV,
      installables_tar = ":%s_debs",
      installation_cleanup_commands = "apt-get clean",
  ) for n, _ in UBUS
]

dockerfile_build(
    name = "old_dkr",
    base = ":old",
    dockerfile = ":Dockerfile.ubuntu",
)

dockerfile_build(
    name = "new_dkr",
    base = ":ubuntu_18_0_4_vanilla",
    dockerfile = ":Dockerfile.ubuntu",
)


bootstrap_image_macro(
    name = "bootstrap_ubuntu_16_0_4",
    date = "20190409",
    image_tar = ":ubuntu_16_0_4_vanilla.tar",
    output_image_name = "ubuntu_16_0_4",
    packages = [
        "ca-certificates",
        "curl",
        "libc-bin",
        "netbase",
    ],
    store_location = "ubuntu/16_0_4/builds",
)

bootstrap_image_macro(
    name = "bootstrap_ubuntu_18_0_4",
    date = "20190406",
    image_tar = ":ubuntu_18_0_4_vanilla.tar",
    output_image_name = "ubuntu_18_0_4",
    packages = [
        "ca-certificates",
        "curl",
        "libc-bin",
        "netbase",
    ],
    store_location = "ubuntu/18_0_4/builds",
)


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


DEBIAN_ENV = {
    "DEBIAN_FRONTEND": "noninteractive",
    "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    "PORT": "8080",
}

container_image(
    name = "image",
    cmd = "/bin/bash",
    env = DEBIAN_ENV,
    tars = [
        # The overlay tar has to come first to actuall overwrite existing files.
        ":overlay.tar",
        "@debian9_tar//file",
    ],
)


toolchain_container(
    name = "image_intermediate",
    base = "@ubuntu1604//image",
    # Remove non-deterministic files.
    installation_cleanup_commands = "rm -f /etc/init.d/.depend.boot /etc/init.d/.depend.start /etc/init.d/.depend.stop",
    language_layers = [
        "@layer_definitions//layers/ubuntu1604/clang:clang-ltl",
        "@layer_definitions//layers/ubuntu1604/java:java-ltl",
        "@layer_definitions//layers/ubuntu1604/java:java11-ltl",
        "@layer_definitions//layers/ubuntu1604/python:python-ltl",
        "@layer_definitions//layers/ubuntu1604/bazel:bazel-ltl",
        "@layer_definitions//layers/ubuntu1604/docker:docker-ltl",
    ],
)

container_image(
    name = "image",
    base = ":image_intermediate",
    cmd = None,
    entrypoint = ["/usr/local/bin/bazel"],
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


toolchain_container(
    name = "image",
    base = "@ubuntu1604//image",
    cmd = [
        "/bin/sh",
        "-c",
        "/bin/bash",
    ],
    env = {
        "LANG": "C.UTF-8",
        "LANGUAGE": "C.UTF-8",
        "LC_ALL": "C.UTF-8",
        # PATH envvar is a special case, and currently only the one in the
        # topmost layer is set. So that we override it here to include all.
        "PATH": "$$PATH:/opt/python3.6/bin:/usr/local/go/bin",
    },
    installation_cleanup_commands = "rm -f /etc/init.d/.depend.boot /etc/init.d/.depend.start /etc/init.d/.depend.stop",
    language_layers = [
        "@layer_definitions//layers/ubuntu1604/clang:clang-ltl",
        "@layer_definitions//layers/ubuntu1604/java:java-ltl",
        "@layer_definitions//layers/ubuntu1604/java:java11-ltl",
        "@layer_definitions//layers/ubuntu1604/python:python-ltl",
        "@layer_definitions//layers/ubuntu1604/bazel:bazel-ltl",
        "@layer_definitions//layers/ubuntu1604/docker:docker-ltl",
        "@layer_definitions//layers/ubuntu1604/gcloud:gcloud-ltl",
    ],
)
