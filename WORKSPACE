workspace(name = "semtools")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(name = "bazel_gazelle", remote = "/Users/qpix/clone/semtools/bazel/libs/upstream/gazelle", branch = "master")
git_repository(name = "bazel_skylib", remote = "/Users/qpix/clone/semtools/bazel/libs/upstream/skylib", branch = "master")
git_repository(name = "bazel_toolchains", remote = "/Users/qpix/clone/semtools/bazel/libs/upstream/toolchains", branch = "master")
git_repository(name = "io_bazel_rules_docker", remote = "/Users/qpix/clone/semtools/bazel/libs/upstream/rules_docker", branch = "master")
git_repository(name = "io_bazel_rules_go", remote = "/Users/qpix/clone/semtools/bazel/libs/upstream/rules_go", branch = "master")
git_repository(name = "io_bazel_rules_k8s", remote = "/Users/qpix/clone/semtools/bazel/libs/upstream/rules_k8s", branch = "master")
git_repository(name = "io_bazel_rules_rust", remote = "/Users/qpix/clone/semtools/bazel/libs/upstream/rules_rust", branch = "master")
git_repository(name = "rules_cc", remote = "/Users/qpix/clone/semtools/bazel/libs/upstream/rules_cc", branch = "master")
git_repository(name = "rules_foreign_cc", remote = "/Users/qpix/clone/semtools/bazel/libs/upstream/rules_foreign_cc", branch = "master")
git_repository(name = "rules_pkg", remote = "/Users/qpix/clone/semtools/bazel/libs/upstream/rules_pkg", branch = "master")
git_repository(name = "rules_python", remote = "/Users/qpix/clone/semtools/bazel/libs/upstream/rules_python", branch = "master")

load("@bazel_skylib//:workspace.bzl", skylib_deps = "bazel_skylib_workspace")
skylib_deps()

load("@//ubuntu/libs:workspace.bzl", "ubuntu_libs_deps")
ubuntu_libs_deps()

load("@//python:workspace.bzl", "python_deps")
python_deps()
