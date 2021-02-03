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


def build_tpls(count):
    t = """
constraint_value(
    name="%{full_#}",
    constraint_setting="@bazel_tools//tools/cpp:cc_compiler",
)

filegroup(
    name="%{full_#}_cc_deps",
    srcs=[
        "%{as_#}",
        "%{gcc_#}",
        ":tools",
    ] + %{wrappers_#} + %{includes_#},
    )

filegroup(
    name="%{full_#}_ld_deps",
    srcs=[
        "%{ar_#}",
        "%{ld_#}",
        ":tools",
    ] + %{wrappers_#} + %{libraries_#},
    )

filegroup(
    name="%{full_#}_all_deps",
    srcs=[
        ":%{full_#}_cc_deps",
        ":%{full_#}_ld_deps",
        "%{dwp_#}",
        "%{gcov_#}",
        "%{nm_#}",
        "%{objcopy_#}",
        "%{objdump_#}",
        "%{profdata_#}",
        "%{strip_#}",
    ], # + %{xray_#},
    )

cc_toolchain(
    name="cc-compiler-%{full_#}",
    toolchain_identifier = "id-%{full_#}",
    cpu="k8",
    all_files=":%{full_#}_all_deps",
    compiler_files=":%{full_#}_cc_deps",
    linker_files=":%{full_#}_ld_deps",
    objcopy_files="%{objcopy_#}",
    strip_files="%{strip_#}",
    dwp_files="%{dwp_#}",
    dynamic_runtime_libs=[":empty"],
    static_runtime_libs=[":empty"],
    supports_param_files=1,
)

toolchain(
    name="cc-toolchain-%{full_#}",
    exec_compatible_with=[
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:linux",
        "@//:%{stack_#}_stack",
    ],
    target_compatible_with=[
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:linux",
        "@//:%{stack_#}_stack",
    ],
    toolchain=":cc-compiler-%{full_#}",
    toolchain_type="@bazel_tools//tools/cpp:toolchain_type",
)

"""
    return [t.replace("_#", "_{}".format(i)) for i in range(count)]


def build_maps(count):
    t = "        \"k8|%{full_#}\": \":cc-compiler-%{full_#}\","
    return [t.replace("_#", "_{}".format(i)) for i in range(count)]
