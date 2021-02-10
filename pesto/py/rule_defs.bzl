

def wheel():

    i = "setup.py"
    n = "wheel.tar"
    c = "@sys//:python3"
    native.genrule(
        name="_" + n,
        srcs=native.glob(["**/*"]),
        outs=[n],
        cmd="\n".join([
            "DST=$$(mktemp -d)",
            "cd $$(dirname $(location {}))".format(i),
            "CMD=$$OLDPWD/$(location {})".format(c),
            "$$CMD {} bdist_wheel -d $$DST".format(i),
            "tar -cf $$OLDPWD/$@ -C $$DST .",
            "rm -rf $$DST",
        ]),
        tools=[c, i],
    )


def venvs(wheels):

    for k in ["sys", "std", "src"]:
        n = "venvs/" + k
        c = "@" + k + "//:python3"
        native.genrule(
            name="_" + n,
            outs=[n + "/pyvenv.cfg"],
            cmd="$(location {}) -m venv $(@D)".format(c),
            tools=[c],
        )
        for i in wheels:
            p = ":_" + n
            n = "venvs/" + k + "/" + i
            w = "@py_" + i + "//:wheel.tar"
            native.genrule(
                name="_" + n,
                srcs=[p, w],
                outs=[n],
                cmd="\n".join([
                    "SRC=$$(mktemp -d)",
                    "tar -xf $(location {}) -C $$SRC".format(w),
                    "$(@D)/bin/python -m pip install --no-index $$SRC/*.whl",
                    "rm -rf $$SRC",
                    "touch $@",
                ]),
            )
        p = ":_" + n
        n = "venvs/" + k
        native.genrule(
            name=n,
            srcs=[p],
            outs=[n + "/venv.tar"],
            cmd="tar -cf $@ -C $(@D) .",
        )
