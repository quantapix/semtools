load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_test")

sh_library(
    name = "ninja_lib",
    srcs = ["//ubuntu/libs:ninja_tool"],
)

sh_test(
    name = "ninja",
    srcs = ["ninja.sh"],
    args = ["true"],
    deps = [":ninja_lib"],
)

cc_binary(
    name = "zlib_sample",
    srcs = ["zlib.cpp"],
    deps = ["//ubuntu/libs:libz"],
)

sh_test(
    name = "zlib",
    srcs = ["zlib.sh"],
    data = [":zlib_sample"],
)

cc_test(
    name = "nghttp2",
    srcs = ["nghttp2.cpp"],
    deps = ["//ubuntu/libs:nghttp2"],
)

cc_test(
    name = "test_libunwind",
    srcs = ["libunwind_test.c"],
    deps = [":libunwind"],
)

test_suite(
    name = "configure_libunwind_tests",
    tests = [":test_libunwind"],
)

"""
cmake_external(
    name = "libpng",
    cache_entries = {
        "ZLIB_ROOT": "$EXT_BUILD_DEPS/libz",
    },
    lib_source = "@libpng//:files",
    out_include_dir = "include/libpng16",
    static_libraries = ["libpng16.a"],
    deps = [":libz"],
)

cc_binary(
    name = "libpng_usage_example",
    srcs = ["libpng_usage_example.cpp"],
    deps = [
        ":libpng",
        ":libz",
    ],
)

sh_test(
    name = "test_libpng",
    srcs = ["test_libpng.sh"],
    args = ["$(location bazel-icon-transparent.png) out.png"],
    data = [
        "bazel-icon-transparent.png",
        ":libpng_usage_example",
    ],
    visibility = ["//:__pkg__"],
)

cmake_external(
    name = "freetype",
    cache_entries = {
        "PNG_LIBRARY": "$EXT_BUILD_DEPS/libpng/lib/libpng16.a",
        "PNG_PNG_INCLUDE_DIR": "$EXT_BUILD_DEPS/libpng/include",
        "ZLIB_ROOT": "$EXT_BUILD_DEPS/libz",
    },
    lib_source = "@freetype//:files",
    out_include_dir = "include/freetype2",
    static_libraries = ["libfreetype.a"],
    deps = [
        ":libpng",
        ":libz",
    ],
)

cmake_external(
    name = "libgd",
    cache_entries = {
        "BUILD_SHARED_LIBS": "OFF",
        "BUILD_STATIC_LIBS": "ON",
        "ENABLE_FREETYPE": "1",
        "ENABLE_PNG": "1",
        "FREETYPE_INCLUDE_DIRS": "$EXT_BUILD_DEPS/freetype/include/freetype2",
        "FREETYPE_LIBRARY": "$EXT_BUILD_DEPS/freetype/lib/libfreetype.a",
        "PNG_LIBRARY": "$EXT_BUILD_DEPS/libpng/lib/libpng16.a",
        "PNG_PNG_INCLUDE_DIR": "$EXT_BUILD_DEPS/libpng/include",
        "ZLIB_ROOT": "$EXT_BUILD_DEPS/libz",
    },
    defines = ["HAVE_LIBPNG"],
    lib_source = "@libgd//:files",
    deps = [
        ":freetype",
        ":libpng",
        ":libz",
    ],
)

cc_binary(
    name = "libgd_with_png_example",
    srcs = ["arc.c"],
    deps = [
        ":libgd",
    ],
)

sh_test(
    name = "test_libgd",
    srcs = ["test_libgd.sh"],
    data = [
        ":libgd_with_png_example",
    ],
    visibility = ["//:__pkg__"],
)
"""