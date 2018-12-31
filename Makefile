SHELL := /bin/bash

MAKEFILE_PATH := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

KUBECONFIG := $(MAKEFILE_PATH)/kube/dank.city.config
DC_CONFIG := $(MAKEFILE_PATH)/kube/dank.city.yaml

DOCKER_REPO := dankcity/dank.city
DOCKER_REPO_CI := dankcity/dank.city-ci
GIT_HASH = $(shell git rev-parse --short=7 HEAD)
GIT_TAG = $(shell git describe --tags --exact-match $(GIT_HASH) 2>/dev/null)

ifneq ($(GIT_TAG),)
DOCKER_TAG ?= $(GIT_TAG)
else
DOCKER_TAG ?= $(GIT_HASH)
endif

.DEFAULT_GOAL := help

# ################################
#
# Build/Dev/Test Targets
#
# ################################
.PHONY: build
build:
	docker build \
		--cache-from $(DOCKER_REPO):latest \
		-t $(DOCKER_REPO):local .

.PHONY: run
run:
	docker run --rm -it \
		-p 8000:8000 \
		--network host\
		$(DOCKER_REPO):local

.PHONY: shell
shell:
	docker run --rm -it \
		--entrypoint ash \
		$(DOCKER_REPO):local

.PHONY: test-lint
test-lint:
	docker run --rm -it \
		--entrypoint ash \
		$(DOCKER_REPO):local \
		-c ' \
			set -e; \
			pip install tox; \
			tox -e lint; \
		'

.PHONY: test-unit
test-unit:
	$(info $@ is not currently implemented)

.PHONY: test-functional
test-functional:
	$(info $@ is not currently implemented)

# ################################
#
# Docker Tag/Push/Pull Targets
#
# ################################
.PHONY: docker-login
docker-login:
	echo $(DOCKER_PASS) | docker login -u $(DOCKER_USER) --password-stdin

.PHONY: tag-git-tag
tag-git-tag:
	docker tag $(DOCKER_REPO):$(GIT_HASH) $(DOCKER_REPO):$(GIT_TAG)

.PHONY: tag-latest
tag-latest:
	docker tag $(DOCKER_REPO):local $(DOCKER_REPO):latest

.PHONY: push-latest
push-latest:
	docker push $(DOCKER_REPO):latest

.PHONY: pull-latest
pull-latest:
	docker pull $(DOCKER_REPO):latest

.PHONY: tag-latest-as-local
tag-latest-as-local:
	docker tag $(DOCKER_REPO):latest $(DOCKER_REPO):local

.PHONY: push-tagged
push-tagged:
	docker push $(DOCKER_REPO):$(GIT_TAG)

.PHONY: push-ci
push-ci:
	docker tag $(DOCKER_REPO):local $(DOCKER_REPO_CI):$(GIT_HASH)
	docker push $(DOCKER_REPO_CI):$(GIT_HASH)

.PHONY: pull-ci
pull-ci:
	docker pull $(DOCKER_REPO_CI):$(GIT_HASH)
	docker tag $(DOCKER_REPO_CI):$(GIT_HASH) $(DOCKER_REPO):$(GIT_HASH)
	docker tag $(DOCKER_REPO_CI):$(GIT_HASH) $(DOCKER_REPO):local

# ################################
#
# Kubernetes Targets
#
# ################################
.PHONY: $(KUBECONFIG)
$(KUBECONFIG):
	$(info Decrypting $@)
ifneq ("$(KUBECONFIG_PASSPHRASE)","")
	@gpg \
		--pinentry-mode=loopback \
		--passphrase $(KUBECONFIG_PASSPHRASE) \
		--output $@ \
		-d $@.gpg
else
	$(error KUBECONFIG_PASSPHRASE not set)
endif

.PHONY: $(KUBECONFIG).gpg
$(KUBECONFIG).gpg:
	$(info Encrypting $@)
ifneq ("$(KUBECONFIG_PASSPHRASE)","")
	@gpg \
		--pinentry-mode=loopback \
		--passphrase $(KUBECONFIG_PASSPHRASE) \
		--output $@ \
		-c $(patsubst %.gpg,%,$@)
else
	$(error KUBECONFIG_PASSPHRASE not set)
endif

.PHONY: decrypt
decrypt: $(MAKEFILE_PATH)/kube/dank.city.config

.PHONY: encrypt
encrypt: $(MAKEFILE_PATH)/kube/dank.city.config.gpg

.PHONY: get-namespaces
get-namespaces:
	@kubectl \
		--kubeconfig $(KUBECONFIG) \
		get namespaces

.PHONY: deploy
deploy:
	@cat $(DC_CONFIG) | \
		DOCKER_TAG=$(DOCKER_TAG) DEPLOY_REPO=$(DEPLOY_REPO) envsubst | \
		kubectl \
			--kubeconfig $(KUBECONFIG) \
			-n dank-city-$(NAMESPACE) \
			apply -f -

.PHONY: deploy-dev
deploy-dev:
	$(MAKE) --no-print-directory NAMESPACE=dev DEPLOY_REPO=$(DOCKER_REPO_CI) deploy

.PHONY: deploy-staging
deploy-staging:
	$(MAKE) --no-print-directory NAMESPACE=staging DEPLOY_REPO=$(DOCKER_REPO_CI) deploy

.PHONY: deploy-prod
deploy-prod:
	$(MAKE) --no-print-directory NAMESPACE=prod DEPLOY_REPO=$(DOCKER_REPO) deploy

.PHONY: help
help:
	@echo "Run 'make build' to build the dank.city image"
