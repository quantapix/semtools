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
