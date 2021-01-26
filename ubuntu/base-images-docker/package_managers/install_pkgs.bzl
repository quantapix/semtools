"""Rule for installing apt packages from a tar file into a docker image.

In addition to the base install_pkgs rule, we expose its constituents
(attr, outputs, implementation) directly so that others can use them
in their rules' implementation. The expectation in such cases is that
users will write something like:

  load(
    "@base_images_docker//package_managers:install_pkgs.bzl",
    _install = "install",
  )

  def _impl(ctx):
    ...
    return _install.implementation(ctx, ... kwarg overrides ...)

  _my_rule = rule(
      attrs = _install.attrs + {
         # My attributes, or overrides of _install.attrs defaults.
         ...
      },
      outputs = _install.outputs,
      implementation = _impl,
  )

"""

load(
    "@io_bazel_rules_docker//docker/package_managers:install_pkgs.bzl",
    _install = "install",
    _install_pkgs = "install_pkgs",
)

# Redirects all defs to implementation which has been refactored to
# @io_bazel_rules_docker//docker/package_managers:install_pkgs.bzl

install = _install
install_pkgs = _install_pkgs
