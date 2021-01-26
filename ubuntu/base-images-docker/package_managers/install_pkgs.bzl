load("@io_bazel_rules_docker//docker/package_managers:install_pkgs.bzl",
    _install = "install",
    _install_pkgs = "install_pkgs",
)

install = _install
install_pkgs = _install_pkgs
