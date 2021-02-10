

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
