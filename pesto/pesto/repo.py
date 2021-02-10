#!/usr/bin/python

from contextlib import contextmanager

from pesto.keys import K
from pesto.root import Root, Shell

BASE = ' pesto_base'
HEAD = ' pesto_head'

PATCHES = '/*.patch'


class Repo(Root):
    def __init__(self, name, branch=None, **kw):
        super().__init__(**kw)
        self.name = name or None
        self.patches = self.name + PATCHES
        self.old_patches = self.name + '/old_patches'
        self.sh = Shell(self.root / self.name / K.UPSTREAM)
        self.branch = branch or dict(self.branches())[self.name]
        self.upstream = ' origin/' + self.branch

    @contextmanager
    def stashing(self):
        self.sh.run('git tag -f' + HEAD)
        b = self.sh.out('git rev-parse --abbrev-ref HEAD').strip()
        if b != 'patched':
            b = 'patched'
            self.sh.out('git checkout -B ' + b)
        f = 'No local changes to save' not in self.sh.out('git stash -a')
        yield None if b == 'HEAD' else (' ' + b)
        if f:
            self.sh.run('git stash pop')
        self.sh.run(
            'git tag -d' + BASE,
            'git tag -d' + HEAD,
        )

    def _repatch(self, branch, update, pull=False):
        self.root_sh.run(
            'rm -rf ' + self.old_patches,
            'mkdir -p ' + self.old_patches,
            'touch {}/dummy.patch'.format(self.name),
            'mv {} {}/'.format(self.patches, self.old_patches),
            ('git checkout -- ' + self.patches) if not update else None,
            'git submodule update -- ' + self.name,
        )
        ps = tuple(self.root_sh.path.glob(self.patches))
        self.sh.run(
            'git tag -f' + BASE,
            ('git am -3 ..' + PATCHES) if len(ps) else None,
            'git merge --squash' + HEAD,
            'git commit -C' + HEAD,
            ('git fetch origin') if pull else None,
            ('git tag -f' + BASE + self.upstream) if pull else None,
            ('git rebase' + BASE) if pull else None,
            ('git format-patch -M -B -o ..' + BASE) if update else None,
            ('git branch -f' + branch) if branch else None,
            ('git checkout' + branch) if branch else None,
        )
        return self.sh.out('git log -1 --pretty=%B')

    def repatch(self, update=False):
        with self.stashing() as branch:
            self._repatch(branch, update)

    def commit(self, pull=False):
        with self.stashing() as branch:
            m = self._repatch(branch, update=True, pull=pull)
            self.sh.run(
                ('git tag -f' + HEAD) if not branch else None,
                'git checkout ' + self.branch,
                ('git merge' + self.upstream) if pull else None,
            )
            self.root_sh.run(
                'git add -- ' + self.name + '/upstream',
                'git add -- \"' + self.patches + '\"',
                'git commit -m "{}"'.format(m),
            )
            self.sh.run('git checkout' + (branch or HEAD))

    def pull(self):
        self.commit(pull=True)


if __name__ == '__main__':
    import os
    p = os.environ.get('PESTO_ROOT')
    from argparse import ArgumentParser
    args = ArgumentParser()
    args.add_argument('-p', '--root', help='Path to root', default=p)
    args.add_argument('-n', '--name', help='Name of repo')
    args.add_argument('-b', '--branch', help='Branch')
    st = 'store_true'
    args.add_argument('-r', '--repatch', action=st, help='Repatch branch')
    args.add_argument('-d', '--rediff', action=st, help='Rediff branch')
    args.add_argument('-c', '--commit', action=st, help='Commit diffs')
    args.add_argument('-u', '--pull', action=st, help='Pull upstream')
    args = args.parse_args()
    r = Repo(args.name, args.branch, root=args.root)
    if args.repatch:
        r.repatch()
    elif args.rediff:
        r.repatch(update=True)
    elif args.commit:
        r.commit()
    elif args.pull:
        r.pull()
