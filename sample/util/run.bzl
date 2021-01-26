load("@io_bazel_rules_docker//docker/util:run.bzl",
    _commit = "commit",
    _container_run_and_commit = "container_run_and_commit",
    _container_run_and_extract = "container_run_and_extract",
    _extract = "extract",
)

commit = _commit
container_run_and_extract = _container_run_and_extract
container_run_and_commit = _container_run_and_commit
extract = _extract
