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


def if_rocm(if_true, if_false=[]):
    return if_false


def rocm_default_copts():
    return if_rocm([])


def rocm_copts(opts=[]):
    return rocm_default_copts() + [] + if_rocm_is_configured(opts)


def rocm_is_configured():
    return False


def if_rocm_is_configured(x):
    if rocm_is_configured():
        return x
    return []
