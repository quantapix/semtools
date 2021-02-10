#!/bin/bash

set -x -e -u -o pipefail

build() {
    if [ "$1" ]; then
        rm -rf std.build std.install
        (cd upstream || exit
         git reset --hard
         git clean -xfd)
    fi
    if [ ! -e std.build ]; then
        mkdir std.build std.install
    fi
    (cd std.build || exit
     if [ ! -e .qpx.flag ]; then
         (cd ../upstream || exit
          PYTHON_BIN_PATH="$(which python)"
          export PYTHON_BIN_PATH
          export USE_DEFAULT_PYTHON_LIB_PATH=1
          # export HOST_C_COMPILER=/usr/bin/gcc-7
          # export HOST_CXX_COMPILER=/usr/bin/g++-7
          # export CC_OPT_FLAGS="-pipe -fstack-protector-strong -fno-plt"
          export LD_LIBRARY_PATH=/home/qpix/clone/pesto/lib/nvidia/upstream/cuda_cudnn/lib64:/home/qpix/clone/pesto/lib/nvidia/upstream/nccl/lib:/home/qpix/clone/pesto/lib/nvidia/upstream/tensorrt/lib
          export TF_NEED_JEMALLOC=1
          export TF_NEED_AWS=0
          export TF_NEED_GCP=0
          export TF_NEED_HDFS=0
          export TF_NEED_S3=0
          export TF_NEED_KAFKA=0
          export TF_ENABLE_XLA=1
          export TF_NEED_NGRAPH=1
          export TF_NEED_OPENCL_SYCL=0
          export TF_NEED_OPENCL=0
          export TF_NEED_MPI=0
          export TF_DOWNLOAD_CLANG=0 
          export TF_SET_ANDROID_WORKSPACE=0
          if [ "$2" ]; then
              # export GCC_HOST_COMPILER_PATH=/usr/bin/gcc-7
              # export CLANG_CUDA_COMPILER_PATH=/usr/bin/clang
              # export CC_OPT_FLAGS="-march=native $CC_OPT_FLAGS"
              export TF_NEED_GDR=1
              export TF_NEED_VERBS=1
              export TF_NEED_CUDA=1
              # export TF_CUDA_CLANG=0
              export CUDA_TOOLKIT_PATH=/home/qpix/clone/pesto/lib/nvidia/upstream/cuda_cudnn
              export TF_CUDA_VERSION=$($CUDA_TOOLKIT_PATH/bin/nvcc --version | sed -n 's/^.*release \(.*\),.*/\1/p')
              export CUDNN_INSTALL_PATH=/home/qpix/clone/pesto/lib/nvidia/upstream/cuda_cudnn
              export TF_CUDNN_VERSION=$(sed -n 's/^#define CUDNN_MAJOR\s*\(.*\).*/\1/p' $CUDNN_INSTALL_PATH/include/cudnn.h)
              export NCCL_INSTALL_PATH=/home/qpix/clone/pesto/lib/nvidia/upstream/nccl
              export TF_NCCL_VERSION=$(sed -n 's/^#define NCCL_MAJOR\s*\(.*\).*/\1/p' $NCCL_INSTALL_PATH/include/nccl.h)
              export TF_NEED_TENSORRT=1
              export TENSORRT_INSTALL_PATH=/home/qpix/clone/pesto/lib/nvidia/upstream/tensorrt
              export TF_TENSORRT_VERSION=$(sed -n 's/^#define NV_TENSORRT_MAJOR\s*\(.*\).*/\1/p' $TENSORRT_INSTALL_PATH/include/NvInfer.h)
              export TF_CUDA_COMPUTE_CAPABILITIES=6.1,7.0
          else
              # export CC_OPT_FLAGS="-march=native $CC_OPT_FLAGS"
              export TF_NEED_GDR=0
              export TF_NEED_VERBS=0
              export TF_NEED_CUDA=0
          fi
          ./configure)
     else
         echo "***** SKIPPING CONFIG... *****"
     fi
     (cd ../upstream || exit
      if [ "$2" ]; then
          bazel build //tensorflow/tools/pip_package:build_pip_package
      else
          bazel build --config=mkl --copt="-DEIGEN_USE_VML" //tensorflow/tools/pip_package:build_pip_package
      fi
      bazel-bin/tensorflow/tools/pip_package/build_pip_package ../std.install)
     )
    (cd std.install || exit
     pip install -I tensorflow-*.whl)
}

show_usage() {
    echo "Usage: $(basename "$0") [-c] [-g]"
}

main() {
    local OPTIND=1
    local CFG=
    local GPU=

    while getopts "cgh" opt; do
	      case $opt in
	          c) CFG=true;;
	          g) GPU=true;;
	          *) show_usage; return 1;;
	      esac
    done
    shift $((OPTIND-1))

	  build "$CFG" "$GPU"
}

main "$@"
