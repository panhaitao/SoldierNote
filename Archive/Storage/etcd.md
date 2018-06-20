# etcd 部署与运维 
  
## 简介


etcd是一个分布式可靠的键值存储，用于存储分布式系统的关键数据。主要特性如下：

- 基于HTTP+JSON的API
- 选SSL客户认证机制
- 使用Raft算法充分实现了分布式。
- 高效的读写性能

在分布式系统中数据分为控制数据和应用数据。etcd的默认使用场景是用来处理控制数据，也可以处理应用数据，一般只推荐数据量很小，但是更新访问频繁的情况。典型应用场景有如下几类：

- 服务发现（Service Discovery）
- 消息发布与订阅
- 负载均衡
- 分布式通知与协调
- 分布式锁、分布式队列
- 集群监控与Leader竞选

## etcd 工作原理

使用Raft协议来维护集群内各个节点状态的一致性。简单说，ETCD集群是一个分布式系统，由多个节点相互通信构成整体对外服务，每个节点都存储了完整的数据，并且通过Raft协议保证每个节点维护的数据是一致的。

## etcd 的安装部署

* 下载地址 https://github.com/coreos/etcd/releases/download/v3.2.6/etcd-v3.2.6-linux-amd64.tar.gz

 

### 单机模式

./etcd  --data-dir ./data.etcd/  --listen-client-urls http://yourip:2379 --advertise-client-urls http://yourip:2379 & >./log/etcd.log

* --listen-client-urls    用于指定etcd和客户端的连接端口
* --advertise-client-urls 用于指定etcd服务器之间通讯的端口

### 集群模式


192.168.108.128 节点1
192.168.108.129 节点2
192.168.108.130 节点3


ETCD安装配置解压安装：
$ tar -zxvf  etcd-v3.2.6-linux-amd64.tar.gz -C /opt/

$ cd /opt

$ mv etcd-v3.2.6-linux-amd64  etcd-v3.2.6

$ mkdir /etc/etcd           # 创建etcd配置文件目录

创建etcd配置文件：
$ vi /etc/etcd/conf.yml

节点1，添加如下内容：

[plain] view plain copy
name: etcd-1  
data-dir: /opt/etcd-v3.2.6/data  
listen-client-urls: http://192.168.108.128:2379,http://127.0.0.1:2379  
advertise-client-urls: http://192.168.108.128:2379,http://127.0.0.1:2379  
listen-peer-urls: http://192.168.108.128:2380  
initial-advertise-peer-urls: http://192.168.108.128:2380  
initial-cluster: etcd-1=http://192.168.108.128:2380,etcd-2=http://192.168.108.129:2380,etcd-3=http://192.168.108.130:2380  
initial-cluster-token: etcd-cluster-token  
initial-cluster-state: new  


节点2，添加如下内容：
[plain] view plain copy
name: etcd-2  
data-dir: /opt/etcd-v3.2.6/data  
listen-client-urls: http://192.168.108.129:2379,http://127.0.0.1:2379  
advertise-client-urls: http://192.168.108.129:2379,http://127.0.0.1:2379  
listen-peer-urls: http://192.168.108.129:2380  
initial-advertise-peer-urls: http://192.168.108.129:2380  
initial-cluster: etcd-1=http://192.168.108.128:2380,etcd-2=http://192.168.108.129:2380,etcd-3=http://192.168.108.130:2380  
initial-cluster-token: etcd-cluster-token  
initial-cluster-state: new  

节点3，添加如下内容：
[plain] view plain copy
name: etcd-3  
data-dir: /opt/etcd-v3.2.6/data  
listen-client-urls: http://192.168.108.130:2379,http://127.0.0.1:2379  
advertise-client-urls: http://192.168.108.130:2379,http://127.0.0.1:2379  
listen-peer-urls: http://192.168.108.130:2380  
initial-advertise-peer-urls: http://192.168.108.130:2380  
initial-cluster: etcd-1=http://192.168.108.128:2380,etcd-2=http://192.168.108.129:2380,etcd-3=http://192.168.108.130:2380  
initial-cluster-token: etcd-cluster-token  
initial-cluster-state: new  
更新etcd系统默认配置：
当前使用的是etcd v3版本，系统默认的是v2，通过下面命令修改配置。

$ vi /etc/profile

在末尾追加

export ETCDCTL_API=3

$ source /etc/profile



ETCD命令

$ cd  /opt/etcd-v3.2.6
创建etcd配置文件：
$ ./etcdctl version

etcdctl version: 3.2.6
API version: 3.2

启动命令：
$ ./etcd --config-file=/etc/etcd/conf.yml

查看集群成员信息：
$ ./etcdctl member list

