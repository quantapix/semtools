bazel version
docker pull gcr.io/asci-toolchain/container_release_tools/dependency_update/validators/semantics:latest
cp -a ubuntu1804 /repro_test/ubuntu1804
bazel --output_base=/workspace/output_base run //:image dir: "ubuntu1804"
bazel --output_base=/workspace/output_base --test_output=errors test //:image-test //:configs_test dir: "ubuntu1804"
bazel --output_base=/repro_test/output_base test //:img_repro_test --test_output=errors dir: "/repro_test/ubuntu1804"

docker -t bazel:image gcr.io/${_IMG_BACKUP_DEST}
docker push 

tests:
	path: '/' shouldExist: true
	more /etc/os-release = '.*ubuntu.*'
	dpkg -l curl != '.*no packages found matching.*'
	dpkg -l ca-certificates != '.*no packages found matching.*'
	dpkg -l netbase != '.*no packages found matching.*'
	echo $DEBIAN_FRONTEND = 'noninteractive' 
	echo $PATH = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

PWD := $(shell pwd)

CONTAINER_TEST_TARGETS = :image-test :configs_test
BAZEL_TEST_OPTS = --test_output=errors --strategy=TestRunner=standalone

.PHONY: test
test:
	./check-fmt.sh
	bazel version
	bazel build //... --action_env=GIT_ROOT=$(PWD) --sandbox_writable_path=$(PWD) --verbose_failures --incompatible_bzl_disallow_load_after_statement=false
	bazel test --test_output=errors //... --action_env=GIT_ROOT=$(PWD) --sandbox_writable_path=$(PWD) --verbose_failures --incompatible_bzl_disallow_load_after_statement=false
	cd ubuntu1604 && bazel test $(BAZEL_TEST_OPTS) $(CONTAINER_TEST_TARGETS) && cd ..
	cd ubuntu1804 && bazel test $(BAZEL_TEST_OPTS) $(CONTAINER_TEST_TARGETS) && cd ..
	cd debian9 && bazel test $(BAZEL_TEST_OPTS) $(CONTAINER_TEST_TARGETS) && cd ..
	cd debian10 && bazel test $(BAZEL_TEST_OPTS) $(CONTAINER_TEST_TARGETS) && cd ..
	cd centos7 && bazel test $(BAZEL_TEST_OPTS) $(CONTAINER_TEST_TARGETS) && cd ..

complex-test:
	tests/package_managers/test_bootstrap_image_macro.sh


steps:
  - name: 'ubuntu'
    args: ['chmod', 'a+rx', '-R', '/workspace']
    # Run the bazel image with docker run to ensure workspace gets mounted in correctly.
  - name: 'gcr.io/cloud-builders/docker:latest'
    args: ['run', '-w', '/workspace',
           '-v', '/workspace:/workspace',
           '-v', '/var/run:/var/run',
           'gcr.io/cloud-builders/bazel:latest',
           'run', '//ubuntu:bootstrap_${_IMAGE}',
           '--incompatible_disable_deprecated_attr_params=false',
           '--incompatible_new_actions_api=false',
           '--incompatible_no_support_tools_in_action_inputs=false',
           '--host_force_python=PY2',
           '--action_env=GIT_ROOT=/workspace',
           '--sandbox_writable_path=/workspace']
  - name: gcr.io/cloud-builders/docker:latest
    args: ['tag', 'bazel/ubuntu:bootstrap_${_IMAGE}',
           'gcr.io/gcp-runtimes/${_IMAGE}:${COMMIT_SHA}']
images: ['gcr.io/gcp-runtimes/${_IMAGE}']

steps:
  # It's unclear why we need this, but bazel appears to need it sometimes.
  - name: 'l.gcr.io/google/debian9:latest'
    args: ['chmod', 'a+rx', '-R', '/workspace']

  # We have to build and load the builder image first, so it can be used in the next step.
  # Using "run" instead of "build" loads the built image into the daemon.
  - name: gcr.io/cloud-builders/bazel
    args: ['run', '--incompatible_disable_deprecated_attr_params=false', '--incompatible_string_join_requires_strings=false', '--incompatible_new_actions_api=false', '--incompatible_no_support_tools_in_action_inputs=false', '//debian/reproducible:debian${_VERSION_NUMBER}']



