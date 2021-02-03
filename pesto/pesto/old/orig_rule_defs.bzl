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
"""Execute a binary.
The example below executes the binary target "//actions_run:merge" with
some arguments. The binary will be automatically built by Bazel.
The rule must declare its dependencies. To do that, we pass the target to
the attribute "_merge_tool". Since it starts with an underscore, it is private
and users cannot redefine it.
"""

sh_binary(
    name="merge",
    srcs=["merge.sh"],
)


def _impl(ctx):
    args = [ctx.outputs.out.path] + [f.path for f in ctx.files.chunks]
    ctx.actions.run(
        inputs=ctx.files.chunks,
        outputs=[ctx.outputs.out],
        arguments=args,
        progress_message="Merging into %s" % ctx.outputs.out.short_path,
        executable=ctx.executable._merge_tool,
    )


concat = rule(
    implementation=_impl,
    attrs={
        "chunks":
        attr.label_list(allow_files=True),
        "out":
        attr.output(mandatory=True),
        "_merge_tool":
        attr.label(
            executable=True,
            cfg="host",
            allow_files=True,
            default=Label("//actions_run:merge"),
        ),
    },
)

load(":execute.bzl", "concat")

concat(
    name="sh",
    out="page.html",
    chunks=[
        "header.html",
        "body.html",
        "footer.html",
    ],
)

# =============================================================================


def _write_file_impl(ctx):
    output = ctx.outputs.out
    ctx.actions.write(output=output, content=ctx.attr.content)


write_file = rule(
    implementation=_write_file_impl,
    attrs={"content": attr.string()},
    outputs={"out": "%{name}.txt"},
)

# =============================================================================
"""Example of using an aspect to collect information from dependencies.
For more information about aspects, see the documentation:
  https://docs.bazel.build/versions/master/skylark/aspects.html
"""

FileCollector = provider(fields={"files": "collected files"}, )


def _file_collector_aspect_impl(target, ctx):
    # This function is executed for each dependency the aspect visits.

    # Collect files from the srcs
    direct = [
        f for f in ctx.rule.files.srcs
        if ctx.attr.extension == "*" or ctx.attr.extension == f.extension
    ]

    # Combine direct files with the files from the dependencies.
    files = depset(
        direct=direct,
        transitive=[dep[FileCollector].files for dep in ctx.rule.attr.deps],
    )

    return [FileCollector(files=files)]


file_collector_aspect = aspect(
    implementation=_file_collector_aspect_impl,
    attr_aspects=["deps"],
    attrs={
        "extension": attr.string(values=["*", "h", "cc"]),
    },
)


def _file_collector_rule_impl(ctx):
    # This function is executed once per `file_collector`.

    # Write the collected information to the output file.
    content = []
    for dep in ctx.attr.deps:
        files = [f.short_path for f in dep[FileCollector].files.to_list()]
        content.append("files from {}: {}".format(dep.label, files))
    content += [""]  # trailing newline

    ctx.actions.write(
        output=ctx.outputs.out,
        content="\n".join(content),
    )


file_collector = rule(
    implementation=_file_collector_rule_impl,
    attrs={
        "deps": attr.label_list(aspects=[file_collector_aspect]),
        "extension": attr.string(default="*"),
    },
    outputs={"out": "%{name}.files"},
)

# =============================================================================
"""Example of a rule that accesses its attributes."""


def _impl(ctx):
    # Print debug information about the target.
    print("Target {} has {} deps".format(ctx.label, len(ctx.attr.deps)))

    # For each target in deps, print its label and files.
    for i, d in enumerate(ctx.attr.deps):
        print(" {}. label = {}".format(i + 1, d.label))

        # A label can represent any number of files (possibly 0).
        print("    files = " + str([f.path for f in d.files.to_list()]))

    # For debugging, consider using `dir` to explore the existing fields.
    print(dir(ctx))  # prints all the fields and methods of ctx
    print(dir(ctx.attr))  # prints all the attributes of the rule


printer = rule(
    implementation=_impl,
    attrs={
        # Do not declare "name": It is added automatically.
        "number": attr.int(default=1),
        "deps": attr.label_list(allow_files=True),
    },
)

# =============================================================================
"""This example shows how a rule can compute implicit dependencies.
Bazel needs to know about all dependencies before doing the analysis phase
and calling the implementation function. Dependencies can be computed
based on the rule attributes: to do so, use a function as the default
value of an attribute (the attribute must be private and have type 'label'
or 'list of labels'). The parameters of this function must correspond to
the attributes that are accessed in the function body.
The example below computes the md5 sum of a file. The file can be
preprocessed using a filter. The exact dependencies depend on the filter
chosen by the user.
"""