2618ce5cd761aa8e: name=etcd-3 peerURLs=http://192.168.108.130:2380 clientURLs=http://127.0.0.1:2379,http://192.168.108.130:2379 isLeader=false
9c359d48a2f34938: name=etcd-1 peerURLs=http://192.168.108.128:2380 clientURLs=http://127.0.0.1:2379,http://192.168.108.128:2379 isLeader=false
f3c45714407d68f3: name=etcd-2 peerURLs=http://192.168.108.129:2380 clientURLs=http://127.0.0.1:2379,http://192.168.108.129:2379 isLeader=true

查看集群状态（Leader节点）：
$ ./etcdctl cluster-health

member 2618ce5cd761aa8e is healthy: got healthy result from http://127.0.0.1:2379
member 9c359d48a2f34938 is healthy: got healthy result from http://127.0.0.1:2379
member f3c45714407d68f3 is healthy: got healthy result from http://127.0.0.1:2379
cluster is healthy



ECTD读写操作


基于HTTP协议的API使用起来比较简单，这里主要通过etcdctl和curl两种方式来做简单介绍。

下面通过给message key设置Hello值示例：

$ ./etcdctl set /message Hello

Hello

$ curl -X PUT http://127.0.0.1:2379/v2/keys/message -d value="Hello"
{"action":"set","node":{"key":"/message","value":"Hello","modifiedIndex":4,"createdIndex":4}}



读取message的值：

$ ./etcdctl  get /message
Hello

$ curl http://127.0.0.1:2379/v2/keys/message
{"action":"get","node":{"key":"/message","value":"Hello","modifiedIndex":9,"createdIndex":9}}



删除message key：

$ ./etcdctl  rm  /message

$ curl -X DELETE http://127.0.0.1:2379/v2/keys/message
{"action":"delete","node":{"key":"/message","modifiedIndex":10,"createdIndex":9},"prevNode":{"key":"/message","value":"Hello","modifiedIndex":9,"createdIndex":9}}



说明：因为是集群，所以message在其中一个节点创建后，在集群中的任何节点都可以查询到。



配置ETCD为启动服务

编辑/usr/lib/systemd/system/etcd.service，添加下面内容：

[plain] view plain copy
[Unit]  
Description=Etcd Server  
After=network.target  
After=network-online.target  
Wants=network-online.target  
  
[Service]  
Type=notify  
WorkingDirectory=/opt/etcd-v3.2.6/  
# User=etcd  
ExecStart=/opt/etcd-v3.2.6/etcd --config-file=/etc/etcd/conf.yml  
Restart=on-failure  
LimitNOFILE=65536  
  
[Install]  
WantedBy=multi-user.target  

更新启动：
systemctl daemon-reload
systemctl enable etcd
systemctl start etcd
systemctl restart etcd

systemctl status etcd.service -l



参考文档


https://coreos.com/etcd/docs/latest/getting-started-with-etcd.html

### 二进制安装

以 3.2.10 版本为例，从社区网站 <https://github.com/coreos/etcd/releases>
获取压缩包etcd-v3.2.10-linux-amd64.tar.gz，解压后将 etcd和etcdctl
拷贝到系统/usr/bin
下即可完成软件包安装，在使用systemd的系统上，创建对应的服务配置
/usr/lib/systemd/system/etcd.service ，即可完成安装，参考如下：

    [Unit]
    Description=Etcd Server
    After=network.target
    After=network-online.target
    Wants=network-online.target

    [Service]
    Type=notify
    WorkingDirectory=/var/lib/etcd/
    EnvironmentFile=-/etc/etcd/etcd.conf
    #User=etcd
    # set GOMAXPROCS to number of processors
    ExecStart=/bin/bash -c "GOMAXPROCS=$(nproc) /usr/bin/etcd --name=\"${ETCD_NAME}\" --data-dir=\"${ETCD_DATA_DIR}\" --listen-client-urls=\"${ETCD_LISTEN_CLIENT_URLS}\""
    Restart=on-failure
    LimitNOFILE=65536

    [Install]
    WantedBy=multi-user.target

etcd的单机部署参考配置
----------------------

    ETCD_NAME=default
    ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
    ETCD_LISTEN_CLIENT_URLS="http://etcd_server:2379"
    ETCD_ADVERTISE_CLIENT_URLS="http://etcd_server:2379"

- ETCD参数说明

-   ETCD\_NAME 节点名称
-   ETCD\_DATA\_DIR
    指定节点的数据存储目录，这些数据包括节点ID，集群ID，集群初始化配置，Snapshot文件，若未指定—wal-dir，还会存储WAL文件；
-   ETCD\_LISTEN\_CLIENT\_URLS 对外提供服务的地址,客户端会连接到这里和
    etcd 交互
-   ETCD\_ADVERTISE\_CLIENT\_URLS 告知客户端url, 也就是服务的url

- 启动服务，确认运行状态

-   systemctl daemon-reload
-   systemctl start etcd.service
-   systemctl status etcd.service

- 使用 etcdctl 来验证服务运行状态
