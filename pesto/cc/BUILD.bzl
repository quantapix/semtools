

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
