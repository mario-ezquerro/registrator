NAME=registrator
VERSION=$(shell cat VERSION)
DEV_RUN_OPTS ?= consul:

dev:
	docker build -f Dockerfile.dev -t $(NAME):dev .
	docker run --rm \
		-v /var/run/docker.sock:/tmp/docker.sock \
		$(NAME):dev /bin/registrator $(DEV_RUN_OPTS)

build:
	mkdir -p build
	docker build -t $(NAME):$(VERSION) .
	docker save $(NAME):$(VERSION) | gzip -9 > build/$(NAME)_$(VERSION).tgz

release:
	rm -rf release && mkdir release
	go install github.com/progrium/gh-release@latest
	cp build/* release
	gh-release create mario-ezquerro/$(NAME) $(VERSION) \
		$(shell git rev-parse --abbrev-ref HEAD) $(VERSION)

docs:
	# Usar mkdocs directamente si está instalado, o usar una imagen oficial de mkdocs
	if command -v mkdocs >/dev/null 2>&1; then \
		mkdocs serve; \
	else \
		docker run --rm -it -p 8000:8000 \
			-v $(PWD):/docs \
			squidfunk/mkdocs-material serve -a 0.0.0.0:8000; \
	fi

.PHONY: build release docs
