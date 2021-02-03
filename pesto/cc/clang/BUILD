# -*- Python -*-
# PULLED FROM BUILD!!!
#

load(
    "@//cc:rule_defs.bzl",
    "prep_toolchain",
    "create_links",
    "create_lists",
    "create_toolchain",
)

_name = "clang"
prep_toolchain(_name)

_pre = "llvm-"
create_links(
    "sys",
    {
        "ar": None,
        "as": None,
        "cpp": None,
        "dwp": None,
        "gcc": "clang",
        "gcov": _pre + "cov",
        "ld": "ld.lld",
        "nm": None,
        "objcopy": None,
        "objdump": None,
        "profdata": None,
        "strip": "strip",
        "xray": None,
    },
    _pre,
)

create_lists(
    "sys",
    {
        "drivers": [],
        "includes": [],
        "libraries": [],
    },
)

create_toolchain("sys", _name)
