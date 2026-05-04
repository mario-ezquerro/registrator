# Registrator

Service registry bridge for Docker.

[![CI/CD Pipeline](https://github.com/mario-ezquerro/registrator/actions/workflows/ci.yml/badge.svg)](https://github.com/mario-ezquerro/registrator/actions)
[![Go Version](https://img.shields.io/badge/Go-1.25-blue.svg?style=shield&logo=go)](https://go.dev/)
[![Docker pulls](https://img.shields.io/docker/pulls/marioezquerro/registrator.svg)](https://hub.docker.com/r/marioezquerro/registrator/)
[![GitHub release](https://img.shields.io/github/release/mario-ezquerro/registrator.svg)](https://github.com/mario-ezquerro/registrator/releases)
[![License](https://img.shields.io/github/license/mario-ezquerro/registrator.svg)](https://github.com/mario-ezquerro/registrator/blob/master/LICENSE)
[![Platforms](https://img.shields.io/badge/platform-linux%2Famd64%20%7C%20linux%2Farm64-lightgrey)](https://hub.docker.com/r/marioezquerro/registrator/tags)
<br /><br />

Registrator automatically registers and deregisters services for any Docker
container by inspecting containers as they come online. Registrator
supports pluggable service registries, which currently includes
[Consul](http://www.consul.io/), [etcd](https://github.com/coreos/etcd) and
[SkyDNS 2](https://github.com/skynetservices/skydns/).

Full documentation available at https://github.com/mario-ezquerro/registrator

## Getting Registrator

Get the latest release, master, or any version of Registrator via [Docker Hub](https://hub.docker.com/r/marioezquerro/registrator):

	$ docker pull marioezquerro/registrator:latest

Latest tag always points to the latest release. There is also a `:master` tag
and version tags to pin to specific releases.

## Using Registrator

The quickest way to see Registrator in action is our
[Quickstart](https://github.com/mario-ezquerro/registrator/blob/master/README.md)
tutorial. Otherwise, jump to the [Run
Reference](https://github.com/mario-ezquerro/registrator/blob/master/README.md) in the User
Guide. Typically, running Registrator looks like this:

    $ docker run -d \
        --rm \
        --name=consul-server \
        -p 8500:8500 \
        -p 8600:8600/udp \
        hashicorp/consul:latest \
        agent -server -ui -node=server-1 -bootstrap-expect=1 -client=0.0.0.0 -data-dir=/consul/data

Connect with a browser to http://localhost:8500 and then run the following command:

    $ docker run -d \
        --rm \
        --name=registrator \
        --net=host \
        --volume=/var/run/docker.sock:/tmp/docker.sock \
        marioezquerro/registrator:v7.4.5 \
          consul://localhost:8500

Confirm the registration in the browser at http://localhost:8500 and you should see the consul-server service registered.

## CLI Options
```
Usage of /bin/registrator:
  /bin/registrator [options] <registry URI>

  -cleanup=false: Remove dangling services
  -deregister="always": Deregister exited services "always" or "on-success"
  -explicit=false: Only register containers which have SERVICE_NAME label set
  -healthcheck-port=0: Port for the health check server (e.g. 8080). 0 disables it.
  -internal=false: Use internal ports instead of published ones
  -ip="": IP for ports mapped to the host
  -resync=0: Frequency with which services are resynchronized
  -retry-attempts=0: Max retry attempts to establish a connection with the backend. Use -1 for infinite retries
  -retry-interval=2000: Interval (in millisecond) between retry-attempts.
  -tags="": Append tags for all registered services (supports Go template)
  -ttl=0: TTL for services (default is no expiry)
  -ttl-refresh=0: Frequency with which service TTLs are refreshed
```

## Health Check (OpenTelemetry Compatible)

Registrator includes a built-in health check HTTP server that is compatible with standard probes and OpenTelemetry requirements (e.g. the `httpcheck` receiver).

To enable it, pass the `-healthcheck-port=<port>` flag. This will start an HTTP server on that port, exposing two endpoints (`/` and `/health`) that return HTTP 200 with a JSON status and metadata.

The response includes the status and internal metrics (CPU load and memory usage) useful for telemetry:
```json
{
  "status": "UP",
  "metrics": {
    "cpu_load_15m": "0.05",
    "cpu_load_1m": "0.00",
    "cpu_load_5m": "0.01",
    "cpus": 4,
    "goroutines": 12,
    "memory_alloc_bytes": 1423456,
    "memory_sys_bytes": 6234567
  }
}
```

Example configuration in `docker-compose.yml` to specify the port and frequency of the health check:
```yaml
version: '3.8'

services:
  consul:
    image: hashicorp/consul:latest
    command: agent -server -ui -node=server-1 -bootstrap-expect=1 -client=0.0.0.0
    ports:
      - "8500:8500"
      - "8600:8600/udp"

  registrator:
    image: marioezquerro/registrator:v7.4.23
    command: -healthcheck-port=8080 -retry-attempts -1 consul://consul:8500
    depends_on:
      - consul
    ports:
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock
    healthcheck:
      test: ["CMD-SHELL", "wget -q --spider http://127.0.0.1:8080/health || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 5s
```

## Contributing

Pull requests are welcome! We recommend getting feedback before starting by
opening a [GitHub issue](https://github.com/mario-ezquerro/registrator/issues).

Also check out our Developer Guide.

## Sponsors and Thanks

Big thanks to Weave for sponsoring, Michael Crosby for
[skydock](https://github.com/crosbymichael/skydock), and the Consul mailing list
for inspiration.

For a full list of sponsors, see
[SPONSORS](https://github.com/mario-ezquerro/registrator/blob/master/SPONSORS).

## License

MIT