# Uk8s kubesphere 部署篇

搭建好内网的registery后，在申请 Uk8s 集群的时候就不用每个节点都需要绑定EIP了，接下来将 kubesphere 3.0 镜像同步到registery中，同步操作如下：

将如下文件保存为images.list
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

## 初始化Uk8s节点配置 

在申请完毕Uk8s集群后，每个集群可以完成乳出初始化配置

1. 设置默认storage，登陆UK8S 集群master 执行命令： kubectl edit sc 添加 ` storageclass.kubernetes.io/is-default-class: "true" 
2. 


## 部署主控集群

1. 创建UK8S 集群
2. 给启动一台master 绑定eip
3. `
4. 修改 kubesphere-installer.yaml
image: uhub.service.ucloud.cn/kubespheredev/ks-installer:latest
5. 安装kubesphere: 修改 cluster-configuration.yaml
```
local_registry: myhub.com
clusterRole: none -> clusterRole: host
```

## 多集群管理

clusterRole: host
clusterRole: member

