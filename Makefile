# These commands are used for development

cname := hackbox
devtag := dev
vnc_port := 8080:8080
novnc_port := 5900:5900
env_file := .env

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
	@docker run --rm -it \
		--net=host \
		--env-file $(env_file) \
		$(cname):$(devtag)

# Start docker-compose
compose:
	docker-compose up

# Command to start the latest release version of the container
box:
	docker run --rm -it \
		-p $(vnc_port) \
		-p $(novnc_port) \
		--env-file $(env_file) \
		$(cname):latest
