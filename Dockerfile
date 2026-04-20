FROM golang:1.17.1-alpine3.14 AS builder

WORKDIR /go/src/github.com/mario-ezquerro/registrator/

# Instalar dependencias del sistema y optimizar la caché de los modulos de Go
RUN apk add --no-cache git

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build \
		-a -installsuffix cgo \
		-ldflags "-X main.Version=$(cat VERSION)" \
		-o bin/registrator \
		.

FROM alpine:3.14
RUN apk add --no-cache ca-certificates tzdata
COPY --from=builder /go/src/github.com/mario-ezquerro/registrator/bin/registrator /bin/registrator

ENTRYPOINT ["/bin/registrator"]