_filters = {
    "comments": Label("//computed_dependencies:comments"),
    "spaces": Label("//computed_dependencies:spaces"),
    "none": None,
}


def _get_filter(filter):  # requires attribute "filter"
    # Return the value for the attribute "_filter_bin"
    # It can be a label or None.
    return _filters[filter]


def _impl(ctx):
    src = ctx.file.src

    if not ctx.attr._filter_bin:
        # Skip the processing
        processed = src
    else:
        # The temporary file is based on 'ctx.label.name' to avoid conflicts.
        processed = ctx.actions.declare_file(ctx.label.name + "_processed")

        # Run the selected binary
        ctx.actions.run(
            outputs=[processed],
            inputs=[ctx.file.src],
            progress_message="Apply filter '%s'" % ctx.attr.filter,
            arguments=[ctx.file.src.path, processed.path],
            executable=ctx.executable._filter_bin,
        )

    # Compute the hash
    out = ctx.outputs.text
    ctx.actions.run_shell(
        outputs=[out],
        inputs=[processed],
        command="md5sum < %s > %s" % (processed.path, out.path),
    )


md5_sum = rule(
    implementation=_impl,
    attrs={
        "filter":
        attr.string(values=_filters.keys(), default="none"),
        "src":
        attr.label(mandatory=True, allow_single_file=True),
        "_filter_bin":
        attr.label(default=_get_filter, executable=True, cfg="host"),
    },
    outputs={"text": "%{name}.txt"},
)

# =============================================================================

FooFiles = provider("transitive_sources")


def get_transitive_srcs(srcs, deps):
    """Obtain the source files for a target and its transitive dependencies.
    Args:
      srcs: a list of source files
      deps: a list of targets that are direct dependencies
    Returns:
      a collection of the transitive sources
    """
    return depset(
        srcs,
        transitive=[dep[FooFiles].transitive_sources for dep in deps],
    )


def _foo_library_impl(ctx):
    trans_srcs = get_transitive_srcs(ctx.files.srcs, ctx.attr.deps)
    return [
        FooFiles(transitive_sources=trans_srcs),
        DefaultInfo(files=trans_srcs),
    ]


foo_library = rule(
    implementation=_foo_library_impl,
    attrs={
        "srcs": attr.label_list(allow_files=True),
        "deps": attr.label_list(),
    },
)

# =============================================================================


def _foo_binary_impl(ctx):
    foocc = ctx.executable._foocc
    out = ctx.outputs.out
    trans_srcs = get_transitive_srcs(ctx.files.srcs, ctx.attr.deps)
    srcs_list = trans_srcs.to_list()
    ctx.actions.run(
        executable=foocc,
        arguments=[out.path] + [src.path for src in srcs_list],
        inputs=srcs_list,
        tools=[foocc],
        outputs=[out],
    )


foo_binary = rule(
    implementation=_foo_binary_impl,
    attrs={
        "srcs":
        attr.label_list(allow_files=True),
        "deps":
        attr.label_list(),
        "_foocc":
        attr.label(
            default=Label("//depsets:foocc"),
            allow_files=True,
            executable=True,
            cfg="host",
        ),
    },
    outputs={"out": "%{name}.out"},
)

# =============================================================================

# A rule that generates a "fortune"-style executable for haikus. It takes haiku
# files as inputs, and produces a data file consisting of their concatenation,
# along with a shell script.
#
# To run, use
#     bazel run //executable:bazel_haikus

# The script content, with placeholders for the data file name and number of
# haikus.
script_template = """\
#!/bin/bash
R=$(($RANDOM%{num_fortunes}*3+1))
cat {fortunes_file} | sed -n "$R,$(($R+2))p"
"""


def _haiku_fortune_impl(ctx):
    # Generate a datafile of concatenated fortunes.
    datafile = ctx.actions.declare_file(ctx.label.name + ".fortunes")
    ctx.actions.run_shell(
        outputs=[datafile],
        inputs=ctx.files.srcs,
        command="cat {} > {}".format(
            " ".join([f.path for f in ctx.files.srcs]),
            datafile.path,
        ),
    )

    # Emit the executable shell script.
    script = ctx.actions.declare_file("%s-fortune" % ctx.label.name)
    script_content = script_template.format(
        fortunes_file=datafile.short_path,
        num_fortunes=len(ctx.attr.srcs),
    )
    ctx.actions.write(script, script_content, is_executable=True)

    # The datafile must be in the runfiles for the executable to see it.
    runfiles = ctx.runfiles(files=[datafile])
    return [DefaultInfo(executable=script, runfiles=runfiles)]


