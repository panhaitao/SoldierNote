# 使用Kubeadm部署k8s

## 准备工作

1. 准备两台配置不低于2核4G的主机
2. 所有节点主机需要安装好docker, [参考文档](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
3. 所有节点主机配置kubeadm apt仓库,执行如下操作：

```
apt-get update && apt-get install -y apt-transport-https
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
apt-get update
```

## master 主机操作

1. master主机需要安装软件包 Kubeadm， kubelet，kubectl
```
apt-get install -y kubelet kubeadm kubectl
```

2. 初始化master 节点配置

kubeadm init 

可选参数　

--kubernetes-version=v1.12.1       　制定部署k8s版本特定版本
--feature-gates=CoreDNS=true 　　　　使用CoreDNS组件　　
--pod-networki-cidr=192.168.0.0/16　　指定pod网络范围　

执行kubeadm init命令会拉取的镜像位于google服务器上，如果是国内的服务器，需要解决翻墙访问的问题，否则会部署失败
执行成功后，会出现

如果部署成功你会看到如下显示：

```
......
Your Kubernetes master has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join 194.168.1.15:6443 --token ninsl0.hgnutou2p9f9u8d4 --discovery-token-ca-cert-hash sha256:ba73076c46a143260ba876d09174f558deb1941794621591cbc104d63c50adaa
```

按照以上提示信息配置kubectl ，并记下最后一行，后面配置node节点会用到

3. 部署网络插件

```
kubectl apply -f https://git.io/weave-kube-1.6

```

4. 部署完成网络插件后，检查 Pod 的状态

```
kubectl get pods -n kube-system
```




## node主机操作


1. node主机需要安装软件包 Kubeadm，kubelet  
2. 执行部署 Master 节点时生成的
```
kubeadm join 194.168.1.15:6443 --token ninsl0.hgnutou2p9f9u8d4 --discovery-token-ca-cert-hash sha256:ba73076c46a143260ba876d09174f558deb1941794621591cbc104d63c50adaa
```
3. 检查节点的运行状态

回到master节点主机，执行命令
```
kubectl get nodes
```


## 其他参考配置

1. 配置cgroup驱动类型

docker中有两种驱动类型：cgroupfs，systemd

查看docker使用的驱动类型：`docker info|grep -i cgroup`
修改/etc/systemd/system/kubelet.service.d/10-kubeadm.conf 配置文件中的是驱动类型与上一步执行结果对应
 
Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=systemd"  
Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=cgroupfs"

使配置生效
```
systemctl daemon-reload
systemctl restart kubelet
```

2. 永久禁用交换分区,打开/etc/fstab文件并找到包含swap文本行在开头注释掉

3. 禁用防火墙 `ufw disable`


## 参考
https://blog.sctux.com/2018/12/30/kubernetes-bootstrapping/
