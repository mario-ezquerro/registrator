# Reglas del Proyecto (Registrator)

Estas reglas están diseñadas para guiar a asistentes de Inteligencia Artificial al interactuar con el repositorio.

## Stack
- Go 1.25
- Docker (Multi-stage build)

## Convenciones de Desarrollo (Importante)
- **Ejecución Local**: Es posible que no haya binarios de `go` ni `docker` en el host (como ya se ha verificado). De presentarse un error al ejecutar validaciones (por ejemplo, `command not found: docker` o `command not found: go`), notifica al usuario que delegarás la prueba a su infraestructura o a él mismo.
- **Compilación Multi-Arquitectura**: Este proyecto da soporte completo a `ARM` (Apple Silicon) e `Intel` (x86). Cuando se creen o modifiquen flujos de release, SIEMPRE usar los targets multi-arquitectura como están fijados en el archivo `Makefile` (`make build-multiarch`).
- **Control de Versiones Estricto (aumento-version.md)**: CADA VEZ que se solicita compilar o construir una nueva imagen de Docker del proyecto, es obligatorio e innegociable *Aumentar en una cifra el valor del fichero VERSION*. Este valor es embebido físicamente en el binario compilado de Go mediante las directivas del compilador (`-ldflags "-X main.Version=..."`) y debe corresponderse sistemáticamente en el "TAG" de las imágenes Docker (p. ej., `v7.4.0` -> `v7.4.1`). Usa siempre que puedas el comando `make bump-version`.
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

## Mejores Prácticas de API (OpenAPI)
Para el diseño y mantenimiento de APIs y sus descripciones OpenAPI (OAD):
- **Enfoque Design-First**: Diseña la descripción de la API (OAD) antes de implementar el código. Esto asegura que se respeten las capacidades de OpenAPI y facilita el uso de herramientas automatizadas.
- **Fuente Única de Verdad**: Evita la duplicación. Si la descripción se genera desde el código, asegura que ambos estén sincronizados mediante CI. Una vez modificado un archivo manualmente, este se convierte en la nueva "verdad".
- **Control de Versiones**: Los archivos OAD son código de primera clase. Deben estar en el repositorio y participar en los flujos de integración continua (CI).
- **Accesibilidad**: Haz que la descripción de la API esté disponible para los usuarios (p. ej. para generar sus propios clientes).
- **Uso de Herramientas**: No escribas YAML/JSON a mano en proyectos grandes. Usa editores específicos, DSLs o anotaciones de código según convenga.
- **Organización y DRY**:
    - Usa `$ref` para reutilizar componentes y evitar redundancias.
    - Divide descripciones grandes en varios documentos siguiendo la jerarquía de URLs.
    - Utiliza `tags` (etiquetas) para organizar las operaciones lógicamente.

