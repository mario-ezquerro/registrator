# Reglas del Proyecto (Registrator)

Estas reglas están diseñadas para guiar a asistentes de Inteligencia Artificial al interactuar con el repositorio.

## Stack
- Go 1.17
- Docker (Multi-stage build)

## Convenciones de Desarrollo (Importante)
- **Ejecución Local**: Es posible que no haya binarios de `go` ni `docker` en el host (como ya se ha verificado). De presentarse un error al ejecutar validaciones (por ejemplo, `command not found: docker` o `command not found: go`), notifica al usuario que delegarás la prueba a su infraestructura o a él mismo.
- **Compilación Multi-Arquitectura**: Este proyecto da soporte completo a `ARM` (Apple Silicon) e `Intel` (x86). Cuando se creen o modifiquen flujos de release, SIEMPRE usar los targets multi-arquitectura como están fijados en el archivo `Makefile` (`make build-multiarch`).
- **Imports Nativos**: El módulo base es `github.com/mario-ezquerro/registrator`. No uses nunca más el antiguo `gliderlabs`. Si añades código Go de este mismo repositorio, asegúrate de utilizar el formato `github.com/mario-ezquerro/registrator/...`

## Makefile
Existen *targets* de `make` definidos específicamente para ser llamados cuando se verifiquen los programas (aunque debes considerar si `docker`/`go` están disponibles):
- `make lint`: Corre `golangci-lint` (si hay entorno Go disponible)
- `make test`: Pasa todos los unit-tests del código Go.
- `make build-multiarch`: Construye la versión final para Docker.

## Buenas Prácticas de Docker
Al interactuar o modificar la configuración de Docker, respeta estas reglas:
- **Caché de Capas (Layer Caching)**: Copia primero los archivos `go.mod` y `go.sum` y ejecuta el comando de descargar dependencias (`go mod download`) ANTES de copiar el resto del código fuente. Esto maximiza la reutilización del cache en Docker en caso de que solo cambie el código principal.
- **Imágenes Ligeras (Alpine)**: Para la imagen de producción/ejecución, básate siempre en distribuciones mínimas y seguras como `alpine` (por ejemplo, `alpine:3.14`). Asegúrate de inyectar dependencias globales de seguridad básica como `ca-certificates` y zona horaria (`tzdata`).
- **Archivo .dockerignore**: Mantén siempre actualizado un `.dockerignore` evitando enviar el `.git/`, builds antiguos y vendors al daemon de Docker; agilizará muchísimo la compilación.
- **Etiquetas Absolutas**: Nunca uses etiquetas como `:latest` o similares indiscriminadamente para constructores (builders). Usa la versión predecible de alpine como `golang:X.XX.X-alpineX.X`.
