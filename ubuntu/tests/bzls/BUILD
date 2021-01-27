load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load("@bazel_tools//tools/build_rules:test_rules.bzl", "rule_test",)
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")
load("//bzls:bootstrap_image.bzl", "bootstrap_image_macro")
load("//bzls:dockerfile_build.bzl", "dockerfile_build")

package(default_visibility = ["//visibility:public"])

bootstrap_image_macro(
    name = "bootstrap_ubuntu",
    date = "20190301",
    image_tar = "//ubuntu:ubuntu_16_0_4_vanilla.tar",
    output_image_name = "ubuntu",
    packages = [
        "curl",
        "netbase",
    ],
    store_location = "ubuntu/16_0_4/builds",
)

rule_test(
    name = "test_bootstrap_ubuntu",
    generates = [
        "bootstrap_ubuntu-layer.tar",
    ],
    rule = "bootstrap_ubuntu",
)

pkg_tar(
    name = "context",
    srcs = glob(["context/**/*"]),
    package_dir = "/",
    strip_prefix = "context/",
)

dockerfile_build(
    name = "test_image",
    base = "//debian/reproducible:debian9",
    context = ":context.tar",
    dockerfile = ":Dockerfile",
)

container_test(
    name = "dockerfile_build_test",
    configs = [":test.yaml"],
    image = ":test_image",
)

dockerfile_build(
    name = "test_image_2",
    base_tar = ":test_image.tar",
    dockerfile = ":Dockerfile.2",
)

container_test(
    name = "dockerfile_build_test_2",
    configs = [":test2.yaml"],
    image = ":test_image_2",
)
