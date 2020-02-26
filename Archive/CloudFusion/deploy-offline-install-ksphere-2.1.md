# 私有环境版本的kubesphere mini 版本

##  概述

本文以 CentOS 7.5 /Docker 19.03.5/ K8S v1.15.6 为例, 模拟一个私有环境，如何使用ks-installer部署KubeSphere mini 2.1 

## 准备工作

1. 部署好一个k8s集群（版本不大于1.15.x）
2. 安装好helm（版本不大于2.x）
2. 准备一个私有环境的 docker registry仓库
3. 在k8s集群配置好一个 storageclass
4. 准备部署kubesphere需要的全部镜像

更多使用ks-installer部署KubeSphere需要的准备工作细节参考 https://github.com/kubesphere/ks-installer

## 部署一个k8s集群

部署一个k8s集群，但这不是本文的重点，本文的重点是在一个私有的K8S集群如何部署kubesphere mini 版本，关于使用kubeadm部署集群可参考文档：https://kubesphere.com.cn/forum/d/554-kubeadm-k8s

## 准备一个docker registry仓库

如果是测试，可以选在一个和k8s集群网络互通的主机上启动一个registry，操作步骤如下：

```
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache
yum install docker-ce -y
systemctl restart docker && systemctl enable docker
mkdir -pv /data/
docker pull registry
docker run -d -p 5000:5000 --name=registry -v /data/:/var/lib/registry  docker.io/registry
```

所有节点 /etc/docker/daemon.json 配置文件加入如下示例配置:

```
    "insecure-registries": [
       "172.16.0.9:5000"
    ]
```
重启docker服务`systemctl restart docker`生效, 如果重启docker服务的主机运行着registry，需要手动registry`docker restart registry`

如果是生产，建议使用一个可靠的仓库，例如 harbor，或者商业解决方案的jfrog 之类的

## 在k8s集群配置好一个 storageclass

以腾讯云提供的cfs为例创建一个storageclass  https://cloud.tencent.com/developer/article/1419471 node节点需要安装nfs-utils包支持，具体的私有环境存储，请安装存储厂商提供的方案来创建相应的storageclass。

以下是基于腾讯云cfs创建的storageclass参考配置：
```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
  name: nfs
provisioner: k8s/nfs
```

其中补充`storageclass.kubernetes.io/is-default-class: "true"` 配置细节，设为默认

## 准备部署kubesphere需要的全部镜像

```
kubesphere/ks-installer:v2.1.0
kubesphere/ks-console:v2.1.0
kubesphere/ks-controller-manager:v2.1.0
kubesphere/ks-account:v2.1.0
kubesphere/ks-apiserver:v2.1.0
kubesphere/ks-apigateway:v2.1.0
kubesphere/kubectl:v1.0.0
kubesphere/log-sidecar-injector:1.0
osixia/openldap:1.3.0
redis:5.0.5-alpine
kubesphere/prometheus-operator:v0.27.1
kubesphere/kube-state-metrics:v1.5.2
kubesphere/node-exporter:ks-v0.16.0
quay.io/coreos/kube-rbac-proxy:v0.4.1
kubesphere/prometheus-config-reloader:v0.27.1
kubesphere/addon-resizer:1.8.4
kubesphere/prometheus:v2.5.0
docker/kube-compose-controller:v0.4.12
docker/kube-compose-api-server:v0.4.12
gcr.azk8s.cn/google_containers/metrics-server-amd64:v0.3.1
haproxy:2.0.4
busybox:1.28.4
mirrorgooglecontainers/defaultbackend-amd64:1.4
kubesphere/configmap-reload:v0.0.1
kubesphere/kube-rbac-proxy:v0.4.1
```
可是将上述文件保存为images.list，可以执行如下参考脚本
```
#!/bin/bash
for img in  `cat images.list`
do
  tar_name=`echo $img | tr '/' '-' | tr ':' '-'`
  docker save $img > ${tar_name}
  gzip ${tar_name}
done
```
最后将所有gizp包和images.list 拷贝到k8s集群中

## 配置 kubesphere-minimal.yaml

获取 ksinstaller 的 https://raw.githubusercontent.com/kubesphere/ks-installer/master/kubesphere-minimal.yaml 修改如下部分配置
```
---
apiVersion: v1
data:
  ks-config.yaml: |
    ---

    local_registry: registry_ip:5000   #添加私有仓库配置
...

    spec:
      serviceAccountName: ks-installer
      containers:
      - name: installer
        image: registry_ip:5000/kubesphere/ks-installer:v2.1.0    # 添加私有仓库地址
        imagePullPolicy: "IfNotPresent"                         # 将Always 修改为 IfNotPresent

```

## 将镜像上传到私有仓库

将上一步修改好的kubesphere-minimal.yaml 放置于上传的镜像文所在的目录，执行如下脚本：


```
#!/bin/bash
for f in `ls *.gz` ;do docker load -i $f ;done

pri_repo=$( cat kubesphere-minimal.yaml  | grep local_registry | awk '{print $2}' )

if [[ "$pri_repo" != "" ]];then

  for img in  `cat images.list`
  do
    case $img in
      *redis*|*busybox*|*haproxy*)
         docker tag $img ${pri_repo}/library/$img
         docker push ${pri_repo}/library/$img ;;
      *)
         docker tag $img ${pri_repo}/$img
         docker push ${pri_repo}/$img ;;
    esac
  done

fi
```
等待镜像上传完毕后，执行`kubectl apply -f kubesphere-minimal.yaml` 等待kubesphere-minimal 2.1版本部署完成，余下略！

## 部署中可能遇到的问题

### helm 问题

现象
```
helm list
Error: configmaps is forbidden: User "system:serviceaccount:kube-system:default" cannot list configmaps in the namespace "kube-system"
```

解决办法
```
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'      
helm init --service-account tiller --upgrade
```