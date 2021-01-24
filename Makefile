REG?=localhost\:5000
# REG?=qbrn.reg
TAG=0
ARGS=--build-arg REG=$(REG) --build-arg TAG=$(TAG)

IMGS=$(shell find * -type f -name imgs.sh)
PKGS=$(shell find * -type f -name pkgs.sh)
SRCS=$(shell find * -type f -name srcs.sh)

UTIL=$(shell pwd)/util.sh

MAKEFLAGS += -rR

.PHONY: all clean pkgs

util.sh: base.sh
	chmod u+x $<
	ln -s base.sh $@

pkgs: util.sh
	DF=$(shell pwd)/Dockerfile; \
	docker build -t $(REG)/ubu:$(TAG) --pull --target=ubu $(ARGS) - < $$DF; \
	docker push $(REG)/ubu:$(TAG); \
	for d in $(subst /pkgs.sh,,$(PKGS)); do \
		echo $$d; \
		if [ ! $$d = "bazel" ]; then continue; fi; \
		(cd $$d || exit; \
			$(UTIL) -s pkgs; \
			docker build --pull --target=pkgs $(ARGS) -f $$DF -o pkgs .; \
		) \
	done

clean-pkgs: util.sh
	for d in $(subst /pkgs.sh,,$(PKGS)); do \
		if [ ! $$d = "bazel" ]; then continue; fi; \
		(cd $$d || exit; \
			$(UTIL) -s pkgs; \
			pkgs/qpx.sh -c; \
		) \
	done

srcs: util.sh
	for d in $(subst /srcs.sh,,$(SRCS)); do \
		if [ ! $$d = "bazel" ]; then continue; fi; \
		(cd $$d || exit; \
			$(UTIL) -s srcs; \
			srcs/qpx.sh -i pull; \
		) \
	done

clean-srcs: util.sh
	for d in $(subst /srcs.sh,,$(SRCS)); do \
		if [ ! $$d = "bazel" ]; then continue; fi; \
		(cd $$d || exit; \
			$(UTIL) -s srcs; \
			srcs/qpx.sh -c; \
		) \
	done

ubu: pkgs srcs
	(cd ubuntu; \
		docker build -t $(REG)/old:$(TAG) --pull --target=old $(ARGS) .; \
		docker push $(REG)/old:$(TAG); \
		docker build -t $(REG)/old-dev:$(TAG) --pull --target=old-dev $(ARGS) .; \
		docker push $(REG)/old-dev:$(TAG); \
		\
		docker build -t $(REG)/new:$(TAG) --pull --target=new $(ARGS) .; \
		docker push $(REG)/new:$(TAG); \
		docker build -t $(REG)/new-dev:$(TAG) --pull --target=new-dev $(ARGS) .; \
		docker push $(REG)/new-dev:$(TAG); \
	)

bzl: util.sh
	(cd bazel; \
		docker build -t $(REG)/bzl_old:$(TAG) --pull --target=bzl_old $(ARGS) .; \
		docker push $(REG)/bzl_old:$(TAG); \
		srcs/qpx.sh -i old; \
		docker build -t $(REG)/bzl_new:$(TAG) --pull --target=bzl_new $(ARGS) .; \
		docker push $(REG)/bzl_new:$(TAG); \
	)

imgs2:
	(cd ubuntu/libs; \
		docker build -t $(REG)/pkg-dev:$(TAG) --pull --target=pkg-dev $(ARGS) .; \
		docker push $(REG)/pkg-dev:$(TAG); \
		chmod u+x $(UTIL); $(UTIL) -s srcs; \
		srcs/qpx.sh -i srcs; \
		docker build -t $(REG)/src-dev:$(TAG) --pull --target=src-dev $(ARGS) .; \
		docker push $(REG)/src-dev:$(TAG); \
		rm srcs/qpx.sh; \
	)
	(cd julia; \
		docker build -t $(REG)/jl_old_pkg:$(TAG) --pull --target=jl_old_pkg $(ARGS) .; \
		docker push $(REG)/jl_old_pkg:$(TAG); \
		docker build -t $(REG)/jl_new_pkg:$(TAG) --pull --target=jl_new_pkg $(ARGS) .; \
		docker push $(REG)/jl_new_pkg:$(TAG); \
		docker build -t $(REG)/jl_old_src:$(TAG) --pull --target=jl_old_src $(ARGS) .; \
		docker push $(REG)/jl_old_src:$(TAG); \
		docker build -t $(REG)/jl_new_src:$(TAG) --pull --target=jl_new_src $(ARGS) .; \
		docker push $(REG)/jl_new_src:$(TAG); \
	)

# all3: $(NAMES)

clean:
