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

_shared = ['ar', 'as', 'dwp', 'nm', 'objcopy', 'objdump']

_tools = [n for n in _shared
          ] + ['cc', 'cpp', 'gcc', 'g++', 'gcov', 'ld', 'gprof', 'strip']

_tools += [('llvm-' + n) for n in _shared
           ] + ['clang', 'llvm-cov', 'ld.lld', 'llvm-profdata', 'llvm-xray']

SPECS = {
    K.LINKS: {
        K.NAMES: ','.join(_tools),
    },
    K.REPO + ' "bazel"': {
        K.URL: 'https://github.com/bazelbuild/bazel.git',
    },
    K.REPO + ' "emacs"': {
        K.URL: 'https://github.com/emacs-mirror/emacs.git'
    },
    K.REPO + ' "git"': {
        K.URL: 'https://github.com/git/git.git',
    },
    K.REPO + ' "julia"': {
        K.URL: 'https://github.com/JuliaLang/julia.git',
    },
    K.REPO + ' "rtags"': {
        K.URL: 'https://github.com/Andersbakken/rtags.git',
    },
    K.REPO + ' "python"': {
        K.URL: 'https://github.com/python/cpython.git',
        # K.BRANCH: '3.7',
    },
    K.REPO + ' "tensorflow"': {
        K.URL: 'https://github.com/tensorflow/tensorflow.git',
    },
    K.REPO + ' "tensorboard"': {
        K.URL: 'https://github.com/tensorflow/tensorboard.git',
    },
    K.REPO + ' "bzl/rules/closure"': {
        K.URL: 'https://github.com/bazelbuild/rules_closure.git',
    },
    K.REPO + ' "bzl/rules/python"': {
        K.URL: 'https://github.com/bazelbuild/rules_python.git',
    },
    K.REPO + ' "bzl/skydoc"': {
        K.URL: 'https://github.com/bazelbuild/skydoc.git',
    },
    K.REPO + ' "bzl/skylib"': {
        K.URL: 'https://github.com/bazelbuild/bazel-skylib.git',
    },
    K.REPO + ' "bzl/toolchains"': {
        K.URL: 'https://github.com/bazelbuild/bazel-toolchains.git',
    },
    K.REPO + ' "cc/gcc"': {
        K.URL: 'https://github.com/gcc-mirror/gcc.git',
        # K.BRANCH: 'gcc-8-branch',
    },
    K.REPO + ' "cc/clang"': {
        K.URL: 'https://github.com/llvm-mirror/clang.git',
        # K.BRANCH: 'release_70',
    },
    K.REPO + ' "cc/clang_tools_extra"': {
        K.URL: 'https://github.com/llvm-mirror/clang-tools-extra.git',
        # K.BRANCH: 'release_70',
    },
    K.REPO + ' "cc/compiler_rt"': {
        K.URL: 'https://github.com/llvm-mirror/compiler-rt.git',
        # K.BRANCH: 'release_70',
    },
    K.REPO + ' "cc/llvm"': {
        K.URL: 'https://github.com/llvm-mirror/llvm.git',
        # K.BRANCH: 'release_70',
    },
    K.REPO + ' "dnn/benchmarks"': {
        K.URL: 'https://github.com/tensorflow/benchmarks.git',
    },
    K.REPO + ' "dnn/infer"': {
        K.URL: 'https://github.com/dotnet/infer.git',
    },
    K.REPO + ' "dnn/keras"': {
        K.URL: 'https://github.com/keras-team/keras.git',
    },
    K.REPO + ' "dnn/keras_applications"': {
        K.URL: 'https://github.com/keras-team/keras-applications.git',
    },
    K.REPO + ' "dnn/keras_contrib"': {
        K.URL: 'https://github.com/keras-team/keras-contrib.git',
    },
    K.REPO + ' "dnn/keras_preprocessing"': {
        K.URL: 'https://github.com/keras-team/keras-preprocessing.git',
    },
    K.REPO + ' "dnn/lingvo"': {
        K.URL: 'https://github.com/tensorflow/lingvo.git',
    },
    K.REPO + ' "dnn/models"': {
        K.URL: 'https://github.com/tensorflow/models.git',
    },
    K.REPO + ' "dnn/ngraph"': {
        K.URL: 'https://github.com/NervanaSystems/ngraph.git',
    },
    K.REPO + ' "dnn/ngraph_tf"': {
        K.URL: 'https://github.com/NervanaSystems/ngraph-tf.git',
    },
    K.REPO + ' "dnn/probability"': {
        K.URL: 'https://github.com/tensorflow/probability.git',
    },
    K.REPO + ' "dnn/tensor2tensor"': {
        K.URL: 'https://github.com/tensorflow/tensor2tensor.git',
    },
    K.REPO + ' "el/magit"': {
        K.URL: 'https://github.com/magit/magit.git',
    },
    K.REPO + ' "el/org_mode"': {
        K.URL: 'https://code.orgmode.org/bzg/org-mode.git',
    },
    K.REPO + ' "el/spacemacs"': {
        K.URL: 'https://github.com/syl20bnr/spacemacs.git',
    },
    K.REPO + ' "google/benchmark"': {
        K.URL: 'https://github.com/google/benchmark.git',
    },
    K.REPO + ' "google/boringssl"': {
        K.URL: 'https://github.com/google/boringssl.git',
        K.BRANCH: 'master-with-bazel',
    },
    K.REPO + ' "google/double_conversion"': {
        K.URL: 'https://github.com/google/double-conversion.git',
    },
    K.REPO + ' "google/farmhash"': {
        K.URL: 'https://github.com/google/farmhash.git',
    },
    K.REPO + ' "google/flatbuffers"': {
        K.URL: 'https://github.com/google/flatbuffers.git',
    },
    K.REPO + ' "google/gemmlowp"': {
        K.URL: 'https://github.com/google/gemmlowp.git',
    },
    K.REPO + ' "google/googleapis"': {
        K.URL: 'https://github.com/googleapis/googleapis.git',
    },
    K.REPO + ' "google/googletest"': {
        K.URL: 'https://github.com/google/googletest.git',
    },
    K.REPO + ' "google/highwayhash"': {
        K.URL: 'https://github.com/google/highwayhash.git',
    },
    K.REPO + ' "google/j2objc"': {
        K.URL: 'https://github.com/google/j2objc.git',
    },
    K.REPO + ' "google/nsync"': {
        K.URL: 'https://github.com/google/nsync.git',
        # K.BRANCH: 'v1.20.1',
    },
    K.REPO + ' "google/or_tools"': {
        K.URL: 'https://github.com/google/or-tools.git',
    },
    K.REPO + ' "google/pprof"': {
        K.URL: 'https://github.com/google/pprof.git',
    },
    K.REPO + ' "google/protobuf"': {
        K.URL: 'https://github.com/google/protobuf.git',
    },
    K.REPO + ' "google/re2"': {
        K.URL: 'https://github.com/google/re2.git',
    },
    K.REPO + ' "google/snappy"': {
        K.URL: 'https://github.com/google/snappy.git',
    },
    K.REPO + ' "lib/abseil"': {
        K.URL: 'https://github.com/abseil/abseil-cpp.git',
    },
    K.REPO + ' "lib/eigen"': {
        K.URL: 'https://github.com/eigenteam/eigen-git-mirror.git',
    },
    K.REPO + ' "lib/gflags"': {
        K.URL: 'https://github.com/gflags/gflags.git',
    },
    K.REPO + ' "lib/grpc"': {
        K.URL: 'https://github.com/grpc/grpc.git',
        # K.BRANCH: 'v1.15.x',
    },
    K.REPO + ' "lib/jemalloc"': {
        K.URL: 'https://github.com/jemalloc/jemalloc.git',
        # K.BRANCH: 'stable-4',
    },
    K.REPO + ' "lib/jpeg"': {
        K.URL: 'https://github.com/libjpeg-turbo/libjpeg-turbo.git',
    },
    K.REPO + ' "lib/json"': {
        K.URL: 'https://github.com/open-source-parsers/jsoncpp.git',
    },
    K.REPO + ' "lib/linenoise"': {
        K.URL: 'https://github.com/antirez/linenoise.git',
    },
    K.REPO + ' "lib/mkl"': {
        K.URL: 'https://github.com/intel/mkl-dnn.git',
    },
    K.REPO + ' "lib/nlohmann_json"': {
        K.URL: 'https://github.com/nlohmann/json.git',
        K.BRANCH: 'release/3.2.0',
    },
    K.REPO + ' "lib/nvidia"': {
        K.URL: 'qblk:~/repos/nvidia.git',
    },
    K.REPO + ' "lib/nvtop"': {
        K.URL: 'https://github.com/Syllo/nvtop.git',
    },
    K.REPO + ' "lib/openblas"': {
        K.URL: 'https://github.com/xianyi/OpenBLAS.git',
        K.BRANCH: 'develop',
        # K.BRANCH: 'release-0.3.0',
    },
    K.REPO + ' "lib/png"': {
        K.URL: 'https://github.com/glennrp/libpng.git',
    },
    K.REPO + ' "lib/xsmm"': {
        K.URL: 'https://github.com/hfp/libxsmm.git',
        # K.BRANCH: 'release',
    },
    K.REPO + ' "nlp/CoreNLP"': {
        K.URL: 'https://github.com/stanfordnlp/CoreNLP.git',
    },
    K.REPO + ' "nlp/nltk"': {
        K.URL: 'https://github.com/nltk/nltk.git',
    },
    K.REPO + ' "nlp/spacy"': {
        K.URL: 'https://github.com/explosion/spaCy.git',
    },
    K.REPO + ' "py/pip"': {
        K.URL: 'https://github.com/pypa/pip.git',
    },
    K.REPO + ' "py/setuptools"': {
        K.URL: 'https://github.com/pypa/setuptools.git',
    },
    K.REPO + ' "py/wheel"': {
        K.URL: 'https://github.com/pypa/wheel.git',
    },
    K.REPO + ' "py/abseil"': {
        K.URL: 'https://github.com/abseil/abseil-py.git',
    },
    K.REPO + ' "py/astor"': {
        K.URL: 'https://github.com/berkerpeksag/astor.git',
    },
    K.REPO + ' "py/astroid"': {
        K.URL: 'https://github.com/PyCQA/astroid.git',
    },
    K.REPO + ' "py/autopep8"': {
        K.URL: 'https://github.com/hhatto/autopep8.git',
    },
    K.REPO + ' "py/camelot"': {
        K.URL: 'https://github.com/socialcopsdev/camelot.git',
    },
    K.REPO + ' "py/cython"': {
        K.URL: 'https://github.com/cython/cython.git',
    },
    K.REPO + ' "py/flake8"': {
        K.URL: 'https://github.com/PyCQA/flake8.git',
    },
    K.REPO + ' "py/gast"': {
        K.URL: 'https://github.com/serge-sans-paille/gast.git',
    },
    K.REPO + ' "py/glances"': {
        K.URL: 'https://github.com/nicolargo/glances.git',
    },
    K.REPO + ' "py/h5py"': {
        K.URL: 'https://github.com/h5py/h5py.git',
    },
    K.REPO + ' "py/jedi"': {
        K.URL: 'https://github.com/davidhalter/jedi.git',
    },
    K.REPO + ' "py/numpy"': {
        K.URL: 'https://github.com/numpy/numpy.git',
        # K.BRANCH: 'maintenance/1.15.x',
    },
    K.REPO + ' "py/pandas"': {
        K.URL: 'https://github.com/pandas-dev/pandas.git',
    },
    K.REPO + ' "py/pycodestyle"': {
        K.URL: 'https://github.com/PyCQA/pycodestyle.git',
    },
    K.REPO + ' "py/pylint"': {
        K.URL: 'https://github.com/PyCQA/pylint.git',
    },
    K.REPO + ' "py/pytest"': {
        K.URL: 'https://github.com/pytest-dev/pytest.git',
    },
    K.REPO + ' "py/pyyaml"': {
        K.URL: 'https://github.com/yaml/pyyaml.git',
    },
    K.REPO + ' "py/six"': {
        K.URL: 'https://github.com/benjaminp/six.git',
    },
    K.REPO + ' "py/termcolor"': {
        K.URL: 'https://github.com/hfeeki/termcolor.git',
    },
    K.REPO + ' "py/yapf"': {
        K.URL: 'https://github.com/google/yapf.git',
    },
    K.MAPS + ' "tensorflow"': {
        '@absl_py': '@py_abseil',
        '@astor_archive': '@py_astor',
        '@bazel_skylib': '@bzl_skylib',
        '@bazel_toolchains': '@bzl_toolchains',
        '@boringssl': '@google_boringssl',
        '@com_github_gflags_gflags': '@lib_gflags',
        '@com_github_googleapis_googleapis': '@google_googleapis',
        '@com_google_absl': '@lib_abseil',
        '@com_google_googletest': '@google_googletest',
        '@com_google_pprof': '@google_pprof',
        '@com_googlesource_code_re2': '@google_re2',
        '@curl': '@sys',
        '@cython': '@py_cython',
        '@double_conversion': '@google_double_conversion',
        '@eigen_archive': '@lib_eigen',
        '@farmhash_archive': '@google_farmhash',
        '@flatbuffers': '@google_flatbuffers',
        '@gast_archive': '@py_gast',
        '@gemmlowp': '@google_gemmlowp',
        '@gif_archive': '@sys',
        '@grpc': '@lib_grpc',
        '@highwayhash': '@google_highwayhash',
        '@io_bazel_rules_closure': '@bzl_rules_closure',
        '@jemalloc': '@lib_jemalloc',
        '@jpeg': '@lib_jpeg',
        '@jsoncpp_git': '@lib_json',
        '@keras_applications_archive': '@dnn_keras_applications',
        '@libxsmm_archive': '@lib_xsmm',
        '@linenoise': '@lib_linenoise',
        '@llvm': '@cc_llvm',
        '@lmdb': '@sys',
        '@local_config_cuda': '@lib_nvidia',
        '@local_config_nccl': '@lib_nvidia_nccl',
        '@local_config_python': '@python',
        '@local_config_rocm': '@nil',
        '@local_config_sycl': '@nil',
        '@local_config_syslibs': '@sys',
        '@local_config_tensorrt': '@lib_nvidia_tensorrt',
        '@nasm': '@sys',
        '@ngraph': '@dnn_ngraph',
        '@ngraph_tf': '@dnn_ngraph_tf',
        '@nlohmann_json_lib': '@lib_nlohmann_json',
        '@nsync': '@google_nsync',
        '@org_sqlite': '@sys',
        '@org_tensorflow': '@tensorflow',
        '@ortools_archive': '@google_or_tools',
        '@pcre': '@sys',
        '@png_archive': '@lib_png',
        '@protobuf_archive': '@google_protobuf',
        # '@six_archive': '@py_six',
        '@snappy': '@google_snappy',
        '@swig': '@sys',
        '@termcolor_archive': '@py_termcolor',
        '@zlib_archive': '@sys',
    },
    K.MAPS + ' "google/protobuf"': {
        '@bazel_skylib': '@bzl_skylib',
        '@com_google_protobuf': '@google_protobuf',
    },
    K.MAPS + ' "bazel"': {
        '@bazel_j2objc': '@google_j2objc',
        '@googleapis': '@google_googleapis',
        '@io_bazel': '@bazel',
        '@openjdk_linux': '@sys',
        '@skydoc': '@bzl_skydoc',
    },
    K.BINDS + ' "tensorflow"': {
        'cares': '@lib_grpc//third_party/nanopb:nanopb',
        'grpc_cpp_plugin': '@lib_grpc//:grpc_cpp_plugin',
        'grpc_lib': '@lib_grpc//:grpc++',
        'grpc_lib_unsecure': '@lib_grpc//:grpc++_unsecure',
        'grpc_python_plugin': '@lib_grpc//:grpc_python_plugin',
        'libssl': '@google_boringssl//:ssl',
        'nanopb': '@lib_grpc//third_party/nanopb:nanopb',
        'protobuf': '@google_protobuf//:protobuf',
        'protobuf_clib': '@google_protobuf//:protoc_lib',
        'protobuf_headers': '@google_protobuf//:protobuf_headers',
        'python_headers': '@python//:python_headers',
        'six': '@py_six//:six',
        'zlib': '@sys//:zlib',
    },
    K.BINDS + ' "google/protobuf"': {
        'gtest': '@submodule_gmock//:gtest',
        'gtest_main': '@submodule_gmock//:gtest_main',
        'python_headers': '@python//:python_headers',
        'six': '@py_six//:six',
    },
    K.BINDS + ' "bazel"': {
        'guava': '@com_google_guava',
        'gson': '@com_google_code_gson',
        'xcrunwrapper': '@bazel_tools//tools/objc:xcrunwrapper',
    },
}
