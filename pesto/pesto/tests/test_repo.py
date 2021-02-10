
from pesto.keys import K


class TestRepo:
    def test_replay_0(self, repo_first):
        r = repo_first
        c = r.read_config()
        assert len(tuple(r.section_filter(c, K.SUBMODULE))) == 0
        r.sync_config()
        r.commit_all()
        r.replay()
        assert replay_0 in r.sh.out('git status')

    def test_rediff_1(self, repo_first):
        r = repo_first
        r.sh.run(
            'echo "bbb\nccc\nddd" > a',
            'touch b',
        )
        assert rediff_1_1 in r.sh.out('git diff')
        r.replay()
        r.rediff()
        assert rediff_1_1 in r.sh.out('git diff')
        assert rediff_1_2 in r.sh.out('git status')

    def test_rediff_2(self, repo_first):
        r = repo_first
        r.sh.run('touch b2')
        assert rediff_1_1 in r.sh.out('git diff')
        r.sh.run('git add a b')
        r.replay()
        r.rediff()
        assert not r.sh.out('git diff')
        assert rediff_2 in r.sh.out('git status')

    def test_commit_1(self, repo_first):
        r = repo_first
        assert not r.sh.out('git diff')
        r.commit('qpx')
        assert commit_1_1 in r.root_sh.out('git status')
        r.commit_all()
        r.replay()
        assert commit_1_2 in r.sh.out('git status')
        assert commit_1_3 in r.root_sh.out('git status')

    def test_commit_2(self, repo_second):
        r = repo_second
        r.replay()
        print(r.sh.out('git status'))
        r.pull()
        print(r.root_sh.out('git status'))
        r.commit_all()
        r.replay()
        print(r.sh.out('git status'))
        print(r.root_sh.out('git status'))


replay_0 = """On branch pesto_master
nothing to commit, working tree clean"""

rediff_1_1 = """--- i/a
+++ w/a
@@ -1,2 +1,3 @@
 bbb
+ccc
 ddd
"""

rediff_1_2 = """On branch pesto_master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   a

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	b

no changes added to commit (use "git add" and/or "git commit -a")
"""

rediff_2 = """On branch pesto_master
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

	modified:   a
	new file:   b

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	b2
"""

commit_1_1 = """On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)
  (commit or discard the untracked or modified content in submodules)

	modified:   m/m1/upstream (untracked content)

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	m/m1/0001-qpx.patch

no changes added to commit (use "git add" and/or "git commit -a")"""

commit_1_2 = """On branch pesto_master
Untracked files:
  (use "git add <file>..." to include in what will be committed)

	b2

nothing added to commit but untracked files present (use "git add" to track)"""

commit_1_3 = """On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)
  (commit or discard the untracked or modified content in submodules)

	modified:   m/m1/upstream (new commits, untracked content)

Submodules changed but not updated:

* m/m1/upstream"""
