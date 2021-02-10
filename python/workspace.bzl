"""Dependencies for python tools and tests"""

load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@rules_python//python:pip.bzl", "pip_install")

def python_deps():
    """Fetches all required dependencies for rules_python tests and tools"""

    # `sudo apt install libssl-dev`

    maybe(
        new_git_repository,
        name = "python3",
        remote = "./python/upstream",
        branch = "3.9",
        build_file_content = """
exports_files(["qpx_bin"])
filegroup(
    name = "files",
    srcs = glob(["qpx_out/**"], exclude = ["**/* *"]),
    visibility = ["//visibility:public"],
)
""",
        patch_cmds = [
            "mkdir $(pwd)/qpx_out",
            "./configure --prefix=$(pwd)/qpx_out",
            "make",
            "make install",
            "ln -s qpx_out/bin/python3 qpx_bin",
        ],
    )

    maybe(
        http_archive,
        name = "python2",
        build_file_content = """
exports_files(["qpx_bin"])
filegroup(
    name = "files",
    srcs = glob(["qpx_out/**"], exclude = ["**/* *"]),
    visibility = ["//visibility:public"],
)
""",
        patch_cmds = [
            "mkdir $(pwd)/qpx_out",
            "./configure --prefix=$(pwd)/qpx_out",
            "make",
            "make install",
            "ln -s qpx_out/bin/python qpx_bin",
        ],
        sha256 = "dfab5ec723c218082fe3d5d7ae17ecbdebffa9a1aea4d64aa3a2ecdd2e795864",
        strip_prefix = "Python-2.7.9",
        urls = ["https://www.python.org/ftp/python/3.8.3/Python-3.8.3.tar.xz"],
    )

    pip_install(
        #extra_pip_args = ["-v"],
        #pip_data_exclude = ["**/* */**"],

        #python_interpreter (path)
        #python_interpreter_target = "@python3//:qpx_bin",

        #quiet = False,

        requirements = "//:requirements.txt",
    )

#register_toolchains("//:my_py_toolchain")
