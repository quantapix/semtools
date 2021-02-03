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

from pesto.keys import K
from pesto.repo import Repo
from pesto.root import Root


class Workspace(Root):
    def links(self):
        for n in self.cspecs.get(K.LINKS, K.NAMES).split(','):
            yield 'sys/bin', n

    def repos(self):
        cs = self.cspecs
        for s in self.sections(flag=K.ACTIVE):
            r = self.from_submodule(s, K.REPO)
            assert cs.has_section(r)
            p = self.to_path(s)
            n = p.replace('/' + K.UPSTREAM, '')
            n = n.replace('/', '_').replace('-', '_')
            ms = self.from_submodule(s, K.MAPS)

            def maps():
                for s, d in cs.items(ms):
                    if s not in self.defaults:
                        yield s, d

            ms = tuple(maps()) if cs.has_section(ms) else None
            yield n, p, ms

    def binds(self):
        cs = self.cspecs
        for s in self.sections(flag=K.ACTIVE):
            b = self.from_submodule(s, K.BINDS)
            if cs.has_section(b):
                for f, t in cs.items(b):
                    if f not in self.defaults:
                        yield f, t

    def repatch_all(self):
        for n, _ in self.branches():
            Repo(n, root=self.root).repatch()

    def commit_all(self):
        for n, _ in self.branches():
            Repo(n, root=self.root).commit()

    def pull_all(self):
        for n, _ in self.branches():
            Repo(n, root=self.root).pull()

    def reset(self):
        self.root_sh.run(
            'git submodule update -f',
            "git submodule foreach 'git clean -fxd'",
        )


if __name__ == '__main__':
    import os
    p = os.environ.get('PESTO_ROOT')
    from argparse import ArgumentParser
    args = ArgumentParser()
    args.add_argument('-p', '--root', help='Path to root', default=p)
    st = 'store_true'
    args.add_argument('-r', '--repatch', action=st, help='Repatch all')
    args.add_argument('-c', '--commit', action=st, help='Commit all')
    args.add_argument('-u', '--pull', action=st, help='Pull all')
    args.add_argument('-s', '--reset', action=st, help='Reset all')
    args = args.parse_args()
    w = Workspace(root=args.root)
    if args.repatch:
        w.repatch_all()
    elif args.commit:
        w.commit_all()
    elif args.pull:
        w.pull_all()
    elif args.reset:
        w.reset()
