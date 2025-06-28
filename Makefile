# Define variables
PODMAN 			:= podman 
ANTORA_IMAGE 	:= docker.io/antora/antora
HTTPD_IMAGE  	:= registry.access.redhat.com/ubi9/httpd-24:1-301

.PHONY: help
help:
	@echo Available targets:
	@fgrep "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sort

.PHONY: build
build: ## Build new site
		echo "Starting build process..."
		echo "Removing old site..."
		rm -rf ./www/*
		echo "Building new site..."
		$(PODMAN) run --rm --name builder \
		-v "./:/antora:z" \
		$(ANTORA_IMAGE) --stacktrace default-site.yml

.PHONY: clean
clean: ## Remove old site
		echo "Removing old site..."
		rm -rf ./www/*
		echo "Old site removed"

.PHONY: serve
serve: ## Starting static webserver to serve html content
		echo "Starting serve process..."
		# TODO: Add case statement to allow stopping, starting, and restarting
		# TODO: Add logic to detect both podman and docker, if both are installed, use podman as default "first found"

		$(PODMAN) run -d --rm --name showroom-httpd -p 8080:8080 \
			-v "./www:/var/www/html/:z" \
			$(HTTPD_IMAGE)

		echo "Serving lab content on http://localhost:8080/index.html"

.PHONY: stop
stop: ## Stopping the webserver
		echo "Stopping serve process..."
		$(PODMAN) kill showroom-httpd
		echo "Stopped serve process."
