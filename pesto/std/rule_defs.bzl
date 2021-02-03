# -*- Python -*-
# Copyright 2018 Quantapix Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# =============================================================================


def sources():
    native.filegroup(
        name="sources",
        srcs=native.glob(["**/*"]),
    )


std = "std/"


def bdir():
    o = "bdir"
    native.genrule(
        name=o,
        srcs=[],
        outs=[std + o],
        cmd="\n".join([
            "if [ ! -e $@ ]",
            " then touch $@",
            "fi",
        ]),
    )


_bdir = ":bdir"


def configure():
    c = "@sys//:autoconf"
    o = "configure"
    i = o + ".ac"
    native.genrule(
        name=o,
        srcs=[_bdir, i] + native.glob(["**/*.m4"]),
        outs=[std + o],
        cmd="\n".join([
            "(cd $$(dirname $(location {}))".format(i),
            " $$OLDPWD/$(location {}) {} > $$OLDPWD/$@)".format(c, i),
            "cd $$(dirname $(location {}))".format(_bdir),
            "cp $$OLDPWD/$@ {} || true".format(o),
        ]),
        tools=[c, i],
    )


_hook = "//:BUILD.bazel"


def makefile(outs=["Makefile"], prefix="@std", preps=[], hooks=[], opts=[]):
    prefix = Label(prefix).workspace_root
    c = ":configure"
    outs = outs + ["config.log", "config.status"]
    native.genrule(
        name="_makefile",
        srcs=[_bdir, c, ":sources"],
        outs=[(std + o) for o in outs],
        cmd="cd $$(dirname $(location {}))\n".format(_bdir) + "\n".join(preps)
        + " \\\n".join([
            "$$OLDPWD/$(location {})".format(c),
            "--srcdir=$$OLDPWD/$$(dirname $(location {}))".format(_hook),
            "--prefix=/{}".format(prefix),
            "",
        ]) + " \\\n".join(opts) + "\n".join([
            "",
            "cp {} $$OLDPWD/$(@D)/{} || true".format(" ".join(outs), std),
        ]),
        tools=[_hook, c] + hooks,
    )


_m = "@sys//:make"
_mf = "-j$$(nproc)"
_cm = "@sys//:cmake"


def make(tgts=[], opts=[]):
    mf = " ".join(opts) + " " + _mf
    mt = " ".join(tgts)
    native.genrule(
        name="make",
        srcs=[_bdir, "_makefile", ":sources"],
        outs=[std + "make.log"],
        cmd="\n".join([
            "cd $$(dirname $(location {}))".format(_bdir),
            "$$OLDPWD/$(location {}) {} {} > $$OLDPWD/$@".format(_m, mf, mt),
        ]),
        tools=[_m],
    )


def cmake(tgts=[], prefix="@std"):
    prefix = Label(prefix).workspace_root
    cmf = " ".join([
        "-G\"Unix Makefiles\"",
        "-DCMAKE_INSTALL_PREFIX=/{}".format(prefix),
    ])
    mt = " ".join(tgts)
    native.genrule(
        name="cmake",
        srcs=[_bdir, ":sources"],
        outs=[std + "make.log"],
        cmd="\n".join([
            "cd $$(dirname $(location {}))".format(_bdir),
            "SRC=$$OLDPWD/$$(dirname $(location {}))".format(_hook),
            "$$OLDPWD/$(location {}) {} $$SRC".format(_cm, cmf),
            "$$OLDPWD/$(location {}) {} {} > $$OLDPWD/$@".format(_m, _mf, mt),
        ]),
        tools=[_hook, _cm, _m],
    )


def install(name, src, outs=[]):
    b = "@{}//{}".format(name, _bdir)
    outs = outs if outs else ["bin/" + name]
    outs += [name]
    f = "\n".join([
        "pushd $$(dirname {})",
        "ln -sf /external/std/{} $$(basename {})",
        "popd",
    ])
    native.genrule(
        name="_" + name,
        srcs=[src],
        outs=outs,
        cmd="\n".join([
            "cd $$(dirname $(location {}))".format(b),
            # "DESTDIR=$$OLDPWD/$(GENDIR) \\",
            "$$OLDPWD/$(location {}) install".format(_m),
            "cd $$OLDPWD/$(@D)",
            "touch {}".format(name),
        ] + [f.format(o, o, o) for o in outs[:-1]]),
        tools=[b, _m],
    )


def profile(name, src, opts=[], libs=[]):
    mf = " ".join(opts)
    mt = "profile-install"
    native.genrule(
        name=name + "_prof",
        srcs=[src],
        outs=libs if libs else ["prof/bin/" + name],
        cmd="\n".join([
            "cd $$(dirname $<)",
            "DESTDIR=$$OLDPWD/$(GENDIR)/prof \\",
            "$$OLDPWD/$(location {}) {} {}".format(_m, mf, mt),
        ]),
        tools=[_m],
    )


# while [ 1 ]; do sleep 1; clear; tail bazel-genfiles/external/python/std/make.log; done

# "DIR=$$(mktemp -d $${TMPDIR-/tmp}/tmp.XXXXXXX)",
# "(cd $(execution_root)/xgboost && cp -fr . \"$${DIR}\")",
# "(cd \"$${DIR}\" && make target)",
# "cp $${DIR}/output $@",
