REGISTRY?=qbrn.reg
DOCKERFILES=$(shell find * -type f -name Dockerfile -not -path "*/.devcontainer/*" -not -path "other/*")
NAMES=$(subst /,\:,$(subst /Dockerfile,,$(DOCKERFILES)))
IMAGES=$(addprefix $(subst :,\:,$(REGISTRY))/,$(NAMES))
DEPENDS=.depends.mk
MAKEFLAGS += -rR

.PHONY: all clean push pull run exec check checkrebuild pull-base ci $(NAMES) $(IMAGES)

all: $(NAMES)

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
	grep '^FROM \$$REGISTRY/' $(DOCKERFILES) | \
		awk -F '/Dockerfile:FROM \\$$REGISTRY/' '{ print $$1 " " $$2 }' | \
		sed 's@[:/]@\\:@g' | awk '{ print "$(subst :,\\:,$(REGISTRY))/" $$1 ": " "$(subst :,\\:,$(REGISTRY))/" $$2 }' > $@

sinclude $(DEPENDS)

$(NAMES): %: $(REGISTRY)/%
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
	docker build --build-arg REGISTRY=$(REGISTRY) -t $@ $(subst :,/,$(subst $(REGISTRY)/,,$@))
endif
ifeq (checkrebuild,$(filter checkrebuild,$(MAKECMDGOALS)))
	which duuh >/dev/null || (>&2 echo "checkrebuild require duuh command to be installed in PATH" && exit 1)
	duuh $@ || (docker build --build-arg REGISTRY=$(REGISTRY) --no-cache -t $@ $(subst :,/,$(subst $(REGISTRY)/,,$@)) && duuh $@)
endif
