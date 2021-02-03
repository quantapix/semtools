# -*- Python -*-

package(default_visibility=["//visibility:public"])

licenses(["notice"])

load("//tensorflow:tensorflow.bzl", "transitive_hdrs")
load("//third_party/mkl:build_defs.bzl", "if_mkl", "if_mkl_ml")
load("//tensorflow:tensorflow.bzl", "if_cuda")
load("@local_config_syslibs//:build_defs.bzl", "if_not_system_lib")
load("//third_party/ngraph:build_defs.bzl", "if_ngraph")

transitive_hdrs(
    name="included_headers",
    deps=[
        "//tensorflow/core:core_cpu",
        "//tensorflow/core:framework",
        "//tensorflow/core:lib",
        "//tensorflow/core:protos_all_cc",
        "//tensorflow/core:stream_executor",
        "//third_party/eigen3",
        "@local_config_cuda//cuda:cuda_headers",
    ],
)

COMMON_PIP_DEPS = [
    ":licenses",
    "MANIFEST.in",
    "README",
    "setup.py",
    ":included_headers",
    "//tensorflow:tensorflow_py",
    # "//tensorflow/contrib/autograph:autograph",
    "//tensorflow/contrib/boosted_trees:boosted_trees_pip",
    # "//tensorflow/contrib/cluster_resolver:cluster_resolver_pip",
    "//tensorflow/contrib/constrained_optimization:constrained_optimization_pip",
    # "//tensorflow/contrib/data/python/kernel_tests/serialization:dataset_serialization_test_base",
    # "//tensorflow/contrib/data/python/kernel_tests:stats_dataset_test_base",
    # "//tensorflow/contrib/data/python/kernel_tests:test_utils",
    # "//tensorflow/contrib/data/python/ops:contrib_op_loader",
    "//tensorflow/contrib/eager/python/examples:examples_pip",
    "//tensorflow/contrib/eager/python:evaluator",
    "//tensorflow/contrib/gan:gan",
    "//tensorflow/contrib/graph_editor:graph_editor_pip",
    # "//tensorflow/contrib/keras:keras",
    "//tensorflow/contrib/labeled_tensor:labeled_tensor_pip",
    "//tensorflow/contrib/nn:nn_py",
    "//tensorflow/contrib/predictor:predictor_pip",
    "//tensorflow/contrib/proto:proto",
    "//tensorflow/contrib/receptive_field:receptive_field_pip",
    "//tensorflow/contrib/rate:rate",
    "//tensorflow/contrib/rpc:rpc_pip",
    "//tensorflow/contrib/session_bundle:session_bundle_pip",
    "//tensorflow/contrib/signal:signal_py",
    "//tensorflow/contrib/signal:test_util",
    "//tensorflow/contrib/slim:slim",
    "//tensorflow/contrib/slim/python/slim/data:data_pip",
    "//tensorflow/contrib/slim/python/slim/nets:nets_pip",
    "//tensorflow/contrib/specs:specs",
    "//tensorflow/contrib/summary:summary_test_util",
    "//tensorflow/contrib/tensor_forest:init_py",
    "//tensorflow/contrib/tensor_forest/hybrid:hybrid_pip",
    "//tensorflow/contrib/timeseries:timeseries_pip",
    # "//tensorflow/contrib/tpu",
    "//tensorflow/examples/tutorials/mnist:package",
    # "//tensorflow/python/autograph/converters:converters",
    # "//tensorflow/python/autograph/core:core",
    # "//tensorflow/python/autograph/core:test_lib",
    # "//tensorflow/python/autograph/impl:impl",
    # "//tensorflow/python/autograph/lang:lang",
    # "//tensorflow/python/autograph/operators:operators",
    # "//tensorflow/python/autograph/pyct:pyct",
    # "//tensorflow/python/autograph/pyct/testing:testing",
    # "//tensorflow/python/autograph/pyct/static_analysis:static_analysis",
    # "//tensorflow/python/autograph/pyct/common_transformers:common_transformers",
    "//tensorflow/python:cond_v2",
    "//tensorflow/python:distributed_framework_test_lib",
    "//tensorflow/python:meta_graph_testdata",
    "//tensorflow/python:spectral_ops_test_util",
    "//tensorflow/python:util_example_parser_configuration",
    "//tensorflow/python/debug:debug_pip",
    "//tensorflow/python/eager:eager_pip",
    "//tensorflow/python/kernel_tests/testdata:self_adjoint_eig_op_test_files",
    "//tensorflow/python/saved_model:saved_model",
    "//tensorflow/python/tools:tools_pip",
    "//tensorflow/python/tools/api/generator:create_python_api",
    "//tensorflow/python:test_ops",
    "//tensorflow/python:while_v2",
    "//tensorflow/tools/dist_test/server:grpc_tensorflow_server",
]

filegroup(
    name="licenses",
    data=[],
)

py_binary(
    name="simple_console",
    srcs=["simple_console.py"],
    deps=["//tensorflow:tensorflow_py"],
)

sh_binary(
    name="build_pip_package",
    srcs=["build_pip_package.sh"],
    data=COMMON_PIP_DEPS +
    [":simple_console", "//third_party/mkl:intel_binary_blob"],
)
