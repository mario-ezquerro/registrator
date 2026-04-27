FROM golang:1.25-alpine AS builder

WORKDIR /go/src/github.com/mario-ezquerro/registrator/

# Instalar dependencias del sistema y actualizar paquetes base para evitar CVEs
RUN apk upgrade --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main busybox alpine-baselayout apk-tools && apk add --no-cache git

# Copiar todo el código (incluyendo la carpeta local /vendor generada)
COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -mod=vendor \
		-a -installsuffix cgo \
		-ldflags "-X main.Version=$(cat VERSION)" \
		-o bin/registrator \
		.

FROM alpine:3.23.4
RUN apk upgrade --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main busybox alpine-baselayout apk-tools && apk add --no-cache ca-certificates tzdata
COPY --from=builder /go/src/github.com/mario-ezquerro/registrator/bin/registrator /bin/registrator

ENTRYPOINT ["/bin/registrator"]
