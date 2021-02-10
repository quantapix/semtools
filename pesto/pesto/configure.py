#!/usr/bin/python

from pesto.keys import K
from pesto.templates import T
from pesto.workspace import Workspace


def write_build(path, txt):
    if (path / 'BUILD').exists():
        txt += '\n' + (path / 'BUILD').read_text()
    (path / 'BUILD.bazel').write_text(T.COPYRIGHT + txt)


def configure(ws):
    ws.synchronize()
    for p, n in ws.links():
        ws.root_sh.run('(cd {}; ln -sf $(which {}))'.format(p, n))
    ss, rs, bs = set(), set(), set()
    i, ii = '\n    ', '\n        '
    rp = ws.root_sh.path
    for n, p, ms in ws.repos():
        # ws.root_sh.run('touch {}/{}'.format(p, 'WORKSPACE'))
        print(n)
        t = 'local_repository({}name="{}",'.format(i, n)
        t += '{}path="{}"'.format(i, p)
        if ms:
            t += ',{}repo_mapping='.format(i) + '{'
            ms = {'"{}": "{}",'.format(s, d) for s, d in ms}
            t += ii + ii.join(sorted(ms)) + i + '}'
        t += ',\n)'
        rs.add(t)
        p = p.replace('/' + K.UPSTREAM, '')
        write_build(rp / p, T.REPO.format(rp, p))
    for n, p in ws.binds():
        bs.add('bind({}name="{}",{}actual="{}",\n)'.format(i, n, i, p))
    t = T.HEADER + '\n'.join(sorted(ss) + sorted(rs) + sorted(bs)) + T.FOOTER
    (rp / 'WORKSPACE').write_text(T.COPYRIGHT + t)
    write_build(rp, T.ROOT.format(rp))


if __name__ == '__main__':
    import os
    p = os.environ.get('PESTO_ROOT')
    from argparse import ArgumentParser
    args = ArgumentParser()
    args.add_argument('-p', '--root', help='Path to root', default=p)
    args = args.parse_args()
    configure(Workspace(root=args.root))
