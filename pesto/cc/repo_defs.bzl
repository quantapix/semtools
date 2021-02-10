

def _str(o):
    if type(o) == "int":
        return str(o)
    elif type(o) == "bool":
        return "true" if o else "false"
    return "\"{}\"".format(o)


def _dict_str(d, pre="  "):
    ls = []
    for k in d:
        if type(d[k]) == "list":
            for e in d[k]:
                ls.append("{}{}: {}".format(pre, k, _str(e)))
        else:
            ls.append("{}{}: {}".format(pre, k, _str(d[k])))
    return "\n".join(ls)


_llvm = "llvm-"
_stacks = {
    "gcc": {
        "ar": None,
        "as": None,
        "cpp": None,
        "dwp": None,
        "gcc": None,
        "gcov": None,
        "ld": None,
        "nm": None,
        "objcopy": None,
        "objdump": None,
        "profdata": "gprof",
        "strip": None,
    },
    "clang": {
        "ar": None,
        "as": None,
        # "cpp": None,
        "dwp": None,
        "gcc": "clang",
        "gcov": _llvm + "cov",
        "ld": "ld.lld",
        "nm": None,
        "objcopy": None,
        "objdump": None,
        "profdata": None,
        "strip": "strip",
        "xray": None,
    },
}


def _labels(ctx, stack, name, idx=None):
    ls = {}
    pre = _llvm if name == "clang" else ""
    for n, p in _stacks[name].items():
        p = (pre + n) if p == None else p
        if idx != None and name == "gcc" and n == "gcc":
            ls[n] = "cc_wrapper_{}.sh".format(idx)
        else:
            ls[n] = Label("@{}//:bin/{}".format(stack, p))
    return ls


def _tool_paths(ctx, stack, name, idx):
    ps = []
    for n, lb in _labels(ctx, stack, name, idx).items():
        p = "name: \"{}\" path: \"{}\"".format(n, str(ctx.path(lb)))
        ps.append("  tool_path {" + p + " }")
    return "\n".join(ps)


def _inc_dirs(cmd, lang, flags=[]):
    ds = []
    ctx = cmd[0]
    r = ctx.execute([cmd[1], lang, "-E", "-v", "-"] + flags)
    i1 = r.stderr.find("#include <...>")
    if i1 != -1:
        i1 = r.stderr.find("\n", i1)
        if i1 != -1:
            i2 = r.stderr.rfind("\n ")
            if i2 != -1 and i2 >= i1:
                i2 = r.stderr.find("\n", i2 + 1)
                if i2 == -1:
                    ps = r.stderr[i1 + 1:]
                else:
                    ps = r.stderr[i1 + 1:i2].strip()
                r = str(ctx.path(".")) + "/"
                for p in ps.split("\n"):
                    p = str(ctx.path(p.strip()))
                    ds.append(p[len(r):] if p.startswith(r) else p)
    return ds


def _if_cc(cmd, opt):
    r = cmd[0].execute([cmd[1], opt, "-o", "/dev/null", "-c", cmd[-1]])
    return r.stderr.find(opt) == -1


def _cc_if(cmd, opt):
    return [opt] if _if_cc(cmd, opt) else []


def _if_ld(cmd, opt, pat):
    r = cmd[0].execute([cmd[1], opt, "-o", "/dev/null", cmd[-1]])
    return r.stderr.find(pat) == -1


def _ld_if(cmd, opt, pat):
    return [opt] if _if_ld(cmd, opt, pat) else []


def _if_gold(cmd):
    r = cmd[0].execute([cmd[1], "-fuse-ld=gold", "-o", "/dev/null", cmd[-1]])
    return r.return_code == 0


def _no_canonicals(cmd):
    opt = _cc_if(cmd, "-fno-canonical-system-headers")
    if opt:
        return opt
    return _cc_if(cmd, "-no-canonical-prefixes")


def _cat(*args):
    return [e for es in args for e in es]


def _uniq(*args):
    return {e: None for es in args for e in es}.keys()


def _content(cmd, name):
    if_gold = _if_gold(cmd)
    no_canonicals = _no_canonicals(cmd)
    b_flag = []  # ["-B" + str(cmd[1].dirname)]
    return {
        # "supports_dsym": true,
        # "dynamic_runtimes_filegroup": "dynamic-runtime-libs-k8",
        # "static_runtimes_filegroup": "static-runtime-libs-k8"
        "supports_embedded_runtimes":
        name == "clang",
        "supports_fission":
        name == "clang",
        "supports_gold_linker":
        if_gold,
        "supports_incremental_linker":
        name == "clang",
        "supports_interface_shared_objects":
        name == "clang",
        "supports_normalizing_ar":
        name == "clang",
        "supports_start_end_lib":
        if_gold,
        "supports_thin_archives":
        name == "clang",
        "cxx_flag": ["-std=c++0x"],
        "linker_flag":
        _cat(
            _cc_if(cmd, "-pass-exit-codes"),
            b_flag,
            [
                "-lstdc++",
                "-lm",
            ],
            (["-fuse-ld=gold"] if if_gold else []),
            _ld_if(cmd, "-Wl,-z,relro,-z,now", "-z"),
            _ld_if(cmd, "-Wl,-no-as-needed", "-no-as-needed"),
        ),
        "cxx_builtin_include_directory":
        _uniq(
            _inc_dirs(cmd, "-xc"),
            _inc_dirs(cmd, "-xc++"),
            _inc_dirs(cmd, "-xc", no_canonicals),
            _inc_dirs(cmd, "-xc++", no_canonicals),
        ),
        "objcopy_embed_flag": [
            "-I",
            "binary",
        ],
        "unfiltered_cxx_flag": ([
            "-Wno-builtin-macro-redefined",
            "-D__DATE__=\\\"redacted\\\"",
            "-D__TIME__=\\\"redacted\\\"",
            "-D__TIMESTAMP__=\\\"redacted\\\"",
        ] + no_canonicals),
        "compiler_flag": ([
            "-Wall",
            "-U_FORTIFY_SOURCE",
            "-fstack-protector",
            "-fno-omit-frame-pointer",
        ] + _cat(
            _cc_if(cmd, "-fcolor-diagnostics"),
            _cc_if(cmd, "-Wself-assign"),
            _cc_if(cmd, "-Wthread-safety"),
            _cc_if(cmd, "-Wno-free-nonheap-object"),
            _cc_if(cmd, "-Wunused-but-set-parameter"),
            _cc_if(cmd, "-Wno-invalid-partial-specialization"),
        ))
    }


