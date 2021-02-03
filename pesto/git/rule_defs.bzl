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
