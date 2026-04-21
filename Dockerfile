FROM golang:1.25-alpine3.23 AS builder

WORKDIR /go/src/github.com/mario-ezquerro/registrator/

# Instalar dependencias del sistema
RUN apk add --no-cache git

# Copiar todo el código (incluyendo la carpeta local /vendor generada)
COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -mod=vendor \
		-a -installsuffix cgo \
		-ldflags "-X main.Version=$(cat VERSION)" \
		-o bin/registrator \
		.

FROM alpine:3.23
RUN apk add --no-cache ca-certificates tzdata
COPY --from=builder /go/src/github.com/mario-ezquerro/registrator/bin/registrator /bin/registrator

ENTRYPOINT ["/bin/registrator"]
