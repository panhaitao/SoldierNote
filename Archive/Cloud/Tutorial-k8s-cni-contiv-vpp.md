# Ucloud 云主机上自建k8s集群-设置contiv/vpp网络插件

## 概述

1. 主机配置多网卡
2. 关闭kubelet HugePages 特性
3. 获取setup-node.sh 脚本辅助初始化节点网卡, 加载uio模块,拉取contiv/vp镜像
4. 获取contiv/vpp yaml
5. 配置节点vpp-node


### 主机配置多网卡

### 关闭kubelet HugePages 特性

```
/lib/systemd/system/kubelet.service  

[Service]
Environment="KUBELET_EXTRA_ARGS=--feature-gates HugePages=false"

systemctl daemon-reload
systemctl restart kubelet 
```

### 初始化节点网卡

wget -k https://raw.githubusercontent.com/contiv/vpp/master/k8s/setup-node.sh

### 部署contiv/vpp

### 配置节点vpp-node

```
cat > NodeConfig-CRD.yaml << EOF
apiVersion: nodeconfig.contiv.vpp/v1
kind: NodeConfig
metadata:
  name: k8s-master
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
```

kubectl apply -f NodeConfig-CRD.yaml

## 安装vpp 用于本地调试

cat > /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Extra Packages for Enterprise Linux 7 - $basearch
baseurl=https://mirrors.tuna.tsinghua.edu.cn/epel/7/x86_64/
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7

[fdio_release]
name=fdio_release
baseurl=https://packagecloud.io/fdio/release/el/7/$basearch
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/fdio/release/gpgkey
sslverify=0
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
EOF

systemctl restart kubelet
#yum install lshw vppl vpp-plugins

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
