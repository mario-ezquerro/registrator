FROM golang:1.22-alpine3.20 AS builder
WORKDIR /go/src/github.com/mario-ezquerro/registrator/
COPY . .
RUN \
	go clean -cache -modcache && \
	apk add --no-cache git && \
	CGO_ENABLED=0 GOOS=linux go build \
		-a -installsuffix cgo \
		-ldflags "-X main.Version=$(cat VERSION)" \
		-o bin/registrator \
		.

FROM alpine:3.20
RUN apk add --no-cache ca-certificates
COPY --from=builder /go/src/github.com/mario-ezquerro/registrator/bin/registrator /bin/registrator

ENTRYPOINT ["/bin/registrator"]
