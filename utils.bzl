"""Utils"""

def _impl(ctx):

  ctx.actions.run_shell(
    inputs = ctx.files.srcs,
    outputs = [ctx.outputs.executable],
    command = "\n".join(["echo echo $(realpath \"%s\") >> %s" % (f.path,
              ctx.outputs.executable.path) for f in ctx.files.srcs]),
    execution_requirements = {
        "no-sandbox": "1",
        "no-cache": "1",
        "no-remote": "1",
        "local": "1",
    },
  )

echo_full_path = rule(
    implementation=_impl,
    executable=True,
    attrs={
      "srcs": attr.label_list(allow_files=True),
    }
)