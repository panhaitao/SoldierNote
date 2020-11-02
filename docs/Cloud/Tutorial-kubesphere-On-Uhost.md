# Ucloud 云主机上部署kubesphere

## 概述

1. Ucloud 云主机上自建k8s集群
2. 建立kubesphere私有镜像仓库
3. 为k8s集群创建StorageClass
4. 使用ks-installer 完成部署
5. 创建多集群重复2，3，4 操作

## Ucloud 云主机上自建k8s集群

如果Uk8s集群不能满足用户对k8s节点，k8s版本，CNI网络插件有特定要求等，使用者可以选择在Ucloud 云主机上自建k8s集群，这样做的弊端是失去了开箱即用的Uk8s集群，增加了维护的工作量，也无法使用ucloud 原生提供的和公有云宿主机打通的容器网络，关于自建k8s集群可以参考: <https://github.com/panhaitao/SoldierNote/blob/master/Archive/Cloud/Uhost-custom-k8scluster.md>

## 建立kubesphere私有镜像仓库

之所以要搭建一个kubesphere私有镜像仓库，是因为kubesphere镜像部分在dockerhub中，国内拉取比较慢，新建的k8s集群只需要从这个私有的镜像仓库获取镜像，就可以实现新集群的快速部署，以后kubesphere有更新，只需维护好这个私有镜像仓库的同步，其他集群就可以快速更新了，具体搭建步骤参考:
<https://github.com/panhaitao/SoldierNote/blob/master/Archive/Cloud/Prep-kubesphere-registry.md>

创建好kubesphere私有镜像仓库,需要在自建的k8s集群所有节点完成如下操作:

1. 添加myhub.com解析记录,执行命令: echo "<registry_node_ip> myhub.com" >> /etc/hosts #registry_node_ip替换为实际IP
2. 将创建kubesphere私有镜像仓库时生成的domain.crt证书添加到系统,执行命令: cat domain.crt > /etc/pki/tls/certs/ca-bundle.crt
3. 重启docker服务生效，执行命令: systemctl restart docker
4. 仓库登陆认证，执行命令: docker login myhub.com -u user -p "password" 执行成功后认证信息会记录在 ~/.docker/config.json
5. 添加kubelet 认证，执行命令:

```
cp /root/.docker/config.json /var/lib/kubelet/
systemctl daemon-reload
systemctl restart kubelet
```

## 在k8s集群新建StorageClass

准备工作：

* 从ucloud控制台申请UFS，UFS与自建K8S集群必须处于同一VPC，否则网络无法互通
* 准备运行NFS-Client Provisioner 需要的镜像: quay.io/external_storage/nfs-client-provisioner:latest 
* 获取部署NFS-Client Provisioner 需要的yaml: https://github.com/panhaitao/nfs-client-provisioner-deploy
* 集群所有节点安装nfs-utils，执行命令: yum install -y nfs-utils

### 在集群中部署 NFS-Client Provisioner

#include "docs/Cloud/Case-UCloud-k8s-Storage-UFS.md"

## 部署管理集群(kubesphere-host)

1. 在创建好的K8S 集群，给一台 master 节点，绑定eip,设置外网防火墙，允许30880端口访问
2. 设置默认storage 登陆UK8S集群 其中一台master,执行命令：kubectl edit sc ufs-nfsv4-storage 在 annotations  添加` storageclass.kubernetes.io/is-default-class: "true" `
3. 获取 wget -k https://raw.githubusercontent.com/kubesphere/ks-installer/master/deploy/kubesphere-installer.yaml 
    * 修改 image: myhub.com/kubespheredev/ks-installer:latest
4.  获取 wget -k https://raw.githubusercontent.com/kubesphere/ks-installer/master/deploy/cluster-configuration.yaml
    * 添加 local_registry: myhub.com
    * 将 clusterRole: none 修改为 clusterRole: host
5. 部署kubesphere，执行命令: kubectl apply -f kubesphere-installer.yaml ; kubectl apply -f kubesphere-installer.yaml
6. 部署完毕host集群后，执行命令: kubectl -n kubesphere-system get cm kubesphere-config -o yaml | grep -v "apiVersion" | grep jwtSecret 记下返回的结果jwtSecret: "xxxxxxxxxxxxxxxxxxx" 后面配置member集群需要修改的参数

## 部署业务集群(kubesphere-member)

1. 准备好一个用于业务角色的K8S集群，为其中一台 master 节点，绑定eip,设置外网防火墙，允许30880端口访问
2. 设置默认storage 登陆UK8S集群 其中一台master,执行命令：kubectl edit sc ufs-nfsv4-storage 在 annotations  添加` storageclass.kubernetes.io/is-default-class: "true" `
3. 获取 wget -k https://raw.githubusercontent.com/kubesphere/ks-installer/master/deploy/kubesphere-installer.yaml 
    * 修改 image: myhub.com/kubespheredev/ks-installer:latest
4. 获取 wget -k https://raw.githubusercontent.com/kubesphere/ks-installer/master/deploy/cluster-configuration.yaml
    * 添加 local_registry: myhub.com
    * 修改 jwtSecret：写入部署完毕host集群后最后一步返回的结果 
    * 将 clusterRole: none 修改为 clusterRole: member
5. 部署kubesphere，执行命令: kubectl apply -f kubesphere-installer.yaml ; kubectl apply -f kubesphere-installer.yaml
6. 将member集群加入主控集群

## 登陆平台

1. 使用浏览器访问 http://主控集群_eip:30880 默认用户名 admin 密码 P@88w0rd
2. 平台管理 -> 集群管理 -> 添加集群 (完成自定义设置)-> 下一步 -> 默认-> 添加从member集群 master节点文件 /root/.kube/config 的内容
3. 添加其他member集群，重复以上操作

## 参考文档

* ks-installer仓库: https://github.com/kubesphere/ks-installer
* 多集群管理 https://github.com/kubesphere/community/tree/master/sig-multicluster/how-to-setup-multicluster-on-kubesphere#MemberCluster
