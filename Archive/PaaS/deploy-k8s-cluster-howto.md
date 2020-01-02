# 用kubeadm部署一个k8s集群

## 源起

从早期的时候，k8s的部署是比较繁琐，到kubeadm等工具的完善，集群部署变成更加容易，同时也隐藏了很多细节，适当的了解如何使用kubeadm 工具一步步完成完成集群的部署，了解其中的细节，对于容器平台的维护者意义更大。

## 准备工作

1. 准备一个负载均衡，云厂商提供的LB/或者企业私有环境的F5/haproxy均可
2. 准备三台配置不低于机器2C4G的主机，用于运行k8s master
3. 准备N台配置不低于4C8G的主机，用于运行k8s node

## 配置LB 和启动一个私有docker仓库

配置 vip 转发到 Master1_IP:6443 ，Master2_IP:6443，Master3_IP:6443, 本文以haproxy为例创建一个简单的负载均衡

```
yum install haproxy -y
cat >> /etc/haproxy/haproxy.cfg <<EOF
listen tcp-6443
    bind 0.0.0.0:6443
    mode tcp
    balance roundrobin
    server      master1         master1_ip:6443         weight  100
    #server      master2         master2_ip:6443         weight  100
    #server      master3         master3_ip:6443         weight  100
EOF
systemctl enable haproxy && systemctl restart haproxy
systemctl stop firewalld.service && systemctl disable firewalld.service
```

初始化配置可以只添加一个master1_ip，等全部集群部署完毕，再去掉注释部分，重启haproxy服务即可。


## 初始化所有节点

设置主机名，更新/etc/hosts，具体操作略，初始化所有节点包含如下步骤：

1. 配置docker kubernetes 仓库
2. 安装docker，kubelet,kubeadm等软件包
3. 禁用交换分区
4. 加载ip_vs模块
5. 关闭防火墙
6. 开启端口转发
7. 关闭selinux

可以通过`yum list kubeadm --showduplicates` 这种方式来列出仓库中相关的软件版本，根据需要选择你要安装的版本 
更多细节参考：https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-required-ports

```
yum install yum-utils -y
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
cat > /etc/yum.repos.d/kubernetes.repo<<EOF
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
       http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
yum makecache
yum install docker-ce ipvsadm kubelet-1.15.6 kubeadm-1.15.6 kubectl-1.15.6 ipset -y
swapoff -a  && sed -i 's/.*swap.*/#&/' /etc/fstab
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
modprobe -- br_netfilter
EOF
sh  /etc/sysconfig/modules/ipvs.modules 
cat > /etc/sysctl.d/k8s.conf <<EOF
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system
systemctl restart docker && systemctl enable docker
systemctl stop firewalld.service && systemctl  disable firewalld.service
setenforce 0 && sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config 
systemctl enable kubelet.service
```

## 初始化master1

初始化k8s集群第一个master节点需要完成如下步骤：

1. 生成kubeadm-init.yaml 这里是一个关键步骤，我会对配置中的关键配置做简要说明:
  * kubernetesVersion    此处定义的版本和上一步安装的kubeadm，kubelet版本一致
  * imageRepository      此处定义了k8s组件的镜像仓库，私有环境部署可以指定自己的镜像仓库
  * controlPlaneEndpoint 此处定义了k8s_apiserver_vip, 部署一个高可用集群依赖这个配置
  * networking           此处定义了集群内部的dns域名，service子网，pod子网，注意合理划分，互相不要冲突也不要和主机网络冲突
  * apiServer.certSANs   此处是master和apiserver交互认证的配置,一定要和master主机名，master_ip一致 
2. 执行 kubeadm init 初始化第一个master节点，--upload-certs 不能遗漏，不然后续添加master只能手动拷贝master1的证书文件了
3. 配置本机的默认kubeconfig，确保kubectl命令能够和apisever认证交互  
4. 部署cni网络插件，这里以flannel为例，注意kube-flannel.yml内的子网定义要和kubeadm-init.yaml里定义的一致
```
  net-conf.json: |
    {
      "Network": "10.10.0.0/16",  #此处需要和kubeadm-init.yaml里定义的一致
      "Backend": {
        "Type": "vxlan"
      }
    }
```

更多参考 https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/，下面是一键部署脚本：

```
cat > kubeadm-init.yaml<<EOF
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: v1.15.6
imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers
controlPlaneEndpoint: "k8s_apiserver_vip:6443"
networking:
  dnsDomain: cluster.local
  serviceSubnet: 10.96.0.0/16
  podSubnet: 10.10.0.0/16
apiServer:
  timeoutForControlPlane: 4m0s
  certSANs:
  - <master-1_ip>
  - <master-2_ip>
  - <master-3_ip>
  - master-1
  - master-2
  - master-3
  - 127.0.0.1
  - localhost
EOF
kubeadm init --config=kubeadm-init.yaml --upload-certs  #参考 https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

修改文件中Network配置后，执行kubectl apply -f kube-flannel.yml

执行完毕后记录下 kubeadm 返回的信息，后续添加节点需要使用 

## 添加其他master节点

对master节点进行扩需要完成如下操作：

1. 初始化系统配置，禁用交换分区，重复执行 初始化所有节点一节 的步骤
2. 执行初始化master1一节最后记录的kubeadm join ... --control-plane 一行，如果遗忘，可以回到master1节点执行`kubeadm token create --print-join-command`返回的结果,加上`--control-plane`即可
3. 配置本机的默认kubeconfig，确保kubectl命令能够和apisever认证交互 

最后实际执行的结果类同如下(请根据实际结果)

```
kubeadm join 172.16.0.2:6443 --token nlaa8f.6oryd1alvspf6r7i --discovery-token-ca-cert-hash sha256:40bdab940b643a1e6958c39d44949dfb9cc6e610d26ea5172307112ecb64afdc --control-plane
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## 添加 其他node节点

对master节点进行扩需要完成如下操作：

1. 初始化系统配置，禁用交换分区，重复执行 初始化所有节点一节 的步骤
2. 执行初始化master1一节最后记录的kubeadm join ... a5172307112ecb64afdc 一行，如果遗忘，可以回到master1节点执行`kubeadm token create --print-join-command`返回的结果

最后实际执行的结果类同如下(请根据实际结果)

```
kubeadm join 172.16.0.2:6443 --token nlaa8f.6oryd1alvspf6r7i --discovery-token-ca-cert-hash sha256:40bdab940b643a1e6958c39d44949dfb9cc6e610d26ea5172307112ecb64afdc --control-plane
```

## 回到master节点为node节点打标签

* 替换实际的node_name

```
kubectl label node --overwrite <node_name> node-role.kubernetes.io/node=
```

## 检查集群运行状态

```
kubectl get cs
kubectl get nodes
kubectl get pods --all-namespaces
```

## 排除故障操作和其他操作参考

* 清除iptables规则: iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
* 清除ipvs规则: ipvsadm --clear
* 查看docker运行日志: journalctl -fu docker
* 查看kubelet运行日志: journalctl -fu kubelet
* 重置集群:kubeadm reset, 清空目录 /var/lib/etcd/ /var/lib/kubelet/ /etc/kubernetes/
* master去掉污点，允许调度其他pod: `kubectl taint nodes <master-name> node-role.kubernetes.io/master-`
* master加污点，禁止调度pod：`kubectl taint nodes <master-name> node-role.kubernetes.io/master=true:NoSchedule`
