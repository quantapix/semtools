REG?=localhost\:5000
# REG?=qbrn.reg
TAG=dkr
DST=/usr/local

ARGS=--build-arg REG=$(REG) --build-arg TAG=$(TAG) --build-arg DST=$(DST)

IMGS=$(shell find * -type f -name imgs.sh)
PKGS=$(shell find * -type f -name pkgs.sh)
SRCS=$(shell find * -type f -name srcs.sh)

UPSS=$(shell find * -type d -name upstream)

UTIL=$(shell pwd)/util.sh

MAKEFLAGS += -rR

.PHONY: all clean clean-pkgs clean-srcs upstreams reset

all: tgt.bzl

util.sh: base.sh
	chmod u+x $<
	ln -s base.sh $@

tgt.pkgs: util.sh
	DF=$(shell pwd)/Dockerfile; \
	docker build -t $(REG)/ubu:$(TAG) --pull --target=ubu $(ARGS) - < $$DF; \
	docker push $(REG)/ubu:$(TAG); \
	for d in $(subst /pkgs.sh,,$(PKGS)); do \
		(cd $$d || exit; \
			$(UTIL) -s pkgs; \
			docker build --pull --target=pkgs $(ARGS) -f $$DF -o pkgs . \
		) \
	done
	touch tgt.pkgs

tgt.srcs: util.sh
	for d in $(subst /srcs.sh,,$(SRCS)); do \
		(cd $$d || exit; \
			$(UTIL) -s srcs; \
			srcs/qpx.sh -i pull; \
		) \
	done
	touch tgt.srcs

tgt.ubu: tgt.pkgs tgt.srcs
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
	touch tgt.ubu

tgt.dev: tgt.ubu
	(cd ubuntu/libs; \
		docker build -t $(REG)/pkg-dev:$(TAG) --pull --target=pkg-dev $(ARGS) .; \
		docker push $(REG)/pkg-dev:$(TAG); \
		srcs/qpx.sh -i srcs; \
		docker build -t $(REG)/src-dev:$(TAG) --pull --target=src-dev $(ARGS) .; \
		docker push $(REG)/src-dev:$(TAG); \
	)
	touch tgt.dev

tgt.bzl: tgt.ubu
	(cd bazel; \
		docker build -t $(REG)/bzl_old:$(TAG) --pull --target=bzl_old $(ARGS) .; \
		docker push $(REG)/bzl_old:$(TAG); \
		srcs/qpx.sh -i old; \
		docker build -t $(REG)/bzl_new:$(TAG) --pull --target=bzl_new $(ARGS) .; \
		docker push $(REG)/bzl_new:$(TAG); \
	)
	touch tgt.bzl

tgt.jl: tgt.dev
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
	touch tgt.jl

clean: clean-pkgs clean-srcs
	rm -f tgt.*

clean-pkgs: 
	for d in $(subst /pkgs.sh,,$(PKGS)); do \
		(cd $$d || exit; \
			if [ -e pkgs/qpx.sh ]; then pkgs/qpx.sh -c; fi \
	  ) \
	done
	rm -f tgt.pkgs

clean-srcs:
	for d in $(subst /srcs.sh,,$(SRCS)); do \
		(cd $$d || exit; \
			if [ -e srcs/qpx.sh ]; then srcs/qpx.sh -c; fi \
		) \
	done
	rm -f tgt.srcs

clean-upstreams:
	for d in $(UPSS); do \
		rm -rf $$d; \
	done

reset: 
	docker container stop registry && docker container rm -v registry
	docker container prune
	docker image prune
	docker builder prune
	docker run -d -p 5000:5000 --restart=always --name registry registry:2