haiku_fortune = rule(
    implementation=_haiku_fortune_impl,
    attrs={
        "srcs":
        attr.label_list(
            allow_files=True,
            doc="Input haiku files. Each file must have exactly three lines. "
            + "The last line must be terminated by a newline character.",
        ),
    },
    executable=True,
)

# =============================================================================
"""Generate a file using a template.
It is much more memory-efficient to use a template file than creating the whole
content during the analysis phase.
"""

# Label of the template file to use.
_TEMPLATE = "//expand_template:hello.cc"


def _hello_impl(ctx):
    ctx.actions.expand_template(
        template=ctx.file._template,
        output=ctx.outputs.source_file,
        substitutions={
            "{FIRSTNAME}": ctx.attr.firstname,
        },
    )


hello = rule(
    implementation=_hello_impl,
    attrs={
        "firstname":
        attr.string(mandatory=True),
        "_template":
        attr.label(
            default=Label(_TEMPLATE),
            allow_single_file=True,
        ),
    },
    outputs={"source_file": "%{name}.cc"},
)

# =============================================================================


def _impl(ctx):
    # Create actions to generate the three output files.
    # Actions are run only when the corresponding file is requested.

    ctx.actions.run_shell(
        outputs=[ctx.outputs.md5],
        inputs=[ctx.file.src],
        command="md5sum {} > {}".format(ctx.file.src.path,
                                        ctx.outputs.md5.path),
    )

    ctx.actions.run_shell(
        outputs=[ctx.outputs.sha1],
        inputs=[ctx.file.src],
        command="sha1sum {} > {}".format(ctx.file.src.path,
                                         ctx.outputs.sha1.path),
    )

    ctx.actions.run_shell(
        outputs=[ctx.outputs.sha256],
        inputs=[ctx.file.src],
        command="sha256sum {} > {}".format(ctx.file.src.path,
                                           ctx.outputs.sha256.path),
    )

    # By default (if you run `bazel build` on this target, or if you use it as a
    # source of another target), only the sha256 is computed.
    return DefaultInfo(files=depset([ctx.outputs.sha256]))


hashes = rule(
    implementation=_impl,
    attrs={
        "src": attr.label(mandatory=True, allow_single_file=True),
    },
    outputs={
        "md5": "%{name}.md5",
        "sha1": "%{name}.sha1",
        "sha256": "%{name}.sha256",
    },
)

# =============================================================================
"""Rule with a mandatory provider.
In this example, rules have a number attribute. Each rule adds its number
with the numbers of its transitive dependencies, and write the result in a
file. This shows how to transfer information from a dependency to its
dependents.
"""

NumberInfo = provider("number")


def _impl(ctx):
    result = ctx.attr.number
    for dep in ctx.attr.deps:
        result += dep[NumberInfo].number
    ctx.actions.write(output=ctx.outputs.out, content=str(result))

    # Return the provider with result, visible to other rules.
    return [NumberInfo(number=result)]


sum = rule(
    implementation=_impl,
    attrs={
        "number": attr.int(default=1),
        # All deps must provide all listed providers.
        "deps": attr.label_list(providers=[NumberInfo]),
    },
    outputs={"out": "%{name}.sum"},
)

# =============================================================================
"""Rule with an optional provider.
In this example, rules have a number attribute. Each rule adds its number
with the numbers of its transitive dependencies, and write the result in a
file. This shows how to transfer information from a dependency to its
dependents. Dependencies are not required to provide a number.
"""

NumberInfo = provider("number")


def _impl(ctx):
    result = ctx.attr.number
    for dep in ctx.attr.deps:
        if NumberInfo in dep:
            result += dep[NumberInfo].number
    ctx.actions.write(output=ctx.outputs.out, content=str(result))

    # Return the provider with result, visible to other rules.
    return [NumberInfo(number=result)]


sum = rule(
    implementation=_impl,
    attrs={
        "number": attr.int(default=1),
        "deps": attr.label_list(),
    },
    outputs={"out": "%{name}.sum"},
)

# =============================================================================

# A rule that takes in a series of "declarations" and produces "compiled
# output" for some of those declarations, along with a manifest. Here, the
# declarations are simply words in a dictionary text file, and the compiled
# output of a word is just its hash.
#
# The compiled outputs are specified by the user, while the manifest file is
# created automatically. Both kinds of outputs are predeclared, and can be
# referred to in the target graph or built in the command line, e.g.:
#
#     bazel build //predeclared_outputs:dog.md5
#
# If you do not need to refer to the output files as labels, it may be simpler
# to pass in the words as an attr.string_list, and declare the files in the
# implementation function instead.
#
# This rule assumes the presence of shell commands "grep", "md5sum", and "cut".


