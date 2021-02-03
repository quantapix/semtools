# -*- Python -*-
# PULLED FROM BUILD!!!
#

constraint_setting(name="tools_stack")

constraint_value(
    name="sys_stack",
    constraint_setting=":tools_stack",
)

platform(
    name="sys_platform",
    constraint_values=[
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:linux",
        ":sys_stack",
    ],
)

constraint_value(
    name="std_stack",
    constraint_setting=":tools_stack",
)

platform(
    name="std_platform",
    constraint_values=[
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:linux",
        ":std_stack",
    ],
)

constraint_value(
    name="src_stack",
    constraint_setting=":tools_stack",
)

platform(
    name="src_platform",
    constraint_values=[
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:linux",
        ":src_stack",
    ],
)

# filegroup(
#     name="formulate",
#     srcs=["@python//:formulate", "@py_numpy//numpy:formulate"],
# )

# filegroup(name="bootstrap", srcs=["@py//:py"])

# filegroup(name="compile", srcs=["@py//pesto_bins"])
