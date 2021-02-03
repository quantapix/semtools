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
