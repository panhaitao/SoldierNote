# 容器云方案部署文档

## 容器云概述

![虚拟机与容器](images/vm-and-container.png)

虚拟机和容器技术的实现了服务器计算环境的抽象和封装，可以作为服务器平台上的应用程序运行的软件实体。多台虚拟机和容器可以被部署在一台物理服务器上，或将多台服务器整合到较少数量的物理服务器上，但是容器技术不是为了完全取代传统虚拟机技术，两者有本质的区别：

* 虚拟机技术属于系统虚拟化，本质上就是在模拟一台真实的计算机资源，其中包括虚拟CPU,存储,以及各种虚拟硬件设备——这意味着它也拥有自己的完整访客操作系统;

* 容器技术则是应用虚拟化，使用沙箱机制虚拟出一个应用程序运行环境，每个运行的容器实例都能拥有自己独立的各种命名空间(亦即资源)包括: 进程, 文件系统, 网络, IPC , 主机名等;

虚拟机将整个操作系统运行在虚拟的硬件平台上, 进而提供完整的运行环境供应用程序运行,同时也需要消耗更过的宿主机硬件资源; 而Docker等容器化应用时使用的资源都是宿主机系统提供的,仅仅是在资源的使用上只是做了某种程度的隔离与限制.比起虚拟机,容器拥有更高的资源使用效率,实例规模更小、创建和迁移速度也更快.这意味相比于虚拟机,在相同的硬件设备当中,可以部署数量更多的容器实例，但是计算资源的隔离程度不如虚拟机，所以运行在同一台宿主机的实例更容易相互影响，甚至主机操作系统崩溃会直接影响运行在宿主机上的所有容器应用。

在实际生产场景中,需要面临众多跨主机的容器协同工作，需要支持各种类型的工作负载，并且要满足可靠性，扩展性，以及面临随着业务增长而要解决的性能问题,以及相关的网络、存储、集群，从容器到容器云的进化随之出现。 

构建一个容器云面临着众多的挑战，首先 Docker引擎的组网能力比较弱，在单一主机网络能提供较好的支持，但将Docker集群扩展到多台主机后，跨主机Docker容器之间的交互和网络的管理和维护将面临巨大的挑战，甚至难以为继，所幸很多公司都开发了各自的产品来解决这个问题，典型的如Calico, Flannel, Weave，包括docker1.9版本后提供的Docker Overlay Network支持，其核心思想就是在将不同主机上的容器连接到同一个虚拟网络，在这里我们选择了来自CoreOS的Flannel来作为集群网路解决方案。

在生产环境中，最终面向业务应用需要的容器数量庞大，容器应用间的依赖关系繁杂，如果完全依赖人工记录和配置这样的复杂的关联信息，并且要满足集群运行的部署，运行，监控，迁移，高可用等运维需求，实属力不从心，所以诞生了编排和部署的需求，能解决这类问题的工具有Swarm、Fleet、Kubernetes以及Mesos等，综合考虑从，最后悬着了来自Google的Kubernetes ---- 一个全径且全面的容器管理平台，具有弹性伸缩、垂直扩容、灰度升级、服务发现、服务编排、错误恢复及性能监测等功能，可以轻松满足众多业务应用的运行和维护。

容器云即以容器为资源分割和调度的基本单位，封装整个软件运行时环境，为开发者和系统管理员提供用于构建、发布和运行分布式应用的平台。最后用一张图示来概括整个容器的生态技术栈：

![容器生态技术栈](images/container-cloud.png)

## 部署规划

参考上文图示,以四台机器为例做规划，一台主机做master，其他三台主机做node节点，所有主机部署centos7, 按照角色为每台主机命名:

| IP          |  主机名   |
|-------------|-----------|
| 10.1.10.101 |  master   |
| 10.1.10.102 |  node1    |
| 10.1.10.103 |  node2    |
| 10.1.10.104 |  node3    |

每台主机需要做的配置是：

