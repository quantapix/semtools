load("@io_bazel_rules_docker//container:container.bzl", "container_image")
load(
    "@io_bazel_rules_docker//contrib/automatic_container_release:configs_test.bzl",
    "configs_test",
)
load("@io_bazel_rules_docker//contrib:repro_test.bzl", "container_repro_test")
load("@io_bazel_rules_docker//contrib:test.bzl", "container_test")
load(
    "@io_bazel_rules_docker//docker/toolchain_container:toolchain_container.bzl",
    "toolchain_container",
)

licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])

# Generate an intermediate image.
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

# Set up `entrypoint` and cmd in the container. These cannot be set in the
# `toolchain_container` rule as they would be consumed by intermediate
# `container_image` rule in its implementation.
# TODO(xingao): enable setting things like `entrypoint` and `cmd` in
# `toolchain_container`.
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

container_repro_test(
    name = "img_repro_test",
    image = ":image",
    workspace_file = "//:WORKSPACE",
)

configs_test(
    name = "configs_test",
    dependency_update_specs = ["deps_spec.yaml"],
)
