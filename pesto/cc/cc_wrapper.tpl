#!/usr/bin/python
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

import argparse
import os
import subprocess
import re
import sys
import pipes

CC = '%{cc}'
HOST = '%{host}'
NVCC = '%{nvcc}'


def _host_opts(argv):
    p = argparse.ArgumentParser()
    p.add_argument('-isystem', nargs='*', action='append')
    p.add_argument('-iquote', nargs='*', action='append')
    p.add_argument('--sysroot', nargs=1)
    p.add_argument('-g', nargs='*', action='append')
    p.add_argument('-fno-canonical-system-headers', action='store_true')
    args, _ = p.parse_known_args(argv)
    opts = ''
    if args.isystem:
        opts += ' -isystem ' + ' -isystem '.join(sum(args.isystem, []))
    if args.iquote:
        opts += ' -iquote ' + ' -iquote '.join(sum(args.iquote, []))
    if args.g:
        opts += ' -g' + ' -g'.join(sum(args.g, []))
    if args.fno_canonical_system_headers:
        opts += ' -fno-canonical-system-headers'
    if args.sysroot:
        opts += ' --sysroot ' + args.sysroot[0]
    return opts


def _nvcc_opts(argv):
    p = argparse.ArgumentParser()
    p.add_argument('-nvcc_options', nargs='*', action='append')
    args, _ = p.parse_known_args(argv)
    opts = ''
    if args.nvcc_options:
        fix = {"relaxed-constexpr": "expt-relaxed-constexpr"}
        for o in args.nvcc_options:
            opts += ' --' + fix.get(o, o)
    return opts


def _opt(argv, opt):
    p = argparse.ArgumentParser()
    p.add_argument('-' + opt, nargs='*', action='append')
    args, _ = p.parse_known_args(argv)
    if args:
        return sum(vars(args).get(opt, []), [])
    return []


def nvcc(argv):
    host = _host_opts(argv)

    srcs = _opt(argv, 'c')
    if len(srcs) == 0:
        return 1
    srcs = [f for f in srcs if re.search(r'\.cpp$|\.cc$|\.c$|\.cxx$|\.C$', f)]
    srcs = ' '.join(srcs)

    out = _opt(argv, 'o')
    if len(out) != 1:
        return 1
    out = ' -o ' + out[0]

    incs = _opt(argv, 'I')
    incs = (' -I ' + ' -I '.join(incs)) if len(incs) > 0 else ''

    opt = _opt(argv, 'O')
    opt = ' -O2' if len(opt) > 0 and int(opt[0]) > 0 else ' -g -G'

    cmd = '-D_FORCE_INLINES '
    for c in ("61", "70"):
        cmd += '-gencode=arch=compute_{},\"code=sm_{},compute_{}\" '.format(c)
    cmd += ' ' + _nvcc_opts(argv)
    cmd += ''.join([' -U' + u for u in _opt(argv, 'U')])
    cmd += ''.join([' -D' + d for d in _opt(argv, 'D')])
    cmd += ''.join([' -std=' + s for s in _opt(argv, 'std')])
    cmd += ''.join([' -m' + m for m in _opt(argv, 'm') if m in ['32', '64']])
    cmd += ' -w' if '-w' in argv else ''

    deps = _opt(argv, 'MF')
    if deps:
        d = deps[0]
        c = (NVCC + ' ' + cmd + ' --compiler-options "' + host + '"' +
             ' --compiler-bindir=' + HOST + ' -I .' + ' -x cu ' + opt + incs +
             ' ' + srcs + ' -M -o ' + d)
        s = os.system(c)
        if s != 0:
            return s
    cmd = (NVCC + ' ' + cmd + ' --compiler-options "' + host + ' -fPIC"' +
           ' --compiler-bindir=' + HOST + ' -I .' + ' -x cu ' + opt + incs +
           ' -c ' + srcs + out)
    # cmd = 'PATH=' + PREFIX_DIR + ':$PATH ' + cmd
    return os.system(cmd)


def main():
    p = argparse.ArgumentParser()
    p.add_argument('-x', nargs=1)
    p.add_argument('--cuda_log', action='store_true')
    args, other = p.parse_known_args(sys.argv[1:])
    if args.x and args.x[0] == 'cuda':
        other = [pipes.quote(o) for o in other]
        return nvcc(other)
    fs = [f for f in sys.argv[1:] if not f.startswith(('--cuda_log'))]
    return subprocess.call([CC] + fs)


if __name__ == '__main__':
    sys.exit(main())
