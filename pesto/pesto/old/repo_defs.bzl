# -*- Python -*-

bash = "bash"


def _reset_or_pull(ctx):
    c = ctx.attr.commit
    d = str(ctx.path("."))
    e = ctx.os.environ
    s = ctx.execute([
        bash, "-c", """
set -ex
(cd {}
 git reset --hard {} || (git reset --hard && git pull)
 git clean -xdf)
            """.format(d, c)
    ],
                    environment=e)
    if s.return_code:
        fail("Failed reset_or_pull %s:\n%s" % (ctx.name, s.stderr))
    c = ctx.execute([
        bash, "-c", """
set -ex
(cd {}
 git log -n 1 --pretty='format:%H')
        """.format(d)
    ],
                    environment=e).stdout
    return {"commit": c}


def _copy_and_patch(ctx, path):
    e = ctx.os.environ
    ps = ctx.execute([
        bash, "-c", """
set -ex
(cd {}
 cp -a patches/* upstream/ || true
 find upstream -name '*.qpx.patch')
            """.format(path.dirname)
    ],
                     environment=e).stdout
    for p in ps.splitlines():
        s = ctx.execute([
            bash, "-c", """
set -ex
(cd {}
 patch -N -p0 {} {})
                """.format(path.dirname, p.replace(".qpx.patch", ""), p)
        ],
                        environment=e)
        if s.return_code:
            print("Failed patching %s:\n%s%s" % (str(p), s.stderr, s.stdout))


def _update_commit(orig, keys, commit):
    r = {}
    for k in keys:
        v = getattr(orig, k)
        if v != None:
            r[k] = v
    r["name"] = orig.name
    r.update(commit)
    return r


_attrs = {
    "path": attr.string(mandatory=True),
    "commit": attr.string(default=""),
    "repo_mapping": attr.label_keyed_string_dict(),
}


def _impl(ctx):
    p = ctx.attr.path
    p = ctx.path(Label("@//:" + p + "/upstream/.git")).dirname
    print("*** PATCHING:", p)
    ctx.symlink(p, ctx.path(""))
    c = _reset_or_pull(ctx)
    _copy_and_patch(ctx, p)
    return _update_commit(ctx.attr, _attrs.keys(), c)


patched_repository = repository_rule(
    implementation=_impl, attrs=_attrs, local=True)
