# Tutorial: Ucloud 云主机上自建k8s集群

如果用户希望在在ucloud 云主机上自建k8s集群, 本文以如下组合为例:

* Ucloud快杰云主机: CentOS7.6
* Kernel:4.19.0-6
* k8s:v1.18.8
* docker:19.03.9
* flannel:v0.13.0-rc2

部署一个高可用集群，需要如下操作步骤:

1. 准备三台配置不低于机器2C4G的Ucloud云主机，用于运行k8s master
2. 准备N台配置不低于4C8G的Ucloud主机，用于运行k8s node
3. 使用UHub同步一份kubernetes镜像仓库
4. 创建一个负载均衡 ULB, 用作配置k8s apiserver 高可用VIP
5. 使用kubeadm工具完成k8s集群的部署

## 申请Ucloud云主机并完成初始化

申请云主机步骤略，设置主机名，更新/etc/hosts，具体操作略，初始化所有节点包含如下步骤：

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
cat > /etc/yum.repos.d/docker-ce.repo <<EOF
[docker]
name=docker-ce
baseurl=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/7/x86_64/stable/
enabled=1
gpgcheck=0
repo_gpgcheck=0
EOF
yum makecache
yum install docker-ce -y

cat > /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.tuna.tsinghua.edu.cn/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
repo_gpgcheck=0
EOF
yum makecache
yum install ipvsadm kubelet-1.18.8 kubeadm-1.18.8 kubectl-1.18.8 ipset -y

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

## 配置Uhub

登陆 https://console.ucloud.cn/  从全部产品中找到, 容器镜像库-UHub

1. 用户镜像-> 镜像库名称 -> 新建镜像仓库，比如起个名字k8srepo(Ucloud这个名字我已经占用了)
2. 在这个k8srepo仓库下配置镜像加速，分别添加如下加速规则
```
 - 源镜像 k8s.gcr.io/kube-apiserver:v1.18.8            目标镜像 k8srepo/kube-apiserver:v1.18.8
 - 源镜像 k8s.gcr.io/kube-controller-manager:v1.18.8   目标镜像 k8srepo/kube-controller-manager:v1.18.8 
 - 源镜像 k8s.gcr.io/kube-scheduler:v1.18.8            目标镜像 k8srepo/kube-scheduler:v1.18.8/ 
 - 源镜像 k8s.gcr.io/kube-proxy:v1.18.8                目标镜像 k8srepo/kube-proxy:v1.18.8 
 - 源镜像 k8s.gcr.io/pause:3.2                         目标镜像 k8srepo/pause:3.2 
 - 源镜像 k8s.gcr.io/etcd:3.4.3-0                      目标镜像 k8srepo/etcd:3.4.3-0 
 - 源镜像 k8s.gcr.io/coredns:1.6.7                     目标镜像 k8srepo/coredns:1.6.7 
 - 源镜像 quay.io/coreos/flannel:v0.13.0-rc2           目标镜像 k8srepo/flannel:v0.13.0-rc2
```

加速后的镜像仓库为 uhub.service.ucloud.cn/k8srepo 官方镜像列表地址可以从`kubeadm config images list`这里获得, 所有使用加速镜像仓库需要完成认证,登陆所有K8S节点
```
docker login -u <ucloud用户> -p "ucloud密码"  uhub.service.ucloud.cn/k8srepo
cp /root/.docker/config.json /var/lib/kubelet/
systemctl daemon-reload
systemctl restart kubelet
```

## 创建并配置ULB 

登陆 https://console.ucloud.cn/  

1. 从全部产品中找到, 云主机UHost -> 创建主机，具体可以参考ucloud文档
2. 从全部产品中找到, 负载均衡ULB -> 创建负载均衡
```
负载均衡类型: 请求代理型
网络模式: 内网 
所属VPC: 选择和新建的云主机一致的VPC
所属子网: 选择和新建的云主机一致的子网
其他按照提示操作即可 
```
3. 选择刚刚创建的负载均衡，配置vserver
```
vserver管理->添加vserver
VServer名称: 自定义
协议和端口 : TCP 6443
其他默认，点击确定
选择刚刚创建的VServer，服务节点->添加节点, 选择 master 1-3 对应的主机即可
```

## 初始化master1

初始化k8s集群第一个master节点需要完成如下步骤：

1. 创建 kubeadm-init.yaml 文件, 用于初始化k8s集群 
```
cat > kubeadm-init.yaml<<EOF
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: v1.18.8
imageRepository: uhub.service.ucloud.cn/k8srepo
controlPlaneEndpoint: "k8s_apiserver_vip:6443"
networking:
  dnsDomain: cluster.local
  serviceSubnet: 172.16.0.0/17
  podSubnet: 172.16.128.0/17
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
kubeadm init --config=kubeadm-init.yaml --upload-certs
```
执行完毕后记录下 kubeadm 返回的信息，后续添加节点需要使用 

