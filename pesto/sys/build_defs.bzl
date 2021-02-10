
syslibs = [
    # "astor_archive",
    # "com_googlesource_code_re2",
    "curl",
    "gif_archive",
    # "jemalloc",
    # "jpeg",
    # "jsoncpp_git",
    "lmdb",
    "nasm",
    "org_sqlite",
    "pcre",
    # "png_archive",
    # "six_archive",
    # "snappy",
    "swig",
    # "termcolor_archive",
    "zlib_archive",
    # "cython",
    # "flatbuffers",
    # "grpc",
    # "nsync",
]


def if_any_system_libs(a, b=[]):
    return a


def if_system_lib(lib, a, b=[]):
    if lib in syslibs:
        return a
    else:
        return b


def if_not_system_lib(lib, a, b=[]):
    return if_system_lib(lib, b, a)