PWD := $(shell pwd)

CONTAINER_TEST_TARGETS = :image-test :configs_test
BAZEL_TEST_OPTS = --test_output=errors --strategy=TestRunner=standalone

.PHONY: test
test:
	./check-fmt.sh
	bazel version
	bazel build //... --action_env=GIT_ROOT=$(PWD) --sandbox_writable_path=$(PWD) --verbose_failures --incompatible_bzl_disallow_load_after_statement=false
	bazel test --test_output=errors //... --action_env=GIT_ROOT=$(PWD) --sandbox_writable_path=$(PWD) --verbose_failures --incompatible_bzl_disallow_load_after_statement=false
	cd ubuntu1604 && bazel test $(BAZEL_TEST_OPTS) $(CONTAINER_TEST_TARGETS) && cd ..
	cd ubuntu1804 && bazel test $(BAZEL_TEST_OPTS) $(CONTAINER_TEST_TARGETS) && cd ..
	cd debian9 && bazel test $(BAZEL_TEST_OPTS) $(CONTAINER_TEST_TARGETS) && cd ..
	cd debian10 && bazel test $(BAZEL_TEST_OPTS) $(CONTAINER_TEST_TARGETS) && cd ..
	cd centos7 && bazel test $(BAZEL_TEST_OPTS) $(CONTAINER_TEST_TARGETS) && cd ..

complex-test:
	tests/package_managers/test_bootstrap_image_macro.sh


  - name: "gcr.io/asci-toolchain/nosla-ubuntu16_04-bazel-docker-gcloud"
    entrypoint: "bash"
    args:
    - "-c"
    - "/workspace/buildifier --mode=check  $(find . -name BUILD -o -name WORKSPACE -o -name '*.bzl' -type f)"
    waitFor: ["buildifier-enable"]

  # Run buildifier --lint=warn.
  - name: "gcr.io/asci-toolchain/nosla-ubuntu16_04-bazel-docker-gcloud"
    entrypoint: "bash"
    args:
    - "-c"
    - "/workspace/buildifier --lint=warn $(find . -name BUILD -o -name WORKSPACE -o -name '*.bzl' -type f)"
    waitFor: ["buildifier-enable"]

  - name: "gcr.io/asci-toolchain/nosla-ubuntu16_04-bazel-docker-gcloud"
    entrypoint: "bazel"
    args:
    - "--output_base=/workspace"
    - "test"
    - "--remote_instance_name=projects/asci-toolchain/instances/default_instance"
    - "--crosstool_top=@rbe_toolchain_config//cc:toolchain"
    - "--host_javabase=@rbe_toolchain_config//java:jdk"
    - "--javabase=@rbe_toolchain_config//java:jdk"
    - "--extra_toolchains=@rbe_toolchain_config//config:cc-toolchain"
    - "--extra_execution_platforms=//:platform_docker"
    - "--host_platform=//:platform_docker"
    - "--platforms=//:platform_docker"
    - "--action_env=BAZEL_DO_NOT_DETECT_CPP_TOOLCHAIN=1"
    - "--host_java_toolchain=@bazel_tools//tools/jdk:toolchain_hostjdk8"
    - "--java_toolchain=@bazel_tools//tools/jdk:toolchain_hostjdk8"
    - "--spawn_strategy=remote"
    - "--strategy=Javac=remote"
    - "--strategy=Closure=remote"
    # This ensures the "security_check" rule in
    # @io_bazel_rules_docker//docker/security:security_check.bzl is executed
    # locally. It runs gcloud under the hood which won't work on RBE.
    - "--strategy=ImageSecurityCheck=local"
    # Run the config test locally because it runs docker which needs to pull
    # image and the credentials to do this aren't available on the remote
    # machines.
    - "--strategy_regexp=//:configs_test=local"
    - "--genrule_strategy=remote"
    - "--define=EXECUTOR=remote"
    - "--remote_cache=remotebuildexecution.googleapis.com"
    - "--remote_executor=remotebuildexecution.googleapis.com"
    - "--remote_timeout=3600"
    - "--auth_enabled=true"
    - "--test_output=errors"
    - "--host_force_python=PY2"
    - "//layers/..."
