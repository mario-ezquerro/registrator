# Registrator

Service registry bridge for Docker.

![GitHub stars](https://img.shields.io/github/stars/mario-ezquerro/registrator.svg?label=github%20stars&logo=github)
[![Docker Hub](https://img.shields.io/badge/docker-ready-blue.svg)](https://registry.hub.docker.com/u/mario-ezquerro/registrator/)
[![External docs](https://img.shields.io/badge/docs-external--registrator-blue)]([https://url](https://mario-ezquerro.github.io/registrator/))
[![LICENSE](https://img.shields.io/github/license/mario-ezquerro/registrator.svg)](https://github.com/mario-ezquerro/registrator/blob/master/LICENSE)
[![Docker pulls](https://img.shields.io/docker/pulls/marioezquerro/registrator)](https://hub.docker.com/r/marioezquerro/registrator/)
<br /><br />

Registrator automatically registers and deregisters services for any Docker
container by inspecting containers as they come online. Registrator
supports pluggable service registries, which currently includes
[Consul](http://www.consul.io/), [etcd](https://github.com/coreos/etcd) and
[SkyDNS 2](https://github.com/skynetservices/skydns/).

Full documentation available at http://mario-ezquerro.com/registrator

## Getting Registrator

Get the latest release, master, or any version of Registrator via [Docker Hub](https://registry.hub.docker.com/u/mario-ezquerro/registrator/):

	$ docker pull mario-ezquerro/registrator:latest

Latest tag always points to the latest release. There is also a `:master` tag
and version tags to pin to specific releases.

## Using Registrator

The quickest way to see Registrator in action is our
[Quickstart](https://mario-ezquerro.com/registrator/latest/user/quickstart)
tutorial. Otherwise, jump to the [Run
Reference](https://mario-ezquerro.com/registrator/latest/user/run) in the User
Guide. Typically, running Registrator looks like this:

    $ docker run -d \
        --name=registrator \
        --net=host \
        --volume=/var/run/docker.sock:/tmp/docker.sock \
        mario-ezquerro/registrator:latest \
          consul://localhost:8500

## CLI Options
```
Usage of /bin/registrator:
  /bin/registrator [options] <registry URI>

  -cleanup=false: Remove dangling services
  -deregister="always": Deregister exited services "always" or "on-success"
  -explicit=false: Only register containers which have SERVICE_NAME label set
  -internal=false: Use internal ports instead of published ones
  -ip="": IP for ports mapped to the host
  -resync=0: Frequency with which services are resynchronized
  -retry-attempts=0: Max retry attempts to establish a connection with the backend. Use -1 for infinite retries
  -retry-interval=2000: Interval (in millisecond) between retry-attempts.
  -tags="": Append tags for all registered services (supports Go template)
  -ttl=0: TTL for services (default is no expiry)
  -ttl-refresh=0: Frequency with which service TTLs are refreshed
```

## Contributing

Pull requests are welcome! We recommend getting feedback before starting by
opening a [GitHub issue](https://github.com/mario-ezquerro/registrator/issues) or
discussing in [Slack](http://glider-slackin.herokuapp.com/).

Also check out our Developer Guide on [Contributing
Backends](https://mario-ezquerro.com/registrator/latest/dev/backends) and [Staging
Releases](https://mario-ezquerro.com/registrator/latest/dev/releases).

## Sponsors and Thanks

Big thanks to Weave for sponsoring, Michael Crosby for
[skydock](https://github.com/crosbymichael/skydock), and the Consul mailing list
for inspiration.

For a full list of sponsors, see
[SPONSORS](https://github.com/mario-ezquerro/registrator/blob/master/SPONSORS).

## License

MIT

<img src="https://ga-beacon.appspot.com/UA-58928488-2/registrator/readme?pixel" />
