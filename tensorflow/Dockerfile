# python

ARG REG
ARG TAG


FROM $REG/pkg-dev:$TAG AS tmp_pkg
ENV VER=1.49.0 \
    DST=/usr/local/python
WORKDIR /tmp
COPY pkgs .
RUN ./qpx.sh -r ${VER} ${DST}

FROM $REG/old:$TAG AS py_pkg
ENV RUST_VERSION=1.49.0 \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH
COPY --from=tmp_pkg /usr/local /usr/local


FROM $REG/pkg-dev:$TAG AS tmp_src
ENV VER=1.49.0 \
    DST=/usr/local/python
WORKDIR /tmp
COPY srcs .
RUN ./qpx.sh -r old ${DST}

FROM $REG/old:$TAG AS py_src
ENV RUST_VERSION=1.49.0 \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH
COPY --from=tmp_src /usr/local /usr/local


ARG UBUNTU_VERSION=18.04
FROM ubuntu:${UBUNTU_VERSION} as base
RUN apt-get update && apt-get install -y curl
ENV LANG=C.UTF-8
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip
RUN python3 -m pip --no-cache-dir install --upgrade \
    "pip<20.3" \
    setuptools
RUN ln -s $(which python3) /usr/local/bin/python
# Options:
#   tensorflow
#   tensorflow-gpu
#   tf-nightly
#   tf-nightly-gpu
# Set --build-arg TF_PACKAGE_VERSION=1.11.0rc0 to install a specific version.
# Installs the latest version by default.
ARG TF_PACKAGE=tensorflow
ARG TF_PACKAGE_VERSION=
RUN python3 -m pip install --no-cache-dir ${TF_PACKAGE}${TF_PACKAGE_VERSION:+==${TF_PACKAGE_VERSION}}
COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc

ARG UBUNTU_VERSION=18.04
FROM ubuntu:${UBUNTU_VERSION} AS base
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        libcurl3-dev \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libzmq3-dev \
        pkg-config \
        rsync \
        software-properties-common \
        sudo \
        unzip \
        zip \
        zlib1g-dev \
        openjdk-8-jdk \
        openjdk-8-jre-headless \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV CI_BUILD_PYTHON python

# CACHE_STOP is used to rerun future commands, otherwise cloning tensorflow will be cached and will not pull the most recent version
ARG CACHE_STOP=1
# Check out TensorFlow source code if --build-arg CHECKOUT_TF_SRC=1
ARG CHECKOUT_TF_SRC=0
# In case of Python 2.7+ we need to add passwd entries for user and group id
RUN chmod a+w /etc/passwd /etc/group
RUN test "${CHECKOUT_TF_SRC}" -eq 1 && git clone https://github.com/tensorflow/tensorflow.git /tensorflow_src || true

# See http://bugs.python.org/issue19846
ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip

RUN python3 -m pip --no-cache-dir install --upgrade \
    "pip<20.3" \
    setuptools

# Some TF tools expect a "python" binary
RUN ln -s $(which python3) /usr/local/bin/python

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    wget \
    openjdk-8-jdk \
    python3-dev \
    virtualenv \
    swig

RUN python3 -m pip --no-cache-dir install \
    Pillow \
    h5py \
    keras_preprocessing \
    matplotlib \
    mock \
    'numpy<1.19.0' \
    scipy \
    sklearn \
    pandas \
    future \
    portpicker \
    enum34

# Install bazel
ARG BAZEL_VERSION=3.7.2
RUN mkdir /bazel && \
    wget -O /bazel/installer.sh "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh" && \
    wget -O /bazel/LICENSE.txt "https://raw.githubusercontent.com/bazelbuild/bazel/master/LICENSE" && \
    chmod +x /bazel/installer.sh && \
    /bazel/installer.sh && \
    rm -f /bazel/installer.sh

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc


ARG UBUNTU_VERSION=18.04

ARG ARCH=
ARG CUDA=11.0
FROM nvidia/cuda${ARCH:+-$ARCH}:${CUDA}-base-ubuntu${UBUNTU_VERSION} as base
# ARCH and CUDA are specified again because the FROM directive resets ARGs
# (but their default value is retained if set previously)
ARG ARCH
ARG CUDA
ARG CUDNN=8.0.4.30-1
ARG CUDNN_MAJOR_VERSION=8
ARG LIB_DIR_PREFIX=x86_64
ARG LIBNVINFER=7.1.3-1
ARG LIBNVINFER_MAJOR_VERSION=7

# Needed for string substitution
SHELL ["/bin/bash", "-c"]
# Pick up some TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cuda-command-line-tools-${CUDA/./-} \
        libcublas-${CUDA/./-} \
        cuda-nvrtc-${CUDA/./-} \
        libcufft-${CUDA/./-} \
        libcurand-${CUDA/./-} \
        libcusolver-${CUDA/./-} \
        libcusparse-${CUDA/./-} \
        curl \
        libcudnn8=${CUDNN}+cuda${CUDA} \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libzmq3-dev \
        pkg-config \
        software-properties-common \
        unzip

# Install TensorRT if not building for PowerPC
RUN [[ "${ARCH}" = "ppc64le" ]] || { apt-get update && \
        apt-get install -y --no-install-recommends libnvinfer${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER}+cuda${CUDA} \
        libnvinfer-plugin${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER}+cuda${CUDA} \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*; }

