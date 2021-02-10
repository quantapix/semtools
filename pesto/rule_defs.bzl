def _git_info(ctx):
    repo = "@tensorflow"
    root = str(ctx.path(Label("{}//:BUILD".format(repo))))[:-len("BUILD")]
    script = Label("{}//tensorflow/tools/git:gen_git_source.py".format(repo))
    r = ctx.execute([
        "test",
        "-f",
        "{}/.git/logs/HEAD".format(root),
    ])
    if r.return_code == 0:
        ctx.path(Label("//:.git/HEAD"))
    r = ctx.execute(
        [
            "python",  # ctx.path(Label("@sys//:python")),
            ctx.path(script),
            "--configure",
            root,
            "--gen_root_path",
            ctx.path("gen"),
        ],
        quiet=False,
    )
    if not r.return_code == 0:
        red = "\033[0;31m"
        no_color = "\033[0m"
        fail("{}git_info failed:{} {}\n" % (red, no_color, r.stderr))
    ctx.template("BUILD.bazel", Label("@git//:BUILD.tpl"))


git_info = repository_rule(implementation=_git_info)

PESTO_ROOT = "PESTO_ROOT"

Config = provider("pesto_config")


def _pesto_root_repo(ctx):
    r = str(ctx.path(Label("//:BUILD.bazel")))[:-len("BUILD.bazel")]
    r = ctx.os.environ.get(PESTO_ROOT, r)

    script = ctx.path(Label("@pesto//pesto:gen_git_source.py"))
    generated_files_path = ctx.path("gen")

    r = ctx.execute(
        [
            str(ctx.which("python")),
            script,
            "--configure",
            # root_path,
            "--gen_root_path",
            generated_files_path,
        ],
        quiet=False,
    )
    ctx.template("BUILD", Label("@pesto//third_party/git:BUILD.tpl"))
    if not r.return_code == 0:
        fail("pesto_configure failed: ", r.stderr)
    return [Config(root=r)]


pesto_root_repo = repository_rule(
    implementation=_pesto_root_repo,
    environ=[PESTO_ROOT],
)

bash = "bash"


def _pesto_repo(ctx):
    p = ctx.attr.path
    u = ctx.path(Label("//:" + p + "/.git")).dirname
    ctx.symlink(u, ctx.path(""))
    c = ctx.attr._root[Config]
    if not ctx.path("pesto_build").exists:
        e = ctx.os.environ
        r = ctx.path(Label("@//:BUILD.bazel")).dirname
        x = ctx.execute(
            [
                bash, "-c", """
            set -ex
            mkdir pesto_build
            {}
            """.format(ctx.attr.script.format(r + "/stock-out"))
            ],
            environment=e,
        )
        if x.return_code:
            fail("Failed _config_repo %s:\n%s" % (ctx.name, x.stderr))
    return [c]


pesto_repo = repository_rule(
    implementation=_pesto_repo,
    attrs={
        "path": attr.string(mandatory=True),
        "repo_mapping": attr.label_keyed_string_dict(),
        "_root": attr.label(default="@pesto_root", providers=[Config]),
    },
)
