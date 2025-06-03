package etcd

import (
	"context"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"net/url"
	"regexp"
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
	urls := make([]string, 0)
	if uri.Host != "" {
		urls = append(urls, "http://"+uri.Host)
	} else {
		urls = append(urls, "http://127.0.0.1:2379")
	}

	res, err := http.Get(urls[0] + "/version")
	if err != nil {
		log.Fatal("etcd: error retrieving version", err)
	}

	defer res.Body.Close()
	body, _ := ioutil.ReadAll(res.Body)

	if match, _ := regexp.Match("0\\.4\\.*", body); match == true {
		log.Println("etcd: using v0 client")
		return &EtcdAdapter{client: clientv3.NewClient(urls), path: uri.Path}
	}

	return &EtcdAdapter{client2: clientv3.NewClient(urls), path: uri.Path}
}

type EtcdAdapter struct {
	client  *clientv3.Client
	client2 *clientv3.Client

	path string
}

func (r *EtcdAdapter) Ping() error {
	r.syncEtcdCluster()

	var err error
	if r.client != nil {
		rr := clientv3.NewRequest("GET", "version", nil, nil)
		_, err = r.client.SendRequest(rr)
	} else {
		rr := clientv3.NewRequest("GET", "version", nil, nil)
		_, err = r.client2.SendRequest(rr)
	}

	if err != nil {
		return err
	}
	return nil
}

func (r *EtcdAdapter) syncEtcdCluster() {
	var result bool
	if r.client != nil {
		result = r.client.SyncCluster()
	} else {
		result = r.client2.SyncCluster()
	}

	if !result {
		log.Println("etcd: sync cluster was unsuccessful")
	}
}

func (r *EtcdAdapter) Register(service *bridge.Service) error {
	r.syncEtcdCluster()

	path := r.path + "/" + service.Name + "/" + service.ID
	port := strconv.Itoa(service.Port)
	addr := net.JoinHostPort(service.IP, port)

	var err error
	if r.client != nil {
		_, err = r.client.Set(path, addr, uint64(service.TTL))
	} else {
		_, err = r.client2.Set(path, addr, uint64(service.TTL))
	}

	if err != nil {
		log.Println("etcd: failed to register service:", err)
	}
	return err
}

func (r *EtcdAdapter) Deregister(service *bridge.Service) error {
	r.syncEtcdCluster()

	path := r.path + "/" + service.Name + "/" + service.ID

	var err error
	if r.client != nil {
		_, err = r.client.Delete(path, false)
	} else {
		_, err = r.client2.Delete(path, false)
	}

	if err != nil {
		log.Println("etcd: failed to deregister service:", err)
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
