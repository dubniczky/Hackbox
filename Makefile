# These commands are used for development

uname := detrix
cname := hackbox
devtag := dev
vnc_port := 8080:8080
novnc_port := 5900:5900
env_file := .env
current_directory := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Run even if file with same name exists
.PHONY: all build start compose box

# Quick build and start for development
all:
	@$(MAKE) -s build
	@$(MAKE) -s start

# Build curent container with dev tag
build:
	docker build -t $(cname):$(devtag) .

# Start latest dev tagged container
start:
	docker run --rm -it \
		-p $(vnc_port) \
		-p $(novnc_port) \
		--mount type=bind,source="$(current_directory)/share",target=/share \
		$(cname):$(devtag)

# Start docker-compose
compose:
	docker-compose up

# Pull the latest version of the container
pull:
	docker pull $(uname)/$(cname):latest

# Command to start the latest release version of the container
box:
	@docker run --rm -it \
		-p $(vnc_port) \
		-p $(novnc_port) \
		--mount type=bind,source="$(current_directory)/share",target=/share \
		$(uname)/$(cname):latest
