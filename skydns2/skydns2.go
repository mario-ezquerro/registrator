package skydns2

import (
	"context"
	"log"
	"net/url"
	"time"

	"github.com/mario-ezquerro/registrator/bridge"
	clientv3 "go.etcd.io/etcd/client/v3"
)

func init() {
	bridge.Register(new(Factory), "skydns2")
}

type Factory struct{}

func (f *Factory) New(uri *url.URL) bridge.RegistryAdapter {
	config := clientv3.Config{
		Endpoints:   []string{"http://" + uri.Host},
		DialTimeout: 5 * time.Second,
	}

	client, err := clientv3.New(config)
	if err != nil {
		log.Fatal("skydns2: error conectando:", err)
	}

	return &Skydns2Adapter{client: client, path: uri.Path}
}

type Skydns2Adapter struct {
	client *clientv3.Client
	path   string
}

func (r *Skydns2Adapter) Ping() error {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
	defer cancel()

	_, err := r.client.Get(ctx, "health")
	return err
}

func (r *Skydns2Adapter) Register(service *bridge.Service) error {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
	defer cancel()

	path := r.path + "/" + service.Name

	_, err := r.client.Put(ctx, path, service.Origin.ContainerHostname)
	if err != nil {
		log.Println("skydns2: error al registrar servicio:", err)
	}
	return err
}

func (r *Skydns2Adapter) Deregister(service *bridge.Service) error {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
	defer cancel()

	path := r.path + "/" + service.Name

	_, err := r.client.Delete(ctx, path)
	if err != nil {
		log.Println("skydns2: error al eliminar servicio:", err)
	}
	return err
}

func (r *Skydns2Adapter) Refresh(service *bridge.Service) error {
	return r.Register(service)
}

func (r *Skydns2Adapter) Services() ([]*bridge.Service, error) {
	return []*bridge.Service{}, nil
}
