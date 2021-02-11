"""Python tgts"""

load("@rules_cc//cc:defs.bzl", "cc_test")
load("@rules_foreign_cc//tools/build_defs:configure.bzl", "configure_make")


# buildifier: disable=unnamed-macro
def python_tgts():
    """Python deps"""

    configure_make(
        name = "libunwind",
        autogen = True,
        configure_in_place = True,
        configure_options = [
            "--disable-coredump",
            "--disable-ptrace",
            "--disable-setjmp",
            "--disable-documentation",
            "--disable-weak-backtrace",
        ],
        lib_source = "@libunwind//:all",
        shared_libraries = ["libunwind.so"],
        static_libraries = ["libunwind.a"],
        visibility = ["//visibility:public"],
    )

exports_files(["qpx_bin"])
filegroup(
    name = "files",
    srcs = glob(["qpx_out/**"], exclude = ["**/* *"]),
    visibility = ["//visibility:public"],
)

            "mkdir $(pwd)/qpx_out",
            "./configure --prefix=$(pwd)/qpx_out",
            "make",
            "make install",
            "ln -s qpx_out/bin/python3 qpx_bin",


cc_test(
    name = "test_libunwind",
    srcs = ["libunwind_test.c"],
    deps = [":libunwind"],
)

test_suite(
    name = "configure_libunwind_tests",
    tests = [":test_libunwind"],
)
