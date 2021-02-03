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


def crosstool_tpls(count):
    t = """
toolchain {
  toolchain_identifier: "id-%{full_#}"
  compiler: "%{full_#}"
  target_cpu: "k8"
  abi_version: "local"
  target_libc: "local"
  abi_libc_version: "local"
  host_system_name: "local"
  target_system_name: "local"

  needsPic: true
  builtin_sysroot: ""
%{content_#}

  compilation_mode_flags {
    mode: DBG
%{dbg_content_#}
  }
  compilation_mode_flags {
    mode: OPT
%{opt_content_#}
  }
  linking_mode_flags { mode: DYNAMIC }

%{cov_content_#}

  feature {
    name: 'fdo_optimize'
    provides: 'profile'
    flag_set {
      action: 'c-compile'
      action: 'c++-compile'
      expand_if_all_available: 'fdo_profile_path'
      flag_group {
        flag: '-fprofile-use=%{fdo_profile_path}'
        flag: '-fprofile-correction',
      }
    }
  }
}

"""
    return [t.replace("_#", "_{}".format(i)) for i in range(count)]
