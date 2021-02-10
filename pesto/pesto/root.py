
import pathlib as pth
import subprocess as sub
import configparser as cpr

from pesto.keys import K
from pesto.specs import SPECS


class Shell:
    def __init__(self, path):
        self.path = path
        self.trace = []

    def run(self, *cmds):
        c = ';'.join((c for c in cmds if c is not None))
        print('==>', c)
        r = sub.run(
            c,
            cwd=self.path,
            capture_output=True,
            shell=True,
            text=True,
        )
        self.trace.append(r)
        if r.stdout:
            print(r.stdout, end='')
        if r.stderr:
            print('***', r.stderr, end='')
        return r

    def out(self, *cmds):
        return self.run(*cmds).stdout


def section_filter(sections, pattern=None, flag=None):
    for s, _ in sections.items():
        if pattern is None or pattern in s:
            if flag is None or sections.getboolean(s, flag):
                yield s


class Root:

    _config = None
    _cspecs = None

    defaults = {K.VALID: True, K.ACTIVE: True}

    @staticmethod
    def to_submodule(title):
        return title.replace(K.REPO, K.SUBMODULE)[:-1] + '/' + K.UPSTREAM + '"'

    @staticmethod
    def from_submodule(title, to):
        return title.replace(K.SUBMODULE, to).replace('/' + K.UPSTREAM, '')

    @staticmethod
    def to_path(title):
        return title[len(K.SUBMODULE + ' "'):-1]

    @staticmethod
    def to_name(title):
        return title[len(K.REPO + ' "'):-1]

    def __init__(self, root=None, specs=None):
        self.root = pth.Path.cwd() if root is None else pth.Path(root)
        self.specs = SPECS if specs is None else specs
        self.root_sh = Shell(self.root)

    def read_config(self, defaults=None, files=('.git/config', '.gitmodules')):
        c = cpr.ConfigParser(defaults or {K.ACTIVE: False})
        c.read(self.root / f for f in files)
        return c

    @property
    def config(self):
        if self._config is None:
            self._config = self.read_config()
        return self._config

    def sections(self, pattern=K.SUBMODULE, flag=None):
        for s, _ in self.config.items():
            if pattern is None or pattern in s:
                if flag is None or self.config.getboolean(s, flag):
                    yield s

    def branches(self):
        for s in self.sections(flag=K.ACTIVE):
            r = self.from_submodule(s, K.REPO)
            n = self.to_name(r)
            yield n, self.cspecs.get(r, K.BRANCH, fallback='master')

    def specs_as_config(self, defaults=None, name='repo.specs'):
        c = cpr.ConfigParser(defaults or self.defaults)
        p = self.root / name
        if p.exists():
            c.read(p)
        else:
            c.read_dict(self.specs, name)
            # with open(p, 'w') as f:
            #     c.write(f)
        return c

    @property
    def cspecs(self):
        if self._cspecs is None:
            self._cspecs = self.specs_as_config()
        return self._cspecs

    def synchronize(self):
        sh = self.root_sh
        cs = self.cspecs
        for s in self.sections():
            r = self.from_submodule(s, K.REPO)
            if not cs.has_section(r) or not cs.getboolean(r, K.VALID):
                p = self.to_path(s)
                if self.config.getboolean(s, K.ACTIVE):
                    sh.run('git submodule deinit -- ' + p)
                sh.run(
                    'git rm ' + p,
                    'rm -rf .git/modules/' + p,
                )
        for s in section_filter(cs, K.REPO, K.VALID):
            sa = cs.getboolean(s, K.ACTIVE)
            m = self.to_submodule(s)
            p = self.to_path(m)
            if self.config.has_section(m):
                ca = self.config.getboolean(m, K.ACTIVE)
                if ca and not sa:
                    sh.run('git submodule deinit -- ' + p)
                elif not ca and sa:
                    sh.run('git submodule update --init ' + p)
            else:
                (self.root / p).parent.mkdir(parents=True, exist_ok=True)
                u = cs.get(s, K.URL)
                sh.run('git submodule add -- ' + u + ' ' + p)

    def commit(self, message):
        self.root_sh.run(
            'git add .',
            'git commit -m "{}"'.format(message),
        )
