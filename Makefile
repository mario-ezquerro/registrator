NAME=registrator
VERSION=$(shell cat VERSION)
DEV_RUN_OPTS ?= consul:
DOCKER_USER ?= mario-ezquerro
SOURCES := $(shell find . -name '*.go')

.PHONY: dev build bump-version build-multiarch push-multiarch release docs circleci lint test vet fmt

dev:
	docker build -f Dockerfile.dev -t $(NAME):dev .
	docker run --rm \
		-v /var/run/docker.sock:/tmp/docker.sock \
		$(NAME):dev /bin/registrator $(DEV_RUN_OPTS)

bump-version:
	@CURRENT_VERSION=$$(cat VERSION); \
	FORMATTED_PREFIX=$${CURRENT_VERSION%.*}.; \
	LAST_DIGIT=$${CURRENT_VERSION##*.}; \
	NEW_DIGIT=$$((LAST_DIGIT + 1)); \
	NEW_VERSION="$${FORMATTED_PREFIX}$${NEW_DIGIT}"; \
	echo $$NEW_VERSION > VERSION; \
	echo "Version actualizada: $$CURRENT_VERSION -> $$NEW_VERSION"

# La regla exige que siempre que se compile se haga la version de ARM y X86
# Y que aumente una cifra el fichero VERSION
build: bump-version test
	$(eval VERSION=$(shell cat VERSION))
	mkdir -p build
	docker buildx create --name multiarch-builder --use || true
	docker buildx build --platform linux/amd64,linux/arm64 -t $(NAME):$(VERSION) -o type=oci,dest=build/$(NAME)_$(VERSION)_multiarch.tar .

build-multiarch: build

push-multiarch: bump-version
	$(eval VERSION=$(shell cat VERSION))
	docker buildx create --name multiarch-builder --use || true
	docker buildx build --platform linux/amd64,linux/arm64 -t $(DOCKER_USER)/$(NAME):$(VERSION) --push .

release: push-multiarch
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
