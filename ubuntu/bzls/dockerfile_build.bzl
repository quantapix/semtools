load("@io_bazel_rules_docker//container:container.bzl", "container_image")

def _impl(ctx):
    dockerfile_path = ctx.file.dockerfile.path
    if ctx.file.context:
        context_path = ctx.file.context.path
    else:
        context_path = ""
    unstripped_tar = ctx.actions.declare_file(ctx.label.name + ".unstripped")
    if bool(ctx.attr.base) == bool(ctx.attr.base_tar):
        fail("Please specify only one of base and base_tar")
    # Use the incremental loader if possible.
    if ctx.attr.base:
        loader = ctx.executable.base.path
        attr = ctx.attr.base
    else:
        loader = "docker load -i %s" % ctx.file.base_tar.path
        attr = ctx.attr.base_tar
    # Strip off the '.tar'
    base_image = attr.label.name.split(".", 1)[0]
    # docker_build rules always generate an image named 'bazel/$package:$name'.
    base_image_name = "bazel/%s:%s" % (
        attr.label.package,
        base_image,
    )
    # Generate a shell script to run the build.
    build_contents = """\
#!/bin/bash
set -e
# Load the base image
{base_loader}
context={context}
# Setup a tmpdir context
tmpdir=$(mktemp -d)
if [[ ! -z $context ]]; then
    tar -xf $context -C "$tmpdir"
fi
# Template out the FROM line.
cat {dockerfile} | sed "s|FROM.*|FROM {base_name}|g" > "$tmpdir"/Dockerfile
# Perform the build in the context
docker build -t {tag} "$tmpdir"
# Copy out the rootfs.
docker save {tag} > {output}
 """.format(
        base_loader = loader,
        base_name = base_image_name,
        dockerfile = dockerfile_path,
        context = context_path,
        tag = "bazel/%s:%s" % (ctx.label.package, ctx.label.name),
        output = unstripped_tar.path,
    )
    script = ctx.actions.declare_file(ctx.label.name + ".build")
    ctx.actions.write(
        output = script,
        content = build_contents,
    )
    inputs = (attr.files.to_list() + ctx.attr.dockerfile.files.to_list() +
              attr.data_runfiles.files.to_list() + attr.default_runfiles.files.to_list())
    if ctx.attr.context:
        inputs += ctx.attr.context.files.to_list()
    ctx.actions.run(
        outputs = [unstripped_tar],
        inputs = inputs,
        executable = script,
        mnemonic = "BuildTar",
    )
    ctx.actions.run(
        outputs = [ctx.outputs.out],
        inputs = [unstripped_tar],
        executable = ctx.executable._config_stripper,
        arguments = ["--in_tar_path=%s" % unstripped_tar.path, "--out_tar_path=%s" % ctx.outputs.out.path],
        mnemonic = "StripTar",
    )
    return struct()

_dockerfile_build = rule(
    attrs = {
        "base": attr.label(
            allow_single_file = True,
            executable = True,
            cfg = "target",
        ),
        "base_tar": attr.label(
            allow_single_file = True,
            cfg = "target",
        ),
        "dockerfile": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "context": attr.label(
            allow_single_file = True,
        ),
        "_config_stripper": attr.label(
            cfg = "host",
            executable = True,
            default = "@io_bazel_rules_docker//docker/util:config_stripper",
        ),
    },
    executable = False,
    outputs = {
        "out": "%{name}.tar",
    },
    implementation = _impl,
)

def dockerfile_build(name, *args, **kwargs):
    intermediate_name = "%s-intermediate" % name
    _dockerfile_build(
        name = intermediate_name,
        *args,
        **kwargs
    )
    container_image(
        name = name,
        base = intermediate_name + ".tar",
    )
