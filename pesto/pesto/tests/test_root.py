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
from pesto.root import Root


class TestRoot:
    def test_add_modules(self, root_repo, root_modules):
        r = root_repo
        c = r.read_config()
        assert len(tuple(r.section_filter(c, K.SUBMODULE))) == 0
        r.sync_config()
        ms = set(root_modules)
        for s in r.submodules():
            ms.remove(s[2:])
        assert 'm0' in ms and len(ms) == 1
        r.commit_all()

    def test_deinit_modules(self, root_repo):
        r = root_repo
        r.sync_config({K.VALID: True, K.ACTIVE: False})
        for ln in r.root_sh.out('git submodule status').splitlines():
            assert ln.startswith('-')

    def test_reinit_modules(self, root_repo):
        r = root_repo
        r.sync_config()
        for ln in r.root_sh.out('git submodule status').splitlines():
            assert not ln.startswith('-')

    def test_rm_modules(self, modules_base):
        r = Root(modules_base / 'r', {})
        r.sync_config()
        c = r.read_config()
        assert len(tuple(r.section_filter(c, K.SUBMODULE))) == 0
        r.commit_all()
