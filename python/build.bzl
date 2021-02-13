"""Python tgts"""

load("@rules_cc//cc:defs.bzl", "cc_test")
load("@rules_foreign_cc//tools/build_defs:configure.bzl", "configure_make")


# buildifier: disable=unnamed-macro
def python_tgts():

    configure_make(
        name = "libunwind",
        configure_in_place = True,
        configure_options = [
            "--build=\"x86_64-linux-gnu\"",
            "--enable-loadable-sqlite-extensions",
            "--enable-optimizations",
            "--enable-option-checking=fatal",
            "--enable-shared",
            "--with-system-expat",
            "--with-system-ffi",
            "--without-ensurepip",
        ],
        lib_source = "@python3//:files",
        shared_libraries = ["libunwind.so"],
        static_libraries = ["libunwind.a"],
        visibility = ["//visibility:public"],
    )

exports_files(["qpx_bin"])
filegroup(
    name = "files",
    srcs = glob(["qpx_out/**"], exclude = ["**/* *"]),
    visibility = ["//visibility:public"],
)

            "mkdir $(pwd)/qpx_out",
            "./configure --prefix=$(pwd)/qpx_out",
            "make",
            "make install",
            "ln -s qpx_out/bin/python3 qpx_bin",


cc_test(
    name = "test_libunwind",
    srcs = ["libunwind_test.c"],
    deps = [":libunwind"],
)

test_suite(
    name = "configure_libunwind_tests",
    tests = [":test_libunwind"],
)


FROM buildpack-deps:buster
ENV PATH /usr/local/bin:$PATH
ENV LANG C.UTF-8
# extra dependencies (over what buildpack-deps already includes)
ENV GPG_KEY E3FF2839C048B25C084DEBE9B26995E310250568
ENV PYTHON_VERSION 3.9.1
RUN set -ex \
	&& cd /usr/src/python \
	&& make -j "$(nproc)" \
	&& make install \
	&& rm -rf /usr/src/python \
	\
	&& find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
		\) -exec rm -rf '{}' + \
	\
	&& ldconfig \
	\
	&& python3 --version

# make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
	&& ln -s idle3 idle \
	&& ln -s pydoc3 pydoc \
	&& ln -s python3 python \
	&& ln -s python3-config python-config

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 21.0.1
# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/4be3fe44ad9dedc028629ed1497052d65d281b8e/get-pip.py
ENV PYTHON_GET_PIP_SHA256 8006625804f55e1bd99ad4214fd07082fee27a1c35945648a58f9087a714e9d4

RUN set -ex; \
	\
	wget -O get-pip.py "$PYTHON_GET_PIP_URL"; \
	echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum --check --strict -; \
	\
	python get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==$PYTHON_PIP_VERSION" \
	; \
	pip --version; \
	\
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +; \
	rm -f get-pip.py

CMD ["python3"]