# Image URL to use all building/pushing image targets
REGISTRY ?= quay.io
REPOSITORY ?= $(REGISTRY)/eformat/tech-exercise-test

IMG := $(REPOSITORY):latest

# run tests
test:
	./regression.sh

# Podman Login
podman-login:
	@podman login -u $(DOCKER_USER) -p $(DOCKER_PASSWORD) $(REGISTRY)

# Build the oci image
podman-build:
	podman build . -t ${IMG} -f Containerfile

# Push the oci image
podman-push: podman-build
	podman push ${IMG}

podman-run:
	podman-compose -f docker-compose.yml up -d

podman-stop:
	podman-compose -f docker-compose.yml down
