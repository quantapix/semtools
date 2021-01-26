load("@bazel_tools//tools/build_rules:test_rules.bzl",
    "rule_test",
)
load("//package_managers:bootstrap_image.bzl", "bootstrap_image_macro")

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
