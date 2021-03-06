_DOWNLOADED_FILE_NAME = "centos.rpm"
_BASE_URL = "http://mirror.centos.org/centos/{}/os/x86_64/Packages/"
_REGEX = ".*centos-release.*rpm"
_BUILD = """
package(default_visibility = ["//visibility:public"])
filegroup(
    name = "file",
    srcs = ["{}"],
)
"""

def _centos_rpm_impl(repository_ctx):
    """Implementation of the centos_rpm rule."""
    download_path = repository_ctx.path("file/" + _DOWNLOADED_FILE_NAME)
    download_command = [
        "wget",
        "-q",
        _BASE_URL.format(repository_ctx.attr.version),
        "-np",
        "-nd",
        "-r",
        "-R",
        "*index.html*",
        "--accept-regex",  # Passing the file regex.
        _BASE_URL.format(repository_ctx.attr.version) + _REGEX,
    ]
    download_result = repository_ctx.execute(download_command, working_directory = "file")
    if download_result.return_code:
        fail("Download command failed: {} ({})".format(
            download_result.stderr,
            " ".join(download_command),
        ))
    count_command = ["sh", "-c", "ls -1 | wc -l"]
    count_result = repository_ctx.execute(count_command, working_directory = "file")
    if count_result.return_code:
        fail("Count command failed: {} ({})".format(
            count_result.stderr,
            " ".join(count_command),
        ))
    if count_result.stdout.strip("\n") != "1":
        fail(
            "{} files downloaded. Make sure the regex only matches to exactly 1 file."
                .format(count_result.stdout.strip("\n")),
        )
    rename_command = ["sh", "-c", "mv $(ls) {}".format(download_path)]
    rename_result = repository_ctx.execute(rename_command, working_directory = "file")
    if rename_result.return_code:
        fail("Rename command failed: {} ({})".format(
            rename_result.stderr,
            " ".join(rename_command),
        ))
    repository_ctx.file("file/BUILD", _BUILD.format(_DOWNLOADED_FILE_NAME))

centos_rpm = repository_rule(
    attrs = {
        "version": attr.int(
            mandatory = True,
            doc = "The major version of Centos",
        ),
    },
    implementation = _centos_rpm_impl,
)
