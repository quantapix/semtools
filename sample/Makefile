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
