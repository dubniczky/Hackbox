# These commands are used for development

cname := kali

.PHONY: build

build:
	docker build -t $(kali) .

start:
	docker run --rm -it -p 8080:8080 kali