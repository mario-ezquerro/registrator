package main

import (
	_ "github.com/mario-ezquerro/registrator/consul"
	_ "github.com/mario-ezquerro/registrator/consulkv"
	_ "github.com/mario-ezquerro/registrator/etcd"
	_ "github.com/mario-ezquerro/registrator/skydns2"
	_ "github.com/mario-ezquerro/registrator/zookeeper"
)
