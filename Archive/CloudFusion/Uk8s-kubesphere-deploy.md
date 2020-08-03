# Uk8s kubesphere 部署篇

## 容器镜像库-UHub

如果使用的基础镜像在公网拉去速度比较慢,使用UHub镜像仓库加速功能, 加速后的地址

uhub.service.ucloud.cn

镜像同步完毕后, 所有k8s集群节点需要

docker login uhub.service.ucloud.cn -u 用户名 -p "密码"

## kubesphere 3.0 离线部署镜像列表

```
library/haproxy:2.0.4
library/redis:5.0.5-alpine
osixia/openldap:1.3.0
jimmidyson/configmap-reload:v0.3.0
csiplugin/snapshot-controller:v2.0.1
mirrorgooglecontainers/defaultbackend-amd64:1.4
kubesphere/alertmanager:v0.21.0
kubesphere/kube-rbac-proxy:v0.4.1
kubesphere/kube-state-metrics:v1.9.6
kubesphere/kubectl:v1.0.0
kubesphere/kubefed:v0.3.0
kubesphere/node-exporter:ks-v0.18.1
kubesphere/notification-manager-operator:v0.1.0
kubesphere/notification-manager:v0.1.0
kubesphere/prometheus-config-reloader:v0.38.3
kubesphere/prometheus-operator:v0.38.3
kubesphere/prometheus:v2.19.3
kubespheredev/ks-apiserver:latest
kubespheredev/ks-console:latest
kubespheredev/ks-controller-manager:latest
kubespheredev/ks-installer:latest
kubespheredev/tower:latest
```

保存为images.list 然后使用下面的脚本上传镜像


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

多集群管理
clusterRole: host
clusterRole: member

部署主控集群

1. 创建UK8S 集群
2. 给启动一台master 绑定eip
3. 登陆UK8S 集群master 设置默认storage，执行命令： kubectl edit sc 添加 ` storageclass.kubernetes.io/is-default-class: "true" `
4. 修改 kubesphere-installer.yaml
image: uhub.service.ucloud.cn/kubespheredev/ks-installer:latest
5. 安装kubesphere: 修改 cluster-configuration.yaml
```
local_registry: myhub.com
clusterRole: none -> clusterRole: host
```
