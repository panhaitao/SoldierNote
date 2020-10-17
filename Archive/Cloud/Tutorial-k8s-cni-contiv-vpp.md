# Ucloud 云主机上自建k8s集群-设置contiv/vpp网络插件

## 概述

1. 为每个节点配置辅助网卡, 用于运行contiv/vpp
2. 修改 k8s节点 HugePages 配置
3. 获取setup-node.sh 脚本辅助初始化节点网卡, 加载uio模块,拉取contiv/vp镜像
4. 获取contiv/vpp yaml
5. 配置节点vpp-node
6. 检查集群状态

### 主机配置多网卡


### 更改节点HugePages 

```
sysctl -w vm.nr_hugepages=512
echo "vm.nr_hugepages=512" >> /etc/sysctl.conf
service kubelet restart
```

### 初始化节点网卡

yum install lshw -y
wget -k https://raw.githubusercontent.com/contiv/vpp/master/k8s/setup-node.sh

### 部署contiv/vpp

安装Contiv-VPP 参考如下操作
wget https://raw.githubusercontent.com/contiv/vpp/master/k8s/contiv-vpp.yaml

根据部署集群的配置修改contiv-vpp.yam 详细配置参考: https://fdio-vpp.readthedocs.io/en/latest/usecases/contiv/NETWORKING.html
kubectl apply -f contiv-vpp.yaml

### 配置节点vpp-node

通过CRD定义每个节点上VPP Switch的IP, IP/网关就是辅助网卡对应的IP/网关
```
cat > NodeConfig-CRD.yaml << EOF
apiVersion: nodeconfig.contiv.vpp/v1
kind: NodeConfig
metadata:
  name: k8s-master1
spec:
  mainVPPInterface:
     interfaceName: "GigabitEthernet0/6/0"
     ip: "192.168.16.1/24"
  gateway: "192.168.16.100"
---
apiVersion: nodeconfig.contiv.vpp/v1
kind: NodeConfig
metadata:
  name: k8s-worker1
spec:
  mainVPPInterface:
     interfaceName: "GigabitEthernet0/6/0"
     ip: "192.168.16.2/24"
  gateway: "192.168.16.100"
EOF
---
apiVersion: nodeconfig.contiv.vpp/v1
kind: NodeConfig
metadata:
  name: k8s-worker2
spec:
  mainVPPInterface:
     interfaceName: "GigabitEthernet0/6/0"
     ip: "192.168.16.3/24"
  gateway: "192.168.16.100"
EOF
```

kubectl apply -f NodeConfig-CRD.yaml

## 检查集群状态

* `kubectl  get pods -A -o wide` 确认所有pod都是running,并且能分到ip,可以ping通
* `kubectl  get nodes` 所有节点状态都变成Ready 
```
[root@k8s-1 ~]# kubectl  get nodes
NAME          STATUS   ROLES    AGE   VERSION
k8s-1   Ready    master   86m   v1.18.8
k8s-2   Ready    master   85m   v1.18.8
k8s-3   Ready    master   83m   v1.18.8
```
* 根据实际需要进行更多验证

## 参考

* https://github.com/contiv/vpp/blob/master/docs/setup/MANUAL_INSTALL.md
* https://github.com/contiv/vpp/blob/master/docs/setup/MULTI_NIC_SETUP.md
* https://fd.io/docs/vpp/master/gettingstarted/installing/centos.html#vpp-latest-release


## 故障分析

```
  Warning  FailedScheduling  <unknown>  default-scheduler  0/5 nodes are available: 5 Insufficient hugepages-2Mi.
  Warning  FailedScheduling  <unknown>  default-scheduler  0/5 nodes are available: 5 Insufficient hugepages-2Mi.
[root@inventory-2 ~]# kubectl  describe pods contiv-vswitch-r5nz2 -n kube-system
```