# For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Link the libcuda stub to the location where tensorflow is searching for it and reconfigure
# dynamic linker run-time bindings
RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1 \
    && echo "/usr/local/cuda/lib64/stubs" > /etc/ld.so.conf.d/z-cuda-stubs.conf \
    && ldconfig

# See http://bugs.python.org/issue19846
ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip

RUN python3 -m pip --no-cache-dir install --upgrade \
    "pip<20.3" \
    setuptools

# Some TF tools expect a "python" binary
RUN ln -s $(which python3) /usr/local/bin/python

# Options:
#   tensorflow
#   tensorflow-gpu
#   tf-nightly
#   tf-nightly-gpu
# Set --build-arg TF_PACKAGE_VERSION=1.11.0rc0 to install a specific version.
# Installs the latest version by default.
ARG TF_PACKAGE=tensorflow
ARG TF_PACKAGE_VERSION=
RUN python3 -m pip install --no-cache-dir ${TF_PACKAGE}${TF_PACKAGE_VERSION:+==${TF_PACKAGE_VERSION}}

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc


ARG UBUNTU_VERSION=18.04

ARG ARCH=
ARG CUDA=11.0
FROM nvidia/cuda${ARCH:+-$ARCH}:${CUDA}-base-ubuntu${UBUNTU_VERSION} as base
# ARCH and CUDA are specified again because the FROM directive resets ARGs
# (but their default value is retained if set previously)
ARG ARCH
ARG CUDA
ARG CUDNN=8.0.4.30-1
ARG CUDNN_MAJOR_VERSION=8
ARG LIB_DIR_PREFIX=x86_64
ARG LIBNVINFER=7.1.3-1
ARG LIBNVINFER_MAJOR_VERSION=7

# Needed for string substitution
SHELL ["/bin/bash", "-c"]
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cuda-command-line-tools-${CUDA/./-} \
        libcublas-${CUDA/./-} \
        libcublas-dev-${CUDA/./-} \
        cuda-nvrtc-${CUDA/./-} \
        cuda-nvrtc-dev-${CUDA/./-} \
        cuda-cudart-dev-${CUDA/./-} \
        libcufft-dev-${CUDA/./-} \
        libcurand-dev-${CUDA/./-} \
        libcusolver-dev-${CUDA/./-} \
        libcusparse-dev-${CUDA/./-} \
        libcudnn8=${CUDNN}+cuda${CUDA} \
        libcudnn8-dev=${CUDNN}+cuda${CUDA} \
        libcurl3-dev \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libzmq3-dev \
        pkg-config \
        rsync \
        software-properties-common \
        unzip \
        zip \
        zlib1g-dev \
        wget \
        git \
        && \
    find /usr/local/cuda-${CUDA}/lib64/ -type f -name 'lib*_static.a' -not -name 'libcudart_static.a' -delete && \
    rm /usr/lib/${LIB_DIR_PREFIX}-linux-gnu/libcudnn_static_v8.a

# Install TensorRT if not building for PowerPC
RUN [[ "${ARCH}" = "ppc64le" ]] || { apt-get update && \
        apt-get install -y --no-install-recommends libnvinfer${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER}+cuda${CUDA} \
        libnvinfer-dev=${LIBNVINFER}+cuda${CUDA} \
        libnvinfer-plugin-dev=${LIBNVINFER}+cuda${CUDA} \
        libnvinfer-plugin${LIBNVINFER_MAJOR_VERSION}=${LIBNVINFER}+cuda${CUDA} \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*; }

# Configure the build for our CUDA configuration.
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/lib64:/usr/include/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH:/usr/local/cuda/lib64/stubs
ENV TF_NEED_CUDA 1
ENV TF_NEED_TENSORRT 1
ENV TF_CUDA_VERSION=${CUDA}
ENV TF_CUDNN_VERSION=${CUDNN_MAJOR_VERSION}
# CACHE_STOP is used to rerun future commands, otherwise cloning tensorflow will be cached and will not pull the most recent version
ARG CACHE_STOP=1
# Check out TensorFlow source code if --build-arg CHECKOUT_TF_SRC=1
ARG CHECKOUT_TF_SRC=0
RUN test "${CHECKOUT_TF_SRC}" -eq 1 && git clone https://github.com/tensorflow/tensorflow.git /tensorflow_src || true

# Link the libcuda stub to the location where tensorflow is searching for it and reconfigure
# dynamic linker run-time bindings
RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1 \
    && echo "/usr/local/cuda/lib64/stubs" > /etc/ld.so.conf.d/z-cuda-stubs.conf \
    && ldconfig

# See http://bugs.python.org/issue19846
ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip

RUN python3 -m pip --no-cache-dir install --upgrade \
    "pip<20.3" \
    setuptools

# Some TF tools expect a "python" binary
RUN ln -s $(which python3) /usr/local/bin/python

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    wget \
    openjdk-8-jdk \
    python3-dev \
    virtualenv \
    swig

RUN python3 -m pip --no-cache-dir install \
    Pillow \
    h5py \
    keras_preprocessing \
    matplotlib \
    mock \
    'numpy<1.19.0' \
    scipy \
    sklearn \
    pandas \
    future \
    portpicker \
    enum34

# Install bazel
ARG BAZEL_VERSION=3.7.2
RUN mkdir /bazel && \
    wget -O /bazel/installer.sh "https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh" && \
    wget -O /bazel/LICENSE.txt "https://raw.githubusercontent.com/bazelbuild/bazel/master/LICENSE" && \
    chmod +x /bazel/installer.sh && \
    /bazel/installer.sh && \
    rm -f /bazel/installer.sh

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc