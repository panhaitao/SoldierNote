# Kubeadm Deployment HA cluster

##

k8s核心组件
前面介绍过，kudeadm的思路，是通过把k8s主要的组件容器化，来简化安装过程。这时候你可能就有一个疑问，这时候k8s集群还没起来，如何来部署pod？难道直接执行docker run？当然是没有那么low，其实在kubelet的运行规则中，有一种特殊的启动方法叫做“静态pod”（static pod），只要把pod定义的yaml文件放在指定目录下，当这个节点的kubelet启动时，就会自动启动yaml文件中定义的pod。从这个机制你也可以发现，为什么叫做static pod，因为这些pod是不能调度的，只能在这个节点上启动，并且pod的ip地址直接就是宿主机的地址。在k8s中，放这些预先定义yaml文件的位置是 `/etc/kubernetes/manifests`，我们来看一下:

$ ll
总用量 16
-rw-------. 1 root root 1999 1月 12 01:35 etcd.yaml
-rw-------. 1 root root 2674 1月 12 01:35 kube-apiserver.yaml
-rw-------. 1 root root 2547 1月 12 01:35 kube-controller-manager.yaml
-rw-------. 1 root root 1051 1月 12 01:35 kube-scheduler.yaml
以下四个就是k8s的核心组件了，以静态pod的方式运行在当前节点上

etc: k8s的数据库，所有的集群配置信息、密钥、证书等等都是放在这个里面，所以生产上面一般都会做集群，挂了不是开玩笑的
kube-apiserver: 提供了HTTP restful api接口的关键服务进程, 是kubernetes里所有资源的增删改查等操作的唯一入口, 也是集群的入口进程，所有其他的组件都是通过apiserver来操作kubernetes的各类资源
kube-controller-manager: 负责管理容器pod的生命周期, kubernetes 里的所有资源对象的自动化控制中心, 可以理解为资源对象的"大总管"
kube-scheduler: 负责pod在集群中的调度, 相当于公交公司的"调度室"

环境准备
安装组件：docker,kubelet,kubeadm（所有节点）
使⽤上述组件部署 etcd ⾼可⽤集群
部署 master
加⼊node
⽹络安装
验证
总结
机环境准备

系统环境
#操作系统版本（⾮必须，仅为此处案例）
$cat /etc/redhat-release
CentOS Linux release 7.2.1511 (Core)
#内核版本（⾮必须，仅为此处案例）
$uname -r
4.17.8-1.el7.elrepo.x86_64
#数据盘开启ftype（在每台节点上执⾏）
umount /data
mkfs.xfs -n ftype=1 -f /dev/vdb
#禁⽤swap
swapoff -a
sed -i "s#^/swapfile##/swapfile#g" /etc/fstab
mount -a
docker,kubelet,kubeadm 的安装（所有节点）

安装运⾏时（docker）

k8s1.13 版本根据官⽅建议，暂不采⽤最新的 18.09，这⾥我们采⽤18.06，安装时需指 定版本
来源：kubeadm now properly recognizes Docker 18.09.0 and newer, but still treats 18.06 as the default supported version.
安装脚本如下（在每台节点上执⾏）：
用 kubeadm 部署生产级 k8s 集群
安装 kubeadm,kubelet,kubectl

官⽅的 Google yum 源⽆法从国内服务器上直接下载，所以可先在其他渠道下载好，在上传到服务器上
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF
$ yum -y install --downloadonly --downloaddir=k8s kubelet-1.13.1 kubeadm-1.13.1
kubectl-1.13.1
$ ls k8s/
25cd948f63fea40e81e43fbe2e5b635227cc5bbda6d5e15d42ab52decf09a5ac-kubelet-1.13.1-
0.x86_64.rpm
53edc739a0e51a4c17794de26b13ee5df939bd3161b37f503fe2af8980b41a89-cri-tools-
1.12.0-0.x86_64.rpm
5af5ecd0bc46fca6c51cc23280f0c0b1522719c282e23a2b1c39b8e720195763-kubeadm-1.13.1-
0.x86_64.rpm
7855313ff2b42ebcf499bc195f51d56b8372abee1a19bbf15bb4165941c0229d-kubectl-1.13.1-
0.x86_64.rpm
fe33057ffe95bfae65e2f269e1b05e99308853176e24a4d027bc082b471a07c0-kubernetes-cni-
0.6.0-0.x86_64.rpm
socat-1.7.3.2-2.el7.x86_64.rpm
本地安装
# 禁⽤selinux
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config
# 本地安装
yum localinstall -y k8s/*.rpm
systemctl enable --now kubelet
⽹络修复，已知 centos7 会因 iptables 被绕过⽽将流量错误路由，因此需确保sysctl 配置中的 net.bridge.bridgenf-call-iptables 被设置为 1
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
