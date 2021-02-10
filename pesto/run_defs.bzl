def root_repo(root):

    args = ["-p", root]

    native.py_binary(
        name="repatch_all",
        srcs=["@pesto//:pesto"],
        main="workspace.py",
        args=["-r"] + args,
    )

    native.py_binary(
        name="commit_all",
        srcs=["@pesto//:pesto"],
        main="workspace.py",
        args=["-c"] + args,
    )

    native.py_binary(
        name="pull_all",
        srcs=["@pesto//:pesto"],
        main="workspace.py",
        args=["-u"] + args,
    )

    native.py_binary(
        name="reset",
        srcs=["@pesto//:pesto"],
        main="workspace.py",
        args=["-s"] + args,
    )


def repo(root, name, branch=None):

    args = ["-p", root, "-n", name]
    if branch:
        args += ["-b", branch]

    native.py_binary(
        name="repatch",
        srcs=["@pesto//:pesto"],
        main="repo.py",
        args=["-r"] + args,
    )

    native.py_binary(
        name="rediff",
        srcs=["@pesto//:pesto"],
        main="repo.py",
        args=["-d"] + args,
    )

    native.py_binary(
        name="commit",
        srcs=["@pesto//:pesto"],
        main="repo.py",
        args=["-c"] + args,
    )

    native.py_binary(
        name="pull",
        srcs=["@pesto//:pesto"],
        main="repo.py",
        args=["-u"] + args,
    )
