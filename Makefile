SHELL := /bin/bash

DOCKER_REPO := dankcity/dank.city
DOCKER_REPO_CI := dankcity/dank.city-ci
GIT_HASH = $(shell git rev-parse --short=7 HEAD)
GIT_TAG = $(shell git describe --tags --exact-match $(GIT_HASH) 2>/dev/null)

.PHONY: docker-login
docker-login:
	echo $(DOCKER_PASS) | docker login -u $(DOCKER_USER) --password-stdin

.PHONY: build
build:
	docker build \
		--cache-from $(DOCKER_REPO):latest \
		-t $(DOCKER_REPO):local .

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
