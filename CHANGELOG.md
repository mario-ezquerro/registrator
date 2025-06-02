# Change Log
All notable changes to this project will be documented in this file.

## [v7.5.0](https://github.com/mario-ezquerro/registrator/compare/v7.4.0...v7.5.0) - YYYY-MM-DD
### Changed
- Upgraded Go version from 1.17 to 1.22 in `go.mod`.
- Changed Go module path from `github.com/gliderlabs/registrator` to `github.com/mario-ezquerro/registrator` and updated internal import paths.
- Updated `golang.org/x/sys` to a version compatible with Go 1.22 to resolve build issues.
- Refreshed various project dependencies by running `go mod tidy`.
- Updated Dockerfile base images:
    - Builder stage now uses `golang:1.22-alpine3.20`.
    - Final stage now uses `alpine:3.20`.

### Fixed
- Resolved `//go:linkname must refer to declared function or variable` errors during compilation on macOS by updating `golang.org/x/sys`.

---

## [v7.4.0]() - 2021-09-22
### Fixed
- Minor code styling changes

### Added
- Support Go template in -tags flag
    - Custom Go template functions:
        - `strSlice`
        - `sIndex`
        - `mIndex`
        - `toUpper`
        - `toLower`
        - `replace`
        - `join`
        - `split`
        - `splitIndex`
        - `matchFirstElement`
        - `matchAllElements`
        - `httpGet`
        - `jsonParse`
- Prebuilt Docker images available on [DockerHub](https://hub.docker.com/r/psyhomb/registrator/tags)

### Removed

### Changed
- [Migrated to Go modules for managing dependencies](https://go.dev/blog/migrating-to-go-modules)
- Upgraded Docker base images:
    - builder: `golang:1.9.4-alpine3.7` => `golang:1.17.1-alpine3.14`
    - runtime: `alpine:3.7` => `alpine:3.14`

## [v7] - 2016-03-05
### Fixed
- Providing a SERVICE_NAME for a container with multiple ports exposed would cause services to overwrite each other
- dd3ab2e Fix specific port names not overriding port suffix

### Added
- bridge.Ping - calls adapter.Ping
- Consul TCP Health Check
- Support for Consul unix sockets
- Basic Zookeper backend
- Support for Docker multi host networking
- Default to tcp for PortType if not provided
- Sync etcd cluster on service registration
- Support hostip for overlay network
- Cleanup dangling services
- Startup backend service connection retry

### Removed

### Changed
- Upgraded base image to alpine:3.2 and go 1.4
- bridge.New returns an error instead of calling log.Fatal
- bridge.New will not attempt to ping an adapter.
- Specifying a SERVICE_NAME for containers exposing multiple ports will now result in a named service per port. #194
- Etcd uses port 2379 instead of 4001 #340
- Setup Docker client from environment
- Use exit status to determine if container was killed

## [v6] - 2015-08-07
### Fixed
- Support for etcd v0 and v2
- Panic from invalid skydns2 URI.

### Added
- Basic zookeeper adapter
- Optional periodic resyncing of services from containers
- More error logging for registries
- Support for services on containers with `--net=host`
- Added `extensions.go` file for adding/disabling components
- Interpolate SERVICE_PORT and SERVICE_IP in SERVICE_X_CHECK_SCRIPT
- Ability to force IP for a service in Consul
- Implemented initial ping for every service registry
- Option to only deregister containers cleanly shutdown #113
- Added support for label metadata along with environment variables

### Removed

### Changed
- Overall refactoring and cleanup
- Decoupled registries into subpackages using extpoints
- Replaced check-http script with Consul's native HTTP checks


## [v5] - 2015-02-18
### Added
- Automated, PR-driven release process
- Development Dockerfile and make task
- CircleCI config with artifacts for every build
- `--version` flag to see version

### Changed
- Base container is now Alpine
- Built entirely in Docker
- Moved to mario-ezquerro organization
- New versioning scheme
- Release artifact now saved container image

### Removed
- Dropped unnecessary layers in Dockerfile
- Dropped Godeps for now


[unreleased]: https://github.com/mario-ezquerro/registrator/compare/v7.5.0...HEAD
[v7.4.0]: https://github.com/marioezquerro/registrator/compare/v7...v7.4.0 
[v7]: https://github.com/marioezquerro/registrator/compare/v6...v7 
[v6]: https://github.com/marioezquerro/registrator/compare/v5...v6 
[v5]: https://github.com/marioezquerro/registrator/compare/v0.4.0...v5
