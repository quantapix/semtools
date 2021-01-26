load("@io_bazel_rules_docker//docker:docker.bzl",
    "docker_build",
)

"""Rule for building debootstrap rootfs tarballs."""

def _impl(ctx):
    # Strip off the '.tar'
    image_name = ctx.attr._builder_image.label.name.split('.', 1)[0]
    # docker_build rules always generate an image named 'bazel/$package:$name'.
    builder_image_name = "bazel/%s:%s" % (ctx.attr._builder_image.label.package,
                                          image_name)

    # Generate a shell script to run the build.
    build_contents = """\
#!/bin/bash
set -ex

# Execute the loader script.
{0}
# Run the builder image.
cid=$(docker run -d --privileged {1} {2} {3})
docker attach $cid
# Copy out the rootfs.
docker cp $cid:/workspace/rootfs.tar.gz {4}

# Cleanup
docker rm $cid
 """.format(ctx.executable._builder_image.path,
            builder_image_name,
            ctx.attr.variant,
            ctx.attr.distro,
            ctx.outputs.out.path)
    script = ctx.actions.declare_file(ctx.label.name + ".build")
    ctx.file_action(
        output=script,
        content=build_contents
    )

    ctx.actions.run(
        outputs=[ctx.outputs.out],
        inputs=ctx.attr._builder_image.files.to_list() +
        ctx.attr._builder_image.data_runfiles.files.to_list() + ctx.attr._builder_image.default_runfiles.files.to_list(),
        executable=script,
    )

    return struct()

debootstrap = rule(
    attrs = {
        "variant": attr.string(
            default = "minbase",
        ),
        "distro": attr.string(
            default = "stretch",
        ),
        "_builder_image": attr.label(
            default = Label("//debian/reproducible:builder"),
            allow_single_file = True,
            executable = True,
            cfg = "target",
        ),
    },
    executable = False,
    outputs = {
        "out": "%{name}.tar.gz",
    },
    implementation = _impl,
)

def debootstrap_image(name, variant="minbase", distro="stretch", overlay_tar="", env=None):
    if not env:
        env = {}
    rootfs = "%s.rootfs" % name
    debootstrap(
        name=rootfs,
        variant=variant,
        distro=distro,
    )
    tars = [rootfs]
    if overlay_tar:
        # The overlay tar has to come first to actuall overwrite existing files.
        tars.insert(0, overlay_tar)
    docker_build(
        name=name,
        tars=tars,
        env=env,
        cmd="/bin/bash",
    )
