
# python -m pytest -s pesto

import pytest

import pathlib as pth

from pesto.keys import K
from pesto.repo import Repo
from pesto.root import Root, Shell


@pytest.fixture(scope="session")
def root_modules():
    return ['m{}'.format(i) for i in range(4)]


@pytest.fixture(scope="module")
def modules_base(tmpdir_factory, root_modules):
    b = pth.Path(tmpdir_factory.mktemp('pesto'))
    sh = Shell(b)
    for n in ('r', *root_modules):
        sh.run('git init -q ' + n)
        sh.run(
            '(cd ' + n,
            'echo "bbb\nddd" > a',
            'touch a2',
            'git add .',
            'git commit -qm "upstream"',
            ')',
        )
    yield b
    sh.run('rm -rf ' + ' '.join(n for n in ('r', *root_modules)))


@pytest.fixture(scope="module")
def modules_specs(modules_base, root_modules):
    host = 'qblk:'
    ss = {
        K.REPO + ' "m/{}"'.format(m): {
            K.URL: host + str((modules_base / m).resolve()),
        }
        for m in root_modules
    }
    ss[K.REPO + ' "m/m0"'][K.VALID] = False
    return ss


@pytest.fixture(scope="module")
def root_repo(modules_base, modules_specs):
    return Root(modules_base / 'r', modules_specs)


@pytest.fixture(scope="module")
def repo_first(modules_base, modules_specs):
    return Repo('m/m1', root=modules_base / 'r', specs=modules_specs)


@pytest.fixture(scope="module")
def repo_second(repo_first):
    r = repo_first
    r.root_sh.run(
        '(cd ../m1',
        'echo "aaa\nbbb\nddd\neee" > a',
        'touch a3',
        'git add .',
        'git commit -m "upstream"',
        ')',
    )
    return r