* 关闭防火墙，禁用SElinux
* 开启 base,extras 软件源,修改配置文件`/etc/yum.repos.d/CentOS-Base.repo`，完成如下修改：

```
[base]
name=CentOS-$releasever - Base - 163.com
baseurl=http://mirrors.163.com/centos/7.4.1708/os/x86_64/
gpgcheck=0
enabled=1

[extras]
name=CentOS-$releasever - Extras - 163.com
baseurl=http://mirrors.163.com/centos/7.4.1708/extras/x86_64/
gpgcheck=0
enabled=1
```

* 添加四台主机名的解析,可以修改/etc/hosts,添加如下配置:
```
10.1.10.101  master
10.1.10.102  node1
10.1.10.103  node2
10.1.10.104  node3
```
## docker集群部署与配置

首先要实现跨物理机的容器访问——是不同物理内的容器能够互相访问,四台机器，在master主机上部署etcd，三台机器安装flannel和docker。

|    主机     |    部署软件     |
|-------------|-----------------|
|   master    |      etcd       |
|   node1     | flannel、docker |
|   node2     | flannel、docker |
|   node3     | flannel、docker |

简单的说flannel做了三件事情：

1. 数据从源容器中发出后，经由所在主机的docker0虚拟网卡转发到flannel0虚拟网卡，这是个P2P的虚拟网卡，flanneld服务监听在网卡的另外一端。Flannel也是通过修改Node的路由表实现这个效果的。
2. 源主机的flanneld服务将原本的数据内容UDP封装后根据自己的路由表投递给目的节点的flanneld服务，数据到达以后被解包，然后直接进入目的节点的flannel0虚拟网卡，然后被转发到目的主机的docker0虚拟网卡，最后就像本机容器通信一样由docker0路由到达目标容器。
3. 使每个结点上的容器分配的地址不冲突。Flannel通过Etcd分配了每个节点可用的IP地址段后，再修改Docker的启动参数。“--bip=X.X.X.X/X”这个参数，它限制了所在节点容器获得的IP范围。

如上分所述，需要完成如下操作：

- 启动Etcd后台进程
- 在Etcd里添加Flannel的配置
- 启动Flanneld后台进程
- 配置Docker的启动参数
- 重启Docker后台进程

三个组件的启动顺序是: etcd->flanned->docker.

###  master主机的配置

1. 修改配置文件: /etc/etcd/etcd.conf, 参考修改如下(其中ip为master主机IP)：

```
ETCD_LISTEN_CLIENT_URLS="http://10.1.11.101:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://10.1.11.101:2379"
```

* ETCD_LISTEN_CLIENT_URLS 对外提供服务的地址,客户端会连接到这里和 etcd 交互
* ETCD_ADVERTISE_CLIENT_URLS 告知客户端url, 也就是服务的url

2. 重新启动etcd服务，确认运行状态:
```
systemctl restart etcd
```

3. 确认修改无误后，添加和flannel相关的初始设置:

```
etcdctl -C http://10.1.11.101:2379 set /flannel/network/config '{"Network": "192.168.0.0/16"}'
```

### node 主机的配置

1. 修改flannel配置 /etc/sysconfig/flanneld， 参考如下修改：
```
FLANNEL_ETCD_ENDPOINTS="http://master:2379"
FLANNEL_OPTIONS='-etcd-prefix="/flannel/network"'
```

2. 修改 /lib/systemd/system/docker.service 在 [Service] 段内添加一行配置，也是让docker读取flanneld提供给docker的网路参数，参考修改如下:
```
EnvironmentFile=-/run/flannel/docker.env
```

3. 按照顺序重启服务
```
systemctl daemon-reload
systemctl restart flanneld
systemctl restart docker
```

4. 其他node节点主机做同样操作,最后在所有节点各自运行一个docker容器实例，查看各个容器间网络是否互通，如果一切顺利，跨物理机的容器集群网络配置完成。


## k8s部署和配置

### K8s 的整体架构

### kubernetes的安全认证

### k8s-master的配置

### k8s-node的配置

### k8s操作和管理

