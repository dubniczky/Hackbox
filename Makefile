# These commands are used for development

cname := kali
devtag := dev
vnc_port := 8080:8080
novnc_port := 5900:5900

# Run even if file with same name exists
.PHONY: all build start compose

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
		-p $(vnc_port) \
		-p $(novnc_port) \
		--env-file .env \
		$(cname):$(devtag)

# Start docker-compose
compose:
	docker-compose up
