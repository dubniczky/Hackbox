# These commands are used for development

cname := kali

.PHONY: all build start

all:
	$(MAKE) -s build
	$(MAKE) -s start

build:
	docker build -t $(cname) .

start:
	docker run --rm -it -p 8080:8080 $(cname)