load("@rules_cc//cc:defs.bzl", "cc_library")

def libs(pairs):
    for n, o in pairs:
        cc_library(
            name=n,
            linkopts=["-l" + o],
        )

def links(names):
    for o in names:
        n = o.replace("-", "_").replace(".", "_")
        native.genrule(
            name="_" + n,
            outs=["bin/" + o],
            cmd="cd $(@D); ln -s $$(which {})".format(o),
        )
        native.sh_binary(
            name=n,
            srcs=[":bin/" + o],
        )
