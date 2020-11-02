# 使用Kubeadm部署k8s高可用集群

截止至最新的1.14版本,k8s自身依旧没有实现真正的api-server高可用机制，目前的集群方案大多还是采用第三方LB+多master节点实现高可用和api-server的负载均衡,本文以系统 debian 9.x  centos 7.x 为例，记录部署docker-18.09.6 + k8s-1.14 高可用集群的简要操作步骤

![K8S HA Cluster](https://d33wubrfki0l68.cloudfront.net/d1411cded83856552f37911eb4522d9887ca4e83/b94b2/images/kubeadm/kubeadm-ha-topology-stacked-etcd.svg)


## 高可用k8s集群部署简介 

使用kubeadm 1.9.6 部署高可用集群，需要完成如下步骤:

1. 准备一个高可用的LB(haproxy,nginx+,或者第三方云服务提供的负载均衡组件,有条件的可以使用F5硬件设备)
2. 准备3台配置不低于2核4G的主机，供etcd和k8s master节点使用
3. 准备N台配置不低于4核8G的主机，供k8s node节点使用
4. 设置所有节点，确保/sys/class/dmi/id/product_uuid唯一，hostname 唯一
5. 设置所有节点主机名可以解析，可以借助dns或者修改/etc/hosts完成 
5. 所有节点初始化系统配置，禁用交换分区，关闭selinux，关闭防火墙，开启端口转发等
6. 多有节点安装docker，kubeadm软件包
7. 解决翻墙问题，确保docker可以拉取相应镜像
8. 在master节点生成Etcd static Pod 配置,启动etcd集群
9. 生成k8s组件的证书，分发到所有master节点 
9. 执行kubeadm init 命令，完成集群初始化
10. 将nodes节点添加到k8s集群中
11. 选择一个cni网络插件，部署到k8s集群中

使用kubeadm 1.14.x 部署高可用集群，需要完成如下步骤:

1. 准备一个高可用的LB(haproxy,nginx+,或者第三方云服务提供的负载均衡组件,有条件的可以使用F5硬件设备)
2. 准备3台配置不低于2核4G的主机，供etcd和k8s master节点使用
3. 准备N台配置不低于4核8G的主机，供k8s node节点使用
4. 设置所有节点，确保/sys/class/dmi/id/product_uuid唯一，hostname 唯一
5. 设置所有节点主机名可以解析，可以借助dns或者修改/etc/hosts完成 
5. 所有节点初始化系统配置，禁用交换分区，关闭selinux，关闭防火墙，开启端口转发等
6. 多有节点安装docker，kubeadm软件包
7. 解决翻墙问题，确保docker可以拉取相应镜像
8. 在master1节点初始化配置
9. 将其他master节点加入集群中
10. 将其他nodes节点添加到k8s集群中:
11. 为所有node节点打上标
12. 选择一个cni网络插件，部署到k8s集群中

## 高可用k8s集群的详细部署步骤

### 准备计算资源，网络资源

创建一个高可用集群，至少需要准备一个LB,三个配置不低于2C4G的计算节点供master使用，根据实际需要创建三个或者更多的配置不低于4C8G的结算节点

 | 类型        | 数量    |  最低参考配置     |  备注                                  | 
 | --------    | -----:  | :---------------: | :------------------------------------: |
 | lb          | 1       |  1C1G             | 用于转发到三台master api server:6443   |
 | master      | 3       |  2C4G             | k8s master 节点　　　　　　　　　　　  |
 | node        | >=3     |  4C8G             | k8s node　节点　　    　　　　　　　　 |

###  初始化系统配置

- 禁用交换分区: 临时禁用执行命令 swapoff -a  彻底禁用删除 /etc/fstab swap 一行
- 禁用selinux : debian9.x 无需操作; centos7.x 执行命令, 临时禁用执行命令 setenforce  0 彻底禁用执行命令`sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config` 重启生效
- 禁用防火墙: debian 9.x 无需操作; centos 7.x 执行命令, systemctl stop firewalld; systemctl disable firewalld
- 开启端口转发: 修改 /etc/sysctl.conf 文件, 修改 net.ipv4.ip_forward=1 执行命令 sysctl --system 生效
- 配置内核参数: 修改 /etc/sysctl.d/k8s.conf 文件，修改 net.bridge.bridge-nf-call-ip6tables = 1 net.bridge.bridge-nf-call-iptables = 1 执行命令 sysctl --system 生效
- 更多准备工作检查参考: <https://kubernetes.io/docs/setup/independent/install-kubeadm/#check-required-ports>

###  安装软件包

* 安装docker软件包:<https://docs.docker.com/install/>
* 安装kubeadm软件包:<https://kubernetes.io/docs/setup/independent/install-kubeadm/>
* debian 9.x: 执行命令: `apt install docker-ce kubelet kubeadm kubectl -y`
* centos 7.x: 执行命令: `yum install docker-ce kubelet kubeadm kubectl -y`

###  初始化集群

1) 初始化第一个master1节点

