workspace(name = "ubuntu")

load(
    "@bazel_tools//tools/build_defs/repo:http.bzl",
    "http_archive",
)

http_archive(
    name = "io_bazel_rules_docker",
    sha256 = "feb53c560be2f97b7d02b23a1738a3154ba89fe630f09a7a838dcad38731b0b8",
    strip_prefix = "rules_docker-faaa10a72fa9abde070e2a20d6046e9f9b849e9a",
    urls = ["https://github.com/bazelbuild/rules_docker/archive/faaa10a72fa9abde070e2a20d6046e9f9b849e9a.tar.gz"],
)

load(":revisions.bzl", "LAYER_DEFINITIONS")

http_archive(
    name = "layer_definitions",
    sha256 = LAYER_DEFINITIONS.sha256,
    strip_prefix = "layer-definitions-" + LAYER_DEFINITIONS.commit,
    urls = ["https://github.com/GoogleCloudPlatform/layer-definitions/archive/" + LAYER_DEFINITIONS.commit + ".tar.gz"],
)

load(
    "@io_bazel_rules_docker//repositories:repositories.bzl",
    container_repositories = "repositories",
)

container_repositories()

load("@io_bazel_rules_docker//repositories:deps.bzl", container_deps = "deps")

container_deps()

load("@io_bazel_rules_docker//repositories:pip_repositories.bzl", "pip_deps")

pip_deps()

load("@layer_definitions//layers/ubuntu1604/base:deps.bzl", ubuntu1604_base_deps = "deps")

ubuntu1604_base_deps()

load("@layer_definitions//layers/ubuntu1604/bazel:deps.bzl", bazel_deps = "deps")

bazel_deps()

load("@layer_definitions//layers/ubuntu1604/clang:deps.bzl", clang_deps = "deps")

clang_deps()

load("@layer_definitions//layers/ubuntu1604/docker:deps.bzl", docker_deps = "deps")

docker_deps()

load("@layer_definitions//layers/ubuntu1604/java:deps.bzl", java8_deps = "deps")

java8_deps()

load("@layer_definitions//layers/ubuntu1604/python:deps.bzl", python_deps = "deps")

python_deps()