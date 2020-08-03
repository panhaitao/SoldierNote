# Uk8s kubesphere 部署篇

由于目前Uhub提供的镜像加速功能不够灵活，原本搭建一个简单http的registry，但是个人觉得添加docker配置项insecure-registries的方式不够优雅，长时间运行不够安全，还是花时间验证如何搭建https的registry 用于完成内网环境下kubespshre部署在Uk8s集群上。

## 部署过程概述

* 需要一台Ucloud云主机
* 安装docker  用于运行registry 
* httpd-tools 用于生成http auth文件
* 创建自签名证书,并添加到系统信息
* 启动registry
* 申请需要数量的Uk8s集群
* 集群节点主机添加配置

##  搭建registry

需要一台Ucloud云主机，绑定eip,最好使用云存储，方便扩容

### 安装docker  

```
CentOS8 install docker

dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf install docker-ce --nobest -y

CentOS7 install docker 
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce -y

dnf install httpd-tools -y
systemctl  restart docker && docker pull registry  &> /dev/null &
```

### 创建需要的目录:

```
mkdir -pv /data/certs/
mkdir -pv /data/auth/
mkdir -pv /data/docker/registry/
```

### 创建自签名证书

这里是使用自签名证书，创建证书过程如下:

```
cd /data/certs/
openssl genrsa 1024 > domain.key
chmod 400 domain.key
openssl req -new -x509 -nodes -sha1 -days 365 -key domain.key -out domain.crt

其中 Common Name (eg, your name or your server's hostname) []:myhub.com 要对应域名
```

### 创建认证

```
htpasswd -Bbn admin a4h3ljbn > /data/auth/htpasswd
```

### 启动registry

```
docker run -d      \
--name registry    \
-p 443:443         \
--restart=always   \
--privileged=true  \
-e "REGISTRY_HTTP_ADDR=0.0.0.0:443"                       \
-e "REGISTRY_AUTH=htpasswd"                               \
-e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm"          \
-e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd"           \
-e "REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt"      \
-e "REGISTRY_HTTP_TLS_KEY=/certs/domain.key"              \
-v /data/docker/registry:/var/lib/registry                \
-v /data/certs/:/certs                                    \
-v /data/auth:/auth                                       \
registry
```

启动registry后，registry节点还要完成如下配置

1. 设置默认storage，登陆UK8S 集群master 执行命令： kubectl edit sc 添加 ` storageclass.kubernetes.io/is-default-class: "true" `
2. 添加myhub.com解析记录,执行命令: ` echo  "10.10.184.169 myhub.com" >> /etc/hosts `
3. 将domain.crt分发到节点,执行命令: ` cat /data/certs/domain.crt  /etc/pki/tls/certs/ca-bundle.crt ` 
4. 重启docker服务生效执行命令: ` systemctl restart docker`
5. 仓库登陆认证，执行命令: ` docker login myhub.com -u user -p "password" ` 

### 同步 kubesphere 3.0 镜像

搭建好内网的registery后，在申请 Uk8s 集群的时候就不用每个节点都需要绑定EIP了，接下来将 kubesphere 3.0 镜像同步到registery中，同步操作如下：

登陆registry节点，将如下文件保存为images.list

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

1. 设置默认storage，登陆UK8S 集群master 执行命令： kubectl edit sc 添加 ` storageclass.kubernetes.io/is-default-class: "true" `
2. 添加myhub.com解析记录,执行命令: ` echo  "10.10.184.169 myhub.com" >> /etc/hosts `
3. 将domain.crt分发到节点,执行命令: ` cat /data/certs/domain.crt  /etc/pki/tls/certs/ca-bundle.crt ` 
4. 重启docker服务生效执行命令: ` systemctl restart docker`
5. 仓库登陆认证，执行命令: ` docker login myhub.com -u user -p "password" ` 执行成功后认证信息会记录在 ~/.docker/config.json
6. cp /root/.docker/config.json /var/lib/kubelet/
7. systemctl daemon-reload && systemctl restart kubelet"

## 部署主控集群

1. 创建UK8S 集群
2. 给启动一台master 绑定eip
3. 修改 kubesphere-installer.yaml
image: uhub.service.ucloud.cn/kubespheredev/ks-installer:latest
4. 安装kubesphere: 修改 cluster-configuration.yaml
```
local_registry: myhub.com
clusterRole: none -> clusterRole: host
```

## 多集群管理

clusterRole: host
clusterRole: member

