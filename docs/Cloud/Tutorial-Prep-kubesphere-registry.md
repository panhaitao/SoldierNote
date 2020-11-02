# 搭建kubesphere私有镜像仓库

由于目前Uhub提供的镜像加速功能不够灵活，原本搭建一个简单http的registry，但是个人觉得添加docker配置项insecure-registries的方式不够优雅，长时间运行不够安全，还是花时间验证如何搭建https的registry 用于完成内网环境下kubespshre部署

## 概述

* 需要一个创建好的registry 或者harbor
* 同步 kubesphere 3.0 镜像

## 同步过程

搭建好内网的镜像仓库后，接下来将 kubesphere 3.0 镜像同步到镜像中，同步操作如下：

创建 images.list

```
csiplugin/snapshot-controller:v2.0.1
jimmidyson/configmap-reload:v0.3.0
kubesphere/alertmanager:v0.21.0
kubespheredev/ks-apiserver:latest
kubespheredev/ks-console:latest
kubespheredev/ks-controller-manager:latest
kubespheredev/ks-installer:latest
kubespheredev/tower:latest
kubesphere/ks-apiserver:v3.0.0
kubesphere/ks-console:v3.0.0
kubesphere/ks-controller-manager:v3.0.0
kubesphere/kubectl:v1.0.0
kubesphere/kubefed:v0.3.0
kubesphere/kube-rbac-proxy:v0.4.1
kubesphere/kube-state-metrics:v1.9.6
kubesphere/node-exporter:ks-v0.18.1
kubesphere/notification-manager-operator:v0.1.0
kubesphere/notification-manager:v0.1.0
kubesphere/prometheus-config-reloader:v0.38.3
kubesphere/prometheus-operator:v0.38.3
kubesphere/prometheus:v2.19.3
kubesphere/tower:v0.1.0
library/haproxy:2.0.4
library/redis:5.0.5-alpine
mirrorgooglecontainers/defaultbackend-amd64:1.4
osixia/openldap:1.3.0
prom/alertmanager:v0.21.0
prom/prometheus:v2.20.1
```

然后使用下面的脚本上传镜像

```
#!/bin/bash

for img in  `cat images.list`
do
  docker pull $img
done

pri_repo=myhub.com

if [[ "$pri_repo" != "" ]];then

  for img in  `cat images.list`
  do
         docker tag $img ${pri_repo}/$img
         docker push ${pri_repo}/$img
  done

fi
```
