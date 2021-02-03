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
