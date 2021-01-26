load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

load("@io_bazel_rules_docker//container:container.bzl", "container_image",)
load("@io_bazel_rules_docker//contrib:repro_test.bzl", "container_repro_test",)
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test",)
load("@io_bazel_rules_docker//contrib/automatic_container_release:configs_test.bzl", "configs_test",)
load("@io_bazel_rules_docker//contrib/automatic_container_release:metadata_merge.bzl", "metadata_merge",)
load("@io_bazel_rules_docker//contrib/automatic_container_release:packages_metadata.bzl", "packages_metadata",)
load("@io_bazel_rules_docker//docker:docker.bzl", "docker_build",)
load("@io_bazel_rules_docker//docker/package_managers:download_pkgs.bzl", "download_pkgs",)
load("@io_bazel_rules_docker//docker/security:security_check.bzl", "security_check",)
load("@io_bazel_rules_docker//docker/toolchain_container:toolchain_container.bzl", "toolchain_container",)
load("@io_bazel_rules_docker//docker/util:run.bzl", "container_run_and_extract")

load("//bzls:dockerfile_build.bzl", "dockerfile_build",)
load("//bzls:bootstrap_image.bzl", "bootstrap_image_macro",)

licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])

UBUNTU_ENV = {
    "DEBIAN_FRONTEND": "noninteractive",
    "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

container_image(
    name = "ubuntu1804_vanilla",
    env = UBUNTU_ENV,
    tars = ["@ubuntu1804_tar//file"],
)

download_pkgs(
    name = "debs",
    image_tar = ":ubuntu1804_vanilla.tar",
    packages = [
        "ca-certificates",
        "curl",
        "libc-bin",
        "netbase",
    ],
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

toolchain_container(
    name = "image",
    base = ":ubuntu1804_vanilla.tar",
    cmd = [
        "/bin/sh",
        "-c",
    ],
    env = UBUNTU_ENV,
    installables_tar = "@ubuntu1804_debs//file",
    installation_cleanup_commands = "apt-get clean",
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

configs_test(
    name = "configs_test",
    dependency_update_specs = ["deps_spec.yaml"],
    file_update_specs = ["file_updates.yaml"],
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

pkg_tar(
    name = "overlay",
    srcs = glob(["overlay/**/*"]),
    package_dir = "/",
    strip_prefix = "overlay/",
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

UBUNTU_VERSIONS = [
    "16_0_4",
    "18_0_4",
]

dockerfile_build(
    name = "ubuntu_16_0_4",
    base = ":ubuntu_16_0_4_vanilla",
    dockerfile = ":Dockerfile.ubuntu",
)

dockerfile_build(
    name = "ubuntu_18_0_4",
    base = ":ubuntu_18_0_4_vanilla",
    dockerfile = ":Dockerfile.ubuntu",
)

genrule(
    name = "ubuntu_16_0_4_vanilla_reproducible",
    srcs = ["@ubuntu_16_0_4_tar_download//file"],
    outs = ["ubuntu_16_0_4_vanilla_reproducible.tar"],
    cmd = "cp $< temp.tar.gz && gunzip temp.tar.gz && tar --delete var/log/dpkg.log var/cache/ldconfig/aux-cache -f temp.tar && mv temp.tar $@",
)

genrule(
    name = "ubuntu_18_0_4_vanilla_reproducible",
    srcs = ["@ubuntu_18_0_4_tar_download//file"],
    outs = ["ubuntu_18_0_4_vanilla_reproducible.tar"],
    cmd = "cp $< temp.tar.gz && gunzip temp.tar.gz && tar --delete var/log/dpkg.log var/cache/ldconfig/aux-cache -f temp.tar && mv temp.tar $@",
)

[docker_build(
    name = "ubuntu_%s_vanilla" % version,
    env = UBUNTU_ENV,
    tars = [":ubuntu_%s_vanilla_reproducible" % version],
) for version in UBUNTU_VERSIONS]

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