def _word_hashes_impl(ctx):
    dictionary = ctx.file.dictionary
    manifest = ctx.outputs.manifest

    # For each requested output file, validate that it's an .md5, and emit an
    # action that will generate the file from the dictionary.
    for hashfile in ctx.outputs.hashes:
        basename = hashfile.basename
        if not basename.endswith(".md5"):
            fail("Hash file '%s' must end in '.md5'".format(basename))
        word = basename[:-len(".md5")]

        ctx.actions.run_shell(
            outputs=[hashfile],
            inputs=[dictionary],
            command="grep {} {} | md5sum | cut -f1 -d ' ' > {}".format(
                word,
                dictionary.path,
                hashfile.path,
            ),
        )

    # Produce the manifest.
    manifest_content = "".join(
        [hashfile.path + "\n" for hashfile in sorted(ctx.outputs.hashes)], )
    ctx.actions.write(manifest, manifest_content)


# Since we are not returning a DefaultInfo provider with a files= field,
# all the predeclared outputs will be built when the target is requested.

word_hashes = rule(
    implementation=_word_hashes_impl,
    attrs={
        "dictionary":
        attr.label(
            allow_single_file=True,
            mandatory=True,
            doc="A file containing words, one per line.",
        ),
        "hashes":
        attr.output_list(
            doc="A list of files named \"<word>.md5\", where \"<word>\" " +
            "is in the dictionary.", ),
    },
    outputs={"manifest": "%{name}.manifest"},
)

# =============================================================================
"""Create an executable with runfiles.
Runfiles are files that are needed at runtime (when the executable in run).
This example also shows a use of `ctx.expand_location`.
"""


def _impl(ctx):
    # Expand the label in the command string to a runfiles-relative path.
    # The second arg is the list of labels that may be expanded.
    command = ctx.expand_location(ctx.attr.command, ctx.attr.data)

    # Create the output executable file with command as its content.
    ctx.actions.write(
        output=ctx.outputs.executable,
        content=command,
        is_executable=True,
    )

    # Create runfiles from the files specified in the data attribute.
    # The shell executable - the output of this rule - can use them at
    # runtime. It is also possible to define data_runfiles and
    # default_runfiles. However if runfiles is specified it's not possible to
    # define the above ones since runfiles sets them both.
    return [DefaultInfo(runfiles=ctx.runfiles(files=ctx.files.data), )]


execute = rule(
    implementation=_impl,
    executable=True,
    attrs={
        "command": attr.string(),
        "data": attr.label_list(allow_files=True),
    },
)

# =============================================================================
"""Execute a shell command.
While convenient, Shell commands should be used carefully. Generating the
command-line can lead to escaping and injection issues. It can also create
portability problems. It is often better to declare a binary target in a
BUILD file and execute it.
"""


def _impl(ctx):
    output = ctx.outputs.out
    input = ctx.file.file

    # The command may only access files declared in inputs.
    ctx.actions.run_shell(
        inputs=[input],
        outputs=[output],
        progress_message="Getting size of %s" % input.short_path,
        command="stat -L -c%%s '%s' > '%s'" % (input.path, output.path),
    )


size = rule(
    implementation=_impl,
    attrs={"file": attr.label(mandatory=True, allow_single_file=True)},
    outputs={"out": "%{name}.size"},
)

# =============================================================================
"""Test rule that fails if a source file has too long lines."""


def _check_file(f, columns):
    """Return shell commands for testing file 'f'."""

    # We write information to stdout. It will show up in logs, so that the user
    # knows what happened if the test fails.
    return """
echo Testing that {file} has at most {columns} columns...
grep -E '^.{{{columns}}}' {path} && err=1
echo
""".format(
        columns=columns, path=f.path, file=f.short_path)


def _impl(ctx):
    script = "\n".join(
        ["err=0"] + [_check_file(f, ctx.attr.columns)
                     for f in ctx.files.srcs] + ["exit $err"], )

    # Write the file, it is executed by 'bazel test'.
    ctx.actions.write(
        output=ctx.outputs.executable,
        content=script,
    )

    # To ensure the files needed by the script are available, we put them in
    # the runfiles.
    runfiles = ctx.runfiles(files=ctx.files.srcs)
    return [DefaultInfo(runfiles=runfiles)]


line_length_test = rule(
    implementation=_impl,
    attrs={
        "columns": attr.int(default=100),
        "srcs": attr.label_list(allow_files=True),
    },
    test=True,
)
