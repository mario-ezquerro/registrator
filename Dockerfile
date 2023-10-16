FROM golang:1.20.10-alpine3.17 AS builder
LABEL org.opencontainers.image.version="v8.1"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.title="Imagen regitrator use with carefull"
LABEL org.opencontainers.image.url="https://github.com/mario-ezquerro/registrator"
LABEL org.regitrator.maintainer="Mario Ezquerro"

WORKDIR /go/src/github.com/mario-ezquerro/registrator/
COPY . .
RUN \
	apk add --no-cache curl git \
	&& curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh \
	&& dep ensure -vendor-only \
	&& CGO_ENABLED=0 GOOS=linux go build \
		-a -installsuffix cgo \
		-mod=mod \
		-ldflags "-X main.Version=$(cat VERSION)" \
		-o bin/registrator \
		.

FROM alpine:3.17
RUN apk add --no-cache ca-certificates
COPY --from=builder /go/src/github.com/mario-ezquerro/registrator/bin/registrator /bin/registrator

ENTRYPOINT ["/bin/registrator"]
