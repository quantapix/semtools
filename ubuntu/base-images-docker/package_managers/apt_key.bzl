load(
    "@io_bazel_rules_docker//docker/package_managers:apt_key.bzl",
    _add_apt_key = "add_apt_key",
    _key = "key",
)

key = _key
add_apt_key = _add_apt_key
