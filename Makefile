NAME=registrator
VERSION=$(shell cat VERSION)
DEV_RUN_OPTS ?= consul:
DOCKER_USER ?= mario-ezquerro
SOURCES := $(shell find . -name '*.go')

.PHONY: dev build build-multiarch push-multiarch release docs circleci lint test vet fmt

dev:
	docker build -f Dockerfile.dev -t $(NAME):dev .
	docker run --rm \
		-v /var/run/docker.sock:/tmp/docker.sock \
		$(NAME):dev /bin/registrator $(DEV_RUN_OPTS)

build: test
	mkdir -p build
	docker build -t $(NAME):$(VERSION) .
	docker save $(NAME):$(VERSION) | gzip -9 > build/$(NAME)_$(VERSION).tgz

build-multiarch: test
	mkdir -p build
	docker buildx create --name multiarch-builder --use || true
	docker buildx build --platform linux/amd64,linux/arm64 -t $(NAME):$(VERSION) -o type=oci,dest=build/$(NAME)_$(VERSION)_multiarch.tar .

push-multiarch:
	docker buildx create --name multiarch-builder --use || true
	docker buildx build --platform linux/amd64,linux/arm64 -t $(DOCKER_USER)/$(NAME):$(VERSION) --push .

release:
	rm -rf release && mkdir release
	go get github.com/progrium/gh-release/...
	cp build/* release
	gh-release create $(DOCKER_USER)/$(NAME) $(VERSION) \
		$(shell git rev-parse --abbrev-ref HEAD) $(VERSION)

docs:
	docker run --rm -it -p 8000:8000 -v $(PWD):/work mkdocs/mkdocs serve

test: vet
	go test -v ./...

vet: fmt
	go vet ./...

fmt:
	go fmt ./...

lint:
	go run github.com/golangci/golangci-lint/cmd/golangci-lint@v1.54.0 run ./...

circleci:
	rm -f ~/.gitconfig
ifneq ($(CIRCLE_BRANCH), release)
	echo build-$$CIRCLE_BUILD_NUM > VERSION
endif
