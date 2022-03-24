# Image URL to use all building/pushing image targets
REGISTRY ?= quay.io
REPOSITORY ?= $(REGISTRY)/rht-labs/tech-exercise-docs

IMG := $(REPOSITORY):latest

# Podman Login
podman-login:
	@podman login -u $(DOCKER_USER) -p $(DOCKER_PASSWORD) $(REGISTRY)

# Build the oci image
podman-build:
	podman build . -t ${IMG} -f Containerfile

# Push the oci image
podman-push: podman-build
	podman push ${IMG}

deploy:
	oc new-project tl500-docs || true
	oc new-app quay.io/rht-labs/tech-exercise-docs --name tl500-docs
	oc expose svc tl500-docs
	oc patch route/tl500-docs --type=json -p '[{"op":"add", "path":"/spec/tls", "value":{"termination":"edge","insecureEdgeTerminationPolicy":"Redirect"}}]'