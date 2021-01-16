REG?=qbrn.reg
TAG=std
ARGS=--build-arg REG=$(REG) --build-arg TAG=$(TAG)

DOCKERFILES=$(shell find * -type f -name Dockerfile -not -path "*/.devcontainer/*" -not -path "other/*")
NAMES=$(subst /,\:,$(subst /Dockerfile,,$(DOCKERFILES)))
IMAGES=$(addprefix $(subst :,\:,$(REG))/,$(NAMES))
DEPENDS=.depends.mk
MAKEFLAGS += -rR

.PHONY: all clean push pull run exec check checkrebuild pull-base ci $(NAMES) $(IMAGES)

all: 
	(cd ubuntu/deps; \
		docker build -t $(REG)/qpx-base:$(TAG) --pull --target=qpx-base $(ARGS) - < Dockerfile; \
		docker push $(REG)/ubu-base:$(TAG); \
		docker build -t $(REG)/qpx-dev:$(TAG) --pull --target=qpx-dev $(ARGS) - < Dockerfile; \
		docker push $(REG)/qpx-dev:$(TAG)
		chmod u+x deps.sh; \
		./deps.sh -i srcs; \
		docker build -t $(REG)/qpx_src:$(TAG) --pull --target=qpx_src $(ARGS) .; \
		docker push $(REG)/qpx_src:$(TAG); \
		)

all2: 
	(cd ubuntu; \
		docker build -t $(REG)/ubu-base:$(TAG) --pull --target=ubu-base $(ARGS) - < Dockerfile; \
		docker push $(REG)/ubu-base:$(TAG); \
		docker build -t $(REG)/ubu-dev:$(TAG) --pull --target=ubu-dev $(ARGS) - < Dockerfile; \
		docker push $(REG)/ubu-dev:$(TAG))
	(cd julia; \
		docker build -t $(REG)/jl_old_pkg:$(TAG) --pull --target=jl_old_pkg $(ARGS) .; \
		docker push $(REG)/jl_old_pkg:$(TAG); \
		docker build -t $(REG)/jl_new_pkg:$(TAG) --pull --target=jl_new_pkg $(ARGS) .; \
		docker push $(REG)/jl_new_pkg:$(TAG); \
		chmod u+x srcs.sh; \
		./srcs.sh -i old .; \
		docker build -t $(REG)/jl_old_src:$(TAG) --pull --target=jl_old_src $(ARGS) .; \
		docker push $(REG)/jl_old_src:$(TAG); \
		./srcs.sh -i new .; \
		docker build -t $(REG)/jl_new_src:$(TAG) --pull --target=jl_new_src $(ARGS) .; \
		docker push $(REG)/jl_new_src:$(TAG))

# all3: $(NAMES)

clean:
	rm -f $(DEPENDS)

pull-base:
	# used by debian:buster-slim
	docker pull debian:buster-slim
	# used by keycloak
	docker pull jboss/keycloak:12.0.1
	# imago
	docker pull philpep/imago

ci:
	$(MAKE) pull-base checkrebuild push all

.PHONY: $(DEPENDS)
$(DEPENDS): $(DOCKERFILES)
	grep '^FROM \$$REG/' $(DOCKERFILES) | \
		awk -F '/Dockerfile:FROM \\$$REG/' '{ print $$1 " " $$2 }' | \
		sed 's@[:/]@\\:@g' | awk '{ print "$(subst :,\\:,$(REG))/" $$1 ": " "$(subst :,\\:,$(REG))/" $$2 }' > $@

sinclude $(DEPENDS)

$(NAMES): %: $(REG)/%
ifeq (push,$(filter push,$(MAKECMDGOALS)))
	docker push $<
endif
ifeq (run,$(filter run,$(MAKECMDGOALS)))
	docker run --rm -it $<
endif
ifeq (exec,$(filter exec,$(MAKECMDGOALS)))
	docker run --entrypoint sh --rm -it $<
endif
ifeq (check,$(filter check,$(MAKECMDGOALS)))
	duuh $<
endif

$(IMAGES): %:
ifeq (pull,$(filter pull,$(MAKECMDGOALS)))
	docker pull $@
else
	docker build --build-arg REG=$(REG) -t $@ $(subst :,/,$(subst $(REG)/,,$@))
endif
ifeq (checkrebuild,$(filter checkrebuild,$(MAKECMDGOALS)))
	which duuh >/dev/null || (>&2 echo "checkrebuild require duuh command to be installed in PATH" && exit 1)
	duuh $@ || (docker build --build-arg REG=$(REG) --no-cache -t $@ $(subst :,/,$(subst $(REG)/,,$@)) && duuh $@)
endif