def _opt(cmd):
    return {
        "compiler_flag": [
            "-g0",
            "-O2",
            "-D_FORTIFY_SOURCE=1",
            "-DNDEBUG",
            "-ffunction-sections",
            "-fdata-sections",
        ],
        "linker_flag":
        _ld_if(cmd, "-Wl,--gc-sections", "-gc-sections"),
    }


def _dbg():
    return {"compiler_flag": "-g"}


def _coverage(name):
    if name == "clang":
        c_flags = """flag_group {
        flag: '-fprofile-instr-generate'
        flag: '-fcoverage-mapping'
      }"""
        l_flags = """flag_group {
        flag: '-fprofile-instr-generate'
      }"""
    else:
        c_flags = """flag_group {
        flag: '--coverage'
      }"""
        l_flags = """flag_group {
        flag: '--coverage'
      }"""
    return """
    feature {
      name: 'coverage'
      provides: 'profile'
      flag_set {
        action: 'preprocess-assemble'
        action: 'c-compile'
        action: 'c++-compile'
        action: 'c++-header-parsing'
        action: 'c++-module-compile'
        """ + c_flags + """
      }
      flag_set {
        action: 'c++-link-dynamic-library'
        action: 'c++-link-nodeps-dynamic-library'
        action: 'c++-link-executable'
        """ + l_flags + """
      }
    }
  """


def _paths(ctx, *args):
    return {lb: ctx.path(Label(lb)) for lbs in args for lb in lbs}


load("@//cc:BUILD.bzl", "build_tpls", "build_maps")
load("@//cc:CROSSTOOL.bzl", "crosstool_tpls")


def _cc_configure(ctx):
    e = "tools/empty.cc"
    ctx.file(e, "int main() {}")
    paths = _paths(
        ctx,
        [str(t) for t in ctx.attr.stacks.keys()],
        [
            "@//cc:BUILD.tpl",
            "@//cc:CROSSTOOL.tpl",
            "@//cc:cc_wrapper.tpl",
            "@lib_nvidia//:cuda_cudnn/bin/host",
            "@lib_nvidia//:cuda_cudnn/bin/nvcc",
        ],
    )
    cmd = [ctx, None, e]
    count = len(ctx.attr.stacks)
    ctx.template(
        "BUILD",
        paths["@//cc:BUILD.tpl"],
        {
            "%{content}": "\n".join(build_tpls(count)),
            "%{mapping}": "\n".join(build_maps(count)),
        },
    )
    ctx.template(
        "CROSSTOOL",
        paths["@//cc:CROSSTOOL.tpl"],
        {
            "%{content}": "\n".join(crosstool_tpls(count)),
        },
    )
    for i, item in enumerate(ctx.attr.stacks.items()):
        ii = "_{}".format(i) + "}"
        t, full = item
        cc = str(paths[str(t)])
        cmd[1] = cc
        stack, name = full.split("_")
        if name == "gcc":
            ctx.template(
                "cc_wrapper_{}.sh".format(i),
                paths["@//cc:cc_wrapper.tpl"],
                {
                    "%{cc}": cc,
                    "%{host}": str(paths["@lib_nvidia//:cuda_cudnn/bin/host"]),
                    "%{nvcc}": str(paths["@lib_nvidia//:cuda_cudnn/bin/nvcc"]),
                },
            )
        subs = {
            "%{" + n + ii: str(l)
            for n, l in _labels(ctx, stack, name).items()
        }
        subs.update({
            "%{full" + ii:
            full,
            "%{stack" + ii:
            stack,
            "%{wrappers" + ii:
            str(["cc_wrapper_{}.sh".format(i)] if name == "gcc" else []),
            "%{includes" + ii:
            str([]),
            "%{libraries" + ii:
            str([]),
            "%{xray" + ii:
            str([]),
        })
        ctx.template("BUILD", "BUILD", subs)
        ctx.template(
            "CROSSTOOL",
            "CROSSTOOL",
            {
                "%{full" + ii:
                full,
                "%{content" + ii:
                "\n".join([
                    _dict_str(_content(cmd, name)),
                    _tool_paths(ctx, stack, name, i)
                ]),
                "%{opt_content" + ii:
                _dict_str(_opt(cmd), "    "),
                "%{dbg_content" + ii:
                _dict_str(_dbg(), "    "),
                "%{cov_content" + ii:
                _coverage(name),
            },
        )

cc_configure = repository_rule(
    implementation=_cc_configure,
    attrs={
        "stacks":
        attr.label_keyed_string_dict(
            allow_empty=False,
            allow_files=True,
            mandatory=True,
        ),
    },
)