执行命令`kubeadm config print init-defaults > kubeadm-init.yaml`　导出默认的参考配置,修改如下部分

* localAPIEndpoint.advertiseAddress: 172.26.84.150 -> Maste1_IP
* controlPlaneEndpoint: "172.26.84.149:6443" -> LB_IP
* imageRepository: 172.26.84.150:5000 -> 换为集群可用的镜像仓库地址   
* networking: podSubnet: "10.244.0.0/16" 定义为和 CNI 网络插件一致的网段

执行命令: `kubeadm init --config=kubeadm-config.yaml --experimental-upload-certs` 完成master1节点初始化,返回如下结果表示出初始化成功
```
...
Your Kubernetes control-plane has initialized successfully!
...
```

2) 将其他master节点加入集群中: 

执行从master1 节点获取的 `kubeadm token create --print-join-command` 命令返回结果 --experimental-control-plane --certificate-key `kubeadm init phase upload-certs --experimental-upload-certs 最后一行`

3) 将nodes节点添加到k8s集群中
执行从master节点获取的 `kubeadm token create --print-join-command` 命令

4) 初始化kubectl 配置

在所有master节点上执行如下命令，确保kubectl命令能够和apisever认证交互:
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

5) 为所有node节点打上标签

在任意一个master节点执行命令

```
kubectl label node --overwrite node1 node-role.kubernetes.io/node=
kubectl label node --overwrite node1 node-role.kubernetes.io/node=
...
kubectl label node --overwrite nodeN node-role.kubernetes.io/node=
```

6) 选择一个cni网络插件，部署到k8s集群中

在任意一个master节点执行命令：`kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/62e44c867a2846fefb68bd5f178daf4da3095ccb/Documentation/kube-flannel.yml`　返回结果如下：
```
podsecuritypolicy.extensions/psp.flannel.unprivileged created
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.extensions/kube-flannel-ds-amd64 created
...
```

### 检查集群运行状态

```
kubectl get cs                     #检查集群健康状态
kubectl get nodes                  #检查节点是否ready
kubectl get pods --all-namespaces  #检查所有pod是否运行正常
```

## 添加节点

对集群worker节点扩容需要完整如下操作：

1. 初始化系统配置，禁用交换分区，关闭selinux，关闭防火墙，开启端口转发等
2. 安装docker，kubeadm软件包
3. 在master节点获取添加节点的命令
4. 在node节点执行添加节点的命令

### 添加node节点详细操作步骤

1. 更新所有节点/etc/hosts 文件,添加所有节点主机名解析记录，并保持主机名唯一
2. node节点初始化配置同master操作
3. node节点安装软件包同master操作
4. 返回到master节点执行命令，`kubeadm token create --print-join-command` 记录类似如下的结果：
```
kubeadm join 194.168.1.15:6443 --token ninsl0.hgnutou2p9f9u8d4 --discovery-token-ca-cert-hash sha256:ba73076c46a143260ba876d09174f558deb1941794621591cbc104d63c50adaa
```
5. 在nodes节点执行上一步骤返回的命令
6. 为新增加node节点打标签: `kubectl label node --overwrite nodeN node-role.kubernetes.io/node=`
7. 返回master节点，执行命令: `kubectl get nodes` 确认新添加节点是否添加成功

## 排除故障操作参考

1. 清除iptables规则: `iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X`
2. 清除ipvs规则: `ipvsadm --clear`
3. 查看docker运行日志: `journalctl  -fu docker`
4. 查看kubelet运行日志: `journalctl  -fu kubelet`
5. 重置集群:`kubeadm reset`, 清空目录 /var/lib/etcd/ /var/lib/kubelet/ /etc/kubernetes/ 

## 参考

官方文档链接<https://kubernetes.io/docs/setup/independent/ha-topology/#stacked-etcd-topology>
