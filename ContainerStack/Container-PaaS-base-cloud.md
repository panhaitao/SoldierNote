# 基于公有云的容器平台建设指南

# 基于公有云的容器平台总体概览图

![截屏2021-06-16 下午1.10.27.png](https://upload-images.jianshu.io/upload_images/5592768-722062d7c2f58272.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# 容器集群初始化

创建一个容器集群后，为了满足基本使用，方便管理，准备工作如下：
1. 配置动态存储卷,例如 NFS协议的StorageClass
2. 安装容器应用的管理工具,例如 Helm
3. 配置网关服务，例如nginx-ingress

## 配置动态存储卷

1. 如果集群内未创建StorageClass 配置，首先在ucloud 控制台创建UFS存储，选择 k8s集群所在的vpc 子网 创建UFS挂载点，StorageClass部署参考 https://github.com/panhaitao/k8s-app/tree/main/deploy-for-k8s/StorageClass-UFS 

2. 创建修改 deployment.yaml 配置中 挂载点ufs_server_ip 顺序执行如下命令:
```
git clone https://github.com/panhaitao/k8s-app.git
cd k8s-app/deploy-for-k8s/StorageClass-UFS/
kubectl  apply -f deployment.yaml
kubectl  apply -f rbac.yaml
kubectl  apply -f class.yaml
```

## 安装 Helm 包管理器

Helm 类似 Linux 操作系统中的包管理工具，如 CentOS 发行版中的的 yum，Debian发行版中的的 apt。Helm 让 Kubernetes 的用户可以像安装软件包一样，轻松查找、部署、升级或卸载各种容器软件包，推荐安装使用helm v3版本，登录k8s集群任意一台master，执行如下命令
```
wget https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz #或
wget https://mirrors.huaweicloud.com/helm/v3.5.2/helm-v3.5.2-linux-amd64.tar.gz 
tar -xf helm-v3.5.2-linux-amd64.tar.gz
mv linux-amd64/helm /usr/bin/
chmod 755 /usr/bin/helm
```
## 配置ingress网关服务

部署一个公网 LB 版的 nginx  ingress  
helm repo add ingress https://kubernetes.github.io/ingress-nginx
helm repo update

如果在国内拉取官方镜像失败，可以将ingress-nginx需要的镜像推送到自有镜像仓库，然后使用自有镜像仓库参考操作如下：

1. 将官方镜像上传的自有镜像仓库,需要上传的镜像列表:
```
k8s.gcr.io/ingress-nginx/controller:v0.45.0
docker.io/jettech/kube-webhook-certgen:v1.5.1
```
2. 创建  docker-registry类的secrets
```
kubectl create namespace ingress-nginx
kubectl delete secret your-registry-secret -n ingress-nginx
kubectl create secret docker-registry your-registry-secret \
--namespace=ingress-nginx                                  \
--docker-server=uhub.service.ucloud.cn/ucloud_pts          \
--docker-username=${USERNAME}                              \
--docker-password=${PASSWORD}
```
3. 使用自有仓库来部署ingress-nginx（以仓库地址: uhub.service.ucloud.cn/ucloud_pts为例）
```
kubectl create namespace ingress-nginx
cat > ingress-value.yaml << EOF
controller:
  nodeSelector:
    kubernetes.io/os: linux 
  tolerations:
  - effect: NoSchedule
    key: virtual-kubelet.io/provider
    operator: Equal
    value: ucloud
  
  image:
    repository: uhub.service.ucloud.cn/ucloud_pts/controller
    tag: "v0.45.0"
    digest: sha256:c892e4e39885a16324d38b213d0dd42f56d183e93836b28d051c5476b1418bc1
  name: controller
  ingressClass: nginx
  admissionWebhooks:
    patch:
      enabled: true
      image:
        repository: uhub.service.ucloud.cn/ucloud_pts/kube-webhook-certgen
  metrics:
    port: 10254
    enabled: true
    service:
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "10254"
      servicePort: 10254
      type: LoadBalancer
imagePullSecrets: 
  - name: your-registry-secret
EOF
helm upgrade --install ingress-nginx ingress/ingress-nginx -n ingress-nginx --values=ingress-value.yaml
```

## 部署一个内网 LB 版的 nginx  ingress

1. 获取 ingress-nginx chart包，修改为定制的ULB内网版本
```
kubectl create ns ingress-inner
kubectl create secret docker-registry your-registry-secret \
--namespace=ingress-inner                                  \
--docker-server=uhub.service.ucloud.cn/ucloud_pts          \
--docker-username=haitao.pan@ucloud.cn                     \
--docker-password='xxxxxxxxxxx'

helm repo add ingress https://kubernetes.github.io/ingress-nginx
helm repo update
helm fetch ingress/ingress-nginx
tar -xvpf ingress-nginx-3.24.0.tgz
```
修改 ingress-nginx/Chart.yaml
```
name: ingress-nginx-inner
```
修改 ingress-nginx/templates/controller-service.yaml
```
metadata:
  annotations:
    service.beta.kubernetes.io/ucloud-load-balancer-type: inner
 ```   

 2. 安装修改后的chart包
```
helm package ingress-nginx
cat > ingress-inner-value.yaml << EOF
imagePullSecrets:
  - name: your-registry-secret
controller:
  name: controller
  ingressClass: nginx-inner
  image:
    repository: uhub.service.ucloud.cn/ucloud_pts/ingress-nginx-controller
    tag: "v0.46.0"
    digest: sha256:be724c71b4ad5086a734b777a9478e44e68dea1bdd00fbed345a122fb141274b  
EOF
helm del ingress-inner -n ingress-inner
helm upgrade --install ingress-inner /root/ingress-nginx-inner-3.30.0.tgz -n ingress-inner --values=ingress-inner-value.yaml
```

# 总结

以上只是作为初始化容器集群的基本工作，扩展开来讨论，可能还要涉及一下几部分：
1. 如果涉及微服务，还需要部署一套微服务注册中心，API网关等基础组件
2. 如果涉及多集群管理，需要完整对接管理集群的配置，例如rancher agent
3. 日志监控，事件监控等监控数据上报组件
