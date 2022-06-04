# These commands are used for development

cname := kali
devtag := dev

# Run even if file with same name exists
.PHONY: all build start

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
		-p 8080:8080 \
		--env-file .env \
		$(cname):$(devtag)
