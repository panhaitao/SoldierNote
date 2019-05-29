# 使用Kubeadm部署k8s单master集群

以系统 debian 9.x  centos 7.x 为例，记录部署docker-18.09.6 + k8s-1.14 单master集群的简要操作步骤

## 单master节点的k8s集群 

使用kubeadm 部署单机集群，需要完成如下步骤:

1. 准备一台配置不低于2核4G的主机
2. 初始化系统配置，禁用交换分区，关闭selinux，关闭防火墙，开启端口转发等
3. 安装docker，kubeadm软件包
4. 解决翻墙问题，确保docker可以拉取相应镜像
5. 执行kubeadm init 命令，完成初始化
6. 选择一个cni网络插件，部署到k8s集群中
7. 去除master的污点标记，确保master可以调度pod 

## 单master 节点的详细部署步骤

###  初始化系统配置

1  禁用交换分区:
```
临时禁用执行命令`swapoff -a`
彻底禁用删除`/etc/fstab swap`一行
```
2  禁用selinux:
```
debian9.x 无需操作;
centos7.x 执行命令
  临时禁用执行命令 setenforce  0
  彻底禁用执行命令 sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config 重启生效
```
3  禁用防火墙:
```
debian 9.x 无需操作
centos 7.x 执行命令, systemctl stop firewalld; systemctl disable firewalld
```
4  配置内核参数: 
```
修改 /etc/sysctl.d/k8s.conf 文件，修改 net.bridge.bridge-nf-call-ip6tables = 1 net.bridge.bridge-nf-call-iptables = 1 执行命令 sysctl --system 生效
开启端口转发: 修改 /etc/sysctl.conf 文件, 修改 net.ipv4.ip_forward=1 执行命令 sysctl --system 生效
```

###  安装软件包

* 安装docker软件包:<https://docs.docker.com/install/>
* 安装kubeadm软件包:<https://kubernetes.io/docs/setup/independent/install-kubeadm/>
* debian 9.x: 执行命令: `apt install docker-ce kubelet kubeadm kubectl -y`
* centos 7.x: 执行命令: `yum install docker-ce kubelet kubeadm kubectl -y`

###  初始化集群

执行命令 `kubeadm init --pod-network-cidr=10.244.0.0/16` 完成k8s集群初始化,返回如下结果表示出初始化成功

```
Your Kubernetes control-plane has initialized successfully!
```

在master节点执行上面返回结果如下部分，确保kubectl命令能够和apisever认证交互:

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

执行以上操作后，检查pod运行状态, 执行命令，kubectl get pods --all-namespaces 返回结果如下： 
```
NAMESPACE     NAME                              READY   STATUS    RESTARTS   AGE
kube-system   coredns-fb8b8dccf-dkmmn           0/1     Pending   0          3m14s
kube-system   coredns-fb8b8dccf-p5vqs           0/1     Pending   0          3m14s
kube-system   etcd-master1                      1/1     Running   0          2m23s
kube-system   kube-apiserver-master1            1/1     Running   0          2m11s
kube-system   kube-controller-manager-master1   1/1     Running   0          2m7s
kube-system   kube-proxy-4hq4z                  1/1     Running   0          3m14s
kube-system   kube-scheduler-master1            1/1     Running   0          2m34s
```
其中，除了coredns没有运行外，其他组件都为running状态为正常，此时容器网络未就绪，需要部署网络插件

### 部署网络插件

执行命令：`kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/62e44c867a2846fefb68bd5f178daf4da3095ccb/Documentation/kube-flannel.yml`　返回结果如下：
```
podsecuritypolicy.extensions/psp.flannel.unprivileged created
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.extensions/kube-flannel-ds-amd64 created
...
```

* 执行命令，kubectl get pods --all-namespaces 会发现新增pod: kube-flannel-ds-amd64-xxxx ,　coredns 也会变成 running 状态
* 执行命令，kubectl get nodes 返回结果如下，master 节点变成Ready状态
```
NAME      STATUS   ROLES    AGE   VERSION
master1   Ready    master   12m   v1.14.2
```

### 去除master污点

Master 节点不参与工作负载，默认只运行一些管理必须的pod, 需要执行命令,解除限制：

```
kubectl taint nodes --all node-role.kubernetes.io/master-
```

### 检查master

```
kubectl get cs                     #检查集群健康状态
kubectl get nodes                  #检查节点是否ready
kubectl get pods --all-namespaces  #检查所有pod是否运行正常
```

## 添加节点

对master节点进行扩容worker节点需要完成如下操作：

1. 初始化系统配置，禁用交换分区，关闭selinux，关闭防火墙，开启端口转发等
2. 安装docker，kubeadm软件包
3. 在master节点获取添加节点的命令
4. 在node 节点执行添加节点的命令

### 添加node节点详细操作步骤

1. 更新所有节点/etc/hosts 文件,添加所有节点主机名解析记录，并保持主机名唯一
2. node节点初始化配置同master操作
3. node节点安装软件包同master操作
4. 返回到master节点执行命令，`kubeadm token create --print-join-command` 记录类似如下的结果：
> kubeadm join 194.168.1.15:6443 --token ninsl0.hgnutou2p9f9u8d4 --discovery-token-ca-cert-hash sha256:ba73076c46a143260ba876d09174f558deb1941794621591cbc104d63c50adaa
5. 在nodes节点执行上一步骤返回的命令
6. 返回master节点，执行命令: `kubectl get nodes` 确认新添加节点是否添加成功


## 排除故障操作和其他操作参考

1. 清除iptables规则: `iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X`
2. 清除ipvs规则: `ipvsadm --clear`
3. 查看docker运行日志: `journalctl  -fu docker`
4. 查看kubelet运行日志: `journalctl  -fu kubelet`
5. 重置集群:`kubeadm reset`, 清空目录 /var/lib/etcd/ /var/lib/kubelet/ /etc/kubernetes/ 
6. 禁止master部署pod `kubectl taint nodes <master-name> node-role.kubernetes.io/master=true:NoSchedule`

## 参考

- 单master集群官方参考文档: <https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/>
