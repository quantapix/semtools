
load(
    "@tensorflow//third_party:repo.bzl",
    "tf_http_archive",
    "third_party_http_archive",
)
load(
    "@bzl_rules_closure//closure/private:java_import_external.bzl",
    "java_import_external",
)


def clean_dep(dep):
    return str(Label(dep))


def create_tensorflow_repos():

    third_party_http_archive(
        name="icu",
        strip_prefix="icu-release-62-1",
        sha256=
        "e15ffd84606323cbad5515bf9ecdf8061cc3bf80fb883b9e6aa162e485aa9761",
        urls=[
            "https://mirror.bazel.build/github.com/unicode-org/icu/archive/release-62-1.tar.gz",
            "https://github.com/unicode-org/icu/archive/release-62-1.tar.gz",
        ],
        build_file="@tensorflow//third_party/icu:BUILD.bazel",
        system_build_file="@tensorflow//third_party/icu:BUILD.system",
        patch_file=clean_dep("@tensorflow//third_party/icu:udata.patch"),
    )

    tf_http_archive(
        name="com_github_googlecloudplatform_google_cloud_cpp",
        urls=[
            "https://mirror.bazel.build/github.com/GoogleCloudPlatform/google-cloud-cpp/archive/14760a86c4ffab9943b476305c4fe927ad95db1c.tar.gz",
            "https://github.com/GoogleCloudPlatform/google-cloud-cpp/archive/14760a86c4ffab9943b476305c4fe927ad95db1c.tar.gz",
        ],
        sha256=
        "fdd3b3aecce60987e5525e55bf3a21d68a8695320bd5b980775af6507eec3944",
        strip_prefix=
        "google-cloud-cpp-14760a86c4ffab9943b476305c4fe927ad95db1c",
    )

    tf_http_archive(
        name="org_python_pypi_backports_weakref",
        urls=[
            "https://mirror.bazel.build/pypi.python.org/packages/bc/cc/3cdb0a02e7e96f6c70bd971bc8a90b8463fda83e264fa9c5c1c98ceabd81/backports.weakref-1.0rc1.tar.gz",
            "https://pypi.python.org/packages/bc/cc/3cdb0a02e7e96f6c70bd971bc8a90b8463fda83e264fa9c5c1c98ceabd81/backports.weakref-1.0rc1.tar.gz",
        ],
        sha256=
        "8813bf712a66b3d8b85dc289e1104ed220f1878cf981e2fe756dfaabe9a82892",
        strip_prefix="backports.weakref-1.0rc1/src",
        build_file="@tensorflow//third_party:backports_weakref.BUILD",
    )

    tf_http_archive(
        name="fft2d",
        urls=[
            "https://mirror.bazel.build/www.kurims.kyoto-u.ac.jp/~ooura/fft.tgz",
            "http://www.kurims.kyoto-u.ac.jp/~ooura/fft.tgz",
        ],
        sha256=
        "52bb637c70b971958ec79c9c8752b1df5ff0218a4db4510e60826e0cb79b5296",
        build_file="@tensorflow//third_party/fft2d:fft2d.BUILD",
    )

    tf_http_archive(
        name="cub_archive",
        urls=[
            "https://mirror.bazel.build/github.com/NVlabs/cub/archive/1.8.0.zip",
            "https://github.com/NVlabs/cub/archive/1.8.0.zip",
        ],
        sha256=
        "6bfa06ab52a650ae7ee6963143a0bbc667d6504822cbd9670369b598f18c58c3",
        strip_prefix="cub-1.8.0",
        build_file="@tensorflow//third_party:cub.BUILD",
    )

    tf_http_archive(
        name="arm_neon_2_x86_sse",
        sha256=
        "c8d90aa4357f8079d427e87a6f4c493da1fa4140aee926c05902d7ec1533d9a5",
        strip_prefix=
        "ARM_NEON_2_x86_SSE-0f77d9d182265259b135dad949230ecbf1a2633d",
        urls=[
            "https://mirror.bazel.build/github.com/intel/ARM_NEON_2_x86_SSE/archive/0f77d9d182265259b135dad949230ecbf1a2633d.tar.gz",
            "https://github.com/intel/ARM_NEON_2_x86_SSE/archive/0f77d9d182265259b135dad949230ecbf1a2633d.tar.gz",
        ],
        build_file="@tensorflow//third_party:arm_neon_2_x86_sse.BUILD",
    )

    java_import_external(
        name="junit",
        jar_sha256=
        "59721f0805e223d84b90677887d9ff567dc534d7c502ca903c0c2b17f05c116a",
        jar_urls=[
            "https://mirror.bazel.build/repo1.maven.org/maven2/junit/junit/4.12/junit-4.12.jar",
            "http://repo1.maven.org/maven2/junit/junit/4.12/junit-4.12.jar",
            "http://maven.ibiblio.org/maven2/junit/junit/4.12/junit-4.12.jar",
        ],
        licenses=["reciprocal"],  # Common Public License Version 1.0
        testonly_=True,
        deps=["@org_hamcrest_core"],
    )

    java_import_external(
        name="org_hamcrest_core",
        jar_sha256=
        "66fdef91e9739348df7a096aa384a5685f4e875584cce89386a7a47251c4d8e9",
        jar_urls=[
            "https://mirror.bazel.build/repo1.maven.org/maven2/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar",
            "http://repo1.maven.org/maven2/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar",
            "http://maven.ibiblio.org/maven2/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar",
        ],
        licenses=["notice"],  # New BSD License
        testonly_=True,
    )

    java_import_external(
        name="com_google_testing_compile",
        jar_sha256=
        "edc180fdcd9f740240da1a7a45673f46f59c5578d8cd3fbc912161f74b5aebb8",
        jar_urls=[
            "http://mirror.bazel.build/repo1.maven.org/maven2/com/google/testing/compile/compile-testing/0.11/compile-testing-0.11.jar",
            "http://repo1.maven.org/maven2/com/google/testing/compile/compile-testing/0.11/compile-testing-0.11.jar",
        ],
        licenses=["notice"],  # New BSD License
        testonly_=True,
        deps=["@com_google_guava", "@com_google_truth"],
    )

    java_import_external(
        name="com_google_truth",
        jar_sha256=
        "032eddc69652b0a1f8d458f999b4a9534965c646b8b5de0eba48ee69407051df",
        jar_urls=[
            "http://mirror.bazel.build/repo1.maven.org/maven2/com/google/truth/truth/0.32/truth-0.32.jar",
            "http://repo1.maven.org/maven2/com/google/truth/truth/0.32/truth-0.32.jar",
        ],
        licenses=["notice"],  # Apache 2.0
        testonly_=True,
        deps=["@com_google_guava"],
    )

    java_import_external(
        name="org_checkerframework_qual",
        jar_sha256=
        "a17501717ef7c8dda4dba73ded50c0d7cde440fd721acfeacbf19786ceac1ed6",
        jar_urls=[
            "http://mirror.bazel.build/repo1.maven.org/maven2/org/checkerframework/checker-qual/2.4.0/checker-qual-2.4.0.jar",
            "http://repo1.maven.org/maven2/org/checkerframework/checker-qual/2.4.0/checker-qual-2.4.0.jar",
        ],
        licenses=["notice"],  # Apache 2.0
    )

    java_import_external(
        name="com_squareup_javapoet",
        jar_sha256=
        "5bb5abdfe4366c15c0da3332c57d484e238bd48260d6f9d6acf2b08fdde1efea",
        jar_urls=[
            "http://mirror.bazel.build/repo1.maven.org/maven2/com/squareup/javapoet/1.9.0/javapoet-1.9.0.jar",
            "http://repo1.maven.org/maven2/com/squareup/javapoet/1.9.0/javapoet-1.9.0.jar",
        ],
        licenses=["notice"],  # Apache 2.0
    )
