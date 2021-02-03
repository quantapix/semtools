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