其中包含--control-plane 这段是用于`添加master节点，示例如下： 
```
  kubeadm join 10.10.153.192:6443 --token yiqa9m.fv50gop0huu32fie \
    --discovery-token-ca-cert-hash sha256:c722e3d0a77e1995bb43d478a9dc40037705ae3814ffa175b558a90e9242b427 \
    --control-plane --certificate-key 7f512b9e7eca96dbda27c3769c948e9118097e5f29e6fe7c02492442371357cb
```

不包含--control-plane 这条命令是用于添加node节点，示例如下： 
```
kubeadm join 10.10.153.192:6443 --token yiqa9m.fv50gop0huu32fie \
    --discovery-token-ca-cert-hash sha256:c722e3d0a77e1995bb43d478a9dc40037705ae3814ffa175b558a90e9242b427
```
2. kubeadm-init.yaml 配置中的关键配置做简要说明:
  * kubernetesVersion    此处定义的版本和上一步安装的kubeadm，kubelet版本一致
  * imageRepository      此处定义了k8s组件的镜像仓库，私有环境部署可以指定自己的镜像仓库
  * controlPlaneEndpoint 此处定义了k8s_apiserver_vip, 部署一个高可用集群依赖这个配置
  * networking           此处定义了集群内部的dns域名，service子网，pod子网，注意合理划分，互相不要冲突也不要和主机网络冲突
  * apiServer.certSANs   此处是master和apiserver交互认证的配置,一定要和master主机名，master_ip一致 
3. 执行 kubeadm init 初始化第一个master节点，--upload-certs 不能遗漏，不然后续添加master只能手动拷贝master1的证书文件了
4. 配置本机的默认kubeconfig，确保kubectl命令能够和apisever认证交互  
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
5. 部署flanne cni网络插件
  * wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml 
  * 修改kube-flannel.yml内的子网定义要和kubeadm-init.yaml里定义的一致
```
  net-conf.json: |
    {
      "Network": "172.16.128.0/17",  #此处需要和kubeadm-init.yaml里定义的一致
      "Backend": {
        "Type": "vxlan"
      }
    }
```
  * 修改 image: quay.io/coreos/flannel:v0.13.0-rc2 为 image: uhub.service.ucloud.cn/k8srepo/flannel:v0.13.0-rc2 
6. 修改文件保存后，执行kubectl apply -f kube-flannel.yml

* 集群配置更多参考 https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/
* 其他网络插件参考 https://kubernetes.io/docs/concepts/cluster-administration/addons/

## 添加其他master节点

登陆其他master节点进行扩需要完成如下操作：

1. 执行初始化master1 kubeadm init 命令返回的添加master的命令，示例如下： 
```
  kubeadm join 10.10.153.192:6443 --token yiqa9m.fv50gop0huu32fie \
    --discovery-token-ca-cert-hash sha256:c722e3d0a77e1995bb43d478a9dc40037705ae3814ffa175b558a90e9242b427 \
    --control-plane --certificate-key 7f512b9e7eca96dbda27c3769c948e9118097e5f29e6fe7c02492442371357cb
```
2. 配置本机的默认kubeconfig，确保kubectl命令能够和apisever认证交互 
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## 添加 其他node节点

登陆其他node节点进行扩需要完成如下操作：

1. 执行初始化master1 kubeadm init 命令返回的添加node的命令，示例如下： 
```
kubeadm join 10.10.153.192:6443 --token yiqa9m.fv50gop0huu32fie \
    --discovery-token-ca-cert-hash sha256:c722e3d0a77e1995bb43d478a9dc40037705ae3814ffa175b558a90e9242b427
```

## 添加节点过程如果遗忘添加命令

* 可以回到master1节点执行`kubeadm token create --print-join-command`返回的结果
* 如果遗忘certificate-key 可以回到master-1节点执行命令 kubeadm init phase upload-certs --upload-certs 重置

## 回到master节点为node节点打标签

登陆任意一个master 更新其他集群节点的node_name,执行命令:

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
* master去掉污点，允许调度pod: `kubectl taint nodes <master-name> node-role.kubernetes.io/master-`
* master加污点，禁止调度pod：`kubectl taint nodes <master-name> node-role.kubernetes.io/master=true:NoSchedule`
* 如果想使用一台独立haproxy实例创建一个简单的负载均衡，可参考如下：
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
