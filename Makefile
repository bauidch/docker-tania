# Makefile for build Docker images
DOCKER_REPO=bauidch
APP_NAME=tania
VERSION=latest

.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

lint:
	@echo 'Run hadolint on your dockerfile'
	@docker run --rm -i hadolint/hadolint < Dockerfile

test:
	@echo 'Run containter-structure-test on your Docker'
	@docker build . -t image-testing:latest
	container-structure-test test --image image-testing:latest --config tests/test_config.yml
	@docker rmi image-testing:latest

build: ## Build the beta web container
	docker build --no-cache -f Dockerfile -t $(DOCKER_REPO)/$(APP_NAME):$(VERSION) .

release: build publish ## Make a release by building and publishing the  tagged containers to HUB

publish: docker-login publish-version ## publish the tagged containers to HUB

publish-version: ## push the tagged container to HUB
	@echo 'publish $(VERSION) to $(DOCKER_REPO)/$(APP_NAME)'
	docker push $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

tag-version:
	@echo 'create tag $(VERSION)'
	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):$(VERSION)
	# git rev-parse --short HEAD

docker-login: ## Login Docker
	@grep -q "index.docker.io" ${HOME}/.docker/config.json > /dev/null 2>&1 || docker login

clean: ## Clean this shit
	@docker system prune -f
