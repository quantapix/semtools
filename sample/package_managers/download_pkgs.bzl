load("@io_bazel_rules_docker//docker/package_managers:download_pkgs.bzl",
    _download = "download",
    _download_pkgs = "download_pkgs",
)

download = _download
download_pkgs = _download_pkgs
