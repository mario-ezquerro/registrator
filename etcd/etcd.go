package etcd

import (
	"context"
	"log"
	"net"
	"net/url"
	"strconv"
	"time"

	"github.com/mario-ezquerro/registrator/bridge"
	clientv3 "go.etcd.io/etcd/client/v3"
)

func init() {
	bridge.Register(new(Factory), "etcd")
}

type Factory struct{}

func (f *Factory) New(uri *url.URL) bridge.RegistryAdapter {
	urls := []string{"http://127.0.0.1:2379"}
	if uri.Host != "" {
		urls = []string{"http://" + uri.Host}
	}

	config := clientv3.Config{
		Endpoints:   urls,
		DialTimeout: 5 * time.Second,
	}

	client, err := clientv3.New(config)
	if err != nil {
		log.Fatal("etcd: error conectando:", err)
	}

	return &EtcdAdapter{client: client, path: uri.Path}
}

type EtcdAdapter struct {
	client *clientv3.Client

	path string
}

func (r *EtcdAdapter) Ping() error {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
	defer cancel()

	_, err := r.client.Get(ctx, "health")
	return err
}

func (r *EtcdAdapter) Register(service *bridge.Service) error {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
	defer cancel()

	path := r.path + "/" + service.Name + "/" + service.ID
	port := strconv.Itoa(service.Port)
	addr := net.JoinHostPort(service.IP, port)

	_, err := r.client.Put(ctx, path, addr, clientv3.WithLease(clientv3.LeaseID(service.TTL)))
	if err != nil {
		log.Println("etcd: error al registrar servicio:", err)
	}
	return err
}

func (r *EtcdAdapter) Deregister(service *bridge.Service) error {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
	defer cancel()

	path := r.path + "/" + service.Name + "/" + service.ID

	_, err := r.client.Delete(ctx, path)
	if err != nil {
		log.Println("etcd: error al eliminar servicio:", err)
	}
	return err
}

func (r *EtcdAdapter) Refresh(service *bridge.Service) error {
	return r.Register(service)
}

func (r *EtcdAdapter) Services() ([]*bridge.Service, error) {
	return []*bridge.Service{}, nil
}

// Actualizar la estructura del cliente
type Client struct {
	client *clientv3.Client
}

// Actualizar el constructor
func NewClient(machines []string) (*Client, error) {
	cfg := clientv3.Config{
		Endpoints:   machines,
		DialTimeout: 5 * time.Second,
	}

	c, err := clientv3.New(cfg)
	if err != nil {
		return nil, err
	}

	return &Client{client: c}, nil
}

// Actualizar los métodos para usar el nuevo cliente
func (c *Client) Set(key, value string) error {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
	defer cancel()

	_, err := c.client.Put(ctx, key, value)
	return err
}

func (c *Client) Get(key string) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*5)
	defer cancel()

	resp, err := c.client.Get(ctx, key)
	if err != nil {
		return "", err
	}
	if len(resp.Kvs) == 0 {
		return "", nil
	}
	return string(resp.Kvs[0].Value), nil
}
