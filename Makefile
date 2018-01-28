SHELL=/bin/bash -o pipefail

ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
NODE_VERSION := 8.9.4

CONTAINER_WORK_DIR := "/usr/app"
CONTAINER_NAME := my-dev-container



DOCKER_RUN_NODE = docker run \
			   -e "NODE_ENV=production" \
			   -m "300M" --memory-swap "1G" \
			   -w $(CONTAINER_WORK_DIR) \
			   --name "my_running_node_app" \
			   $(CONTAINER_NAME)

# Docker run script
# Note: volume mapping sequence matters:
#       mapping node_modules last to prevent override
DOCKER_RUN_SHELL = docker run \
                        -it --rm \
                        --name my_running_shell \
                        -v $(ROOT_DIR):$(CONTAINER_WORK_DIR) \
                        -v $(CONTAINER_WORK_DIR)/node_modules \
                        -v $(ROOT_DIR)/aws-wrkspace:/aws-wrkspace \
                        -w $(CONTAINER_WORK_DIR) \
                        -p 8080:8080 \
                        -p 8000:8000 \
                        $(CONTAINER_NAME) \
                        bash

DOCKER_BUILD = docker build \
                -t $(CONTAINER_NAME) .

define app-run
	$(DOCKER_RUN_NODE) npm start
endef

define shell-run
	$(DOCKER_RUN_SHELL)
endef

define container-build
	$(DOCKER_BUILD)
endef


# Default target
# Run app
.PHONY: run_app
run_app:
	$(call app-run)

# Run shell (default)
.PHONY: run
run:
	$(call shell-run)

# Build docker container
.PHONY: build
build:
		$(call container-build)


# Clean targets
.PHONY: clean-all-images
clean-all-images:
	-docker ps -aq | xargs docker rm --force
	-docker images -q | xargs docker rmi --force
	-docker volume ls -q | xargs docker volume rm




