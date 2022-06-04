# These commands are used for development

cname := kali

.PHONY: build start

build:
	docker build -t $(cname) .

start:
	docker run --rm -it -p 8080:8080 $(cname)