workspace(name = "semtools")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

"""
git_repository(name = "bazel_gazelle", remote = "./bazel/libs/upstream/gazelle", branch = "master")
git_repository(name = "bazel_skylib", remote = "./bazel/libs/upstream/skylib", branch = "master")
git_repository(name = "bazel_toolchains", remote = "./bazel/libs/upstream/toolchains", branch = "master")
git_repository(name = "io_bazel_rules_docker", remote = "./bazel/libs/upstream/rules_docker", branch = "master")
git_repository(name = "io_bazel_rules_go", remote = "./bazel/libs/upstream/rules_go", branch = "master")
git_repository(name = "io_bazel_rules_k8s", remote = "./bazel/libs/upstream/rules_k8s", branch = "master")
git_repository(name = "io_bazel_rules_rust", remote = "./bazel/libs/upstream/rules_rust", branch = "master")
git_repository(name = "rules_pkg", remote = "./bazel/libs/upstream/rules_pkg", branch = "master")
"""
git_repository(name = "rules_python", remote = "/Users/qpix/clone/semtools/bazel/libs/upstream/rules_python", branch = "master", verbose = True)

load("@//python:workspace.bzl", "python_deps")
python_deps()
