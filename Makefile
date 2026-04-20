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

build-multiarch:
	mkdir -p build
	docker buildx create --name multiarch-builder --use || true
	docker buildx build --platform linux/amd64,linux/arm64 -t $(NAME):$(VERSION) -o type=oci,dest=build/$(NAME)_$(VERSION)_multiarch.tar .

push-multiarch:
	@if [ -z "$(DOCKER_USER)" ]; then \
		echo "Error: DOCKER_USER is missing."; \
		echo "Please run: make push-multiarch DOCKER_USER=tu_usuario_de_docker"; \
		exit 1; \
	fi
	docker buildx create --name multiarch-builder --use || true
	docker buildx build --platform linux/amd64,linux/arm64 -t $(DOCKER_USER)/$(NAME):$(VERSION) --push .

release:
	rm -rf release && mkdir release
	go get github.com/progrium/gh-release/...
	cp build/* release
	gh-release create gliderlabs/$(NAME) $(VERSION) \
		$(shell git rev-parse --abbrev-ref HEAD) $(VERSION)

docs:
	boot2docker ssh "sync; sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'" || true
	docker run --rm -it -p 8000:8000 -v $(PWD):/work gliderlabs/pagebuilder mkdocs serve

circleci:
	rm ~/.gitconfig
ifneq ($(CIRCLE_BRANCH), release)
	echo build-$$CIRCLE_BUILD_NUM > VERSION
endif

.PHONY: build build-multiarch release docs
