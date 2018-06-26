# etcd 指南 
  
## 简介

etcd是一个分布式可靠的键值存储，用于存储分布式系统的关键数据。主要特性如下：

- 基于HTTP+JSON的API
- 可选SSL客户认证机制
- 使用Raft算法充分实现了分布式。
- 高效的读写性能

在分布式系统中数据分为控制数据和应用数据。etcd的默认使用场景是用来处理控制数据，也可以处理应用数据，一般只推荐数据量很小，但是更新访问频繁的情况。典型应用场景有如下几类：

- 服务发现（Service Discovery）
- 消息发布与订阅
- 负载均衡
- 分布式通知与协调
- 分布式锁、分布式队列
- 集群监控与Leader竞选

## 工作原理

使用Raft协议来维护集群内各个节点状态的一致性。简单说，ETCD集群是一个分布式系统，由多个节点相互通信构成整体对外服务，每个节点都存储了完整的数据，并且通过Raft协议保证每个节点维护的数据是一致的。

## etcd 的安装部署

- etcd 是go编写的程序，解压后执行运行即可
- 下载地址 https://github.com/coreos/etcd/releases/download/v3.2.6/etcd-v3.2.6-linux-amd64.tar.gz

## 单机模式

* 直接执行`etcd`命令就可以启动，会占用两个端口，2379,2380 通过etcdctl可以连接 etcd 服务

## 集群模式

* 角色分配：
<pre>
10.10.0.1 节点1
10.10.0.2 节点2
10.10.0.3 节点3
</pre>

### 节点1 操作
* 创建etcd配置文件：/etc/etcd/conf.yml，写入如下内容:
```
name: etcd-1  
data-dir: /data/etcd-1  
listen-client-urls: http://10.10.0.1:2379,http://127.0.0.1:2379  
advertise-client-urls: http://10.10.0.1:2379,http://127.0.0.1:2379  
listen-peer-urls: http://10.10.0.1:2380  
initial-advertise-peer-urls: http://10.10.0.1:2380  
initial-cluster: etcd-1=http://10.10.0.1:2380,etcd-2=http://10.10.0.2:2380,etcd-3=http://10.10.0.3:2380  
initial-cluster-token: etcd-cluster-token  
initial-cluster-state: new  
```
* 启动：`etcd --config-file /etc/etcd/conf.yml`

### 节点2 操作
* 创建etcd配置文件：/etc/etcd/conf.yml，写入如下内容：
```
name: etcd-2  
data-dir: /data/etcd-2  
listen-client-urls: http://10.10.0.2:2379,http://127.0.0.1:2379  
advertise-client-urls: http://10.10.0.2:2379,http://127.0.0.1:2379  
listen-peer-urls: http://10.10.0.2:2380  
initial-advertise-peer-urls: http://10.10.0.2:2380  
initial-cluster: etcd-1=http://10.10.0.1:2380,etcd-2=http://10.10.0.2:2380,etcd-3=http://10.10.0.3:2380  
initial-cluster-token: etcd-cluster-token  
initial-cluster-state: new  
```
* 启动： `etcd --config-file /etc/etcd/conf.yml`

### 节点3 操作

* 创建etcd配置文件：/etc/etcd/conf.yml，写入如下内容：
```
name: etcd-3  
data-dir: /data/etcd-3  
listen-client-urls: http://10.10.0.3:2379,http://127.0.0.1:2379  
advertise-client-urls: http://10.10.0.3:2379,http://127.0.0.1:2379  
listen-peer-urls: http://10.10.0.3:2380  
initial-advertise-peer-urls: http://10.10.0.3:2380  
initial-cluster: etcd-1=http://10.10.0.1:2380,etcd-2=http://10.10.0.2:2380,etcd-3=http://10.10.0.3:2380  
initial-cluster-token: etcd-cluster-token  
initial-cluster-state: new  
```
* 启动： `etcd --config-file /etc/etcd/conf.yml`

### Etcd API 版本设置

系统默认的是v2，当前使用的是etcd v3版本，可以通过下面命令修改配置。

1. 编辑 `/etc/profile` 在末尾追加`export ETCDCTL_API=3`
2. 执行命令 `source /etc/profile` 生效

## etcdctl 命令

* 检查版本: `etcdctl -version`
* 查看集群成员信息：`etcdctl member list`
* 查看集群状态（Leader节点）`etcdctl cluster-health`

**登录节点操作时候可以省略`--endpoints`参数，默认值是 http://127.0.0.1:2379;**
**如果集群外操作需要指定`--endpoints`参数，例如 `--endpoints=http://10.10.0.1:2379`**


## etcd api接口

etcd 在键的组织上采用了层次化的空间结构（类似于文件系统中目录的概念），用户指定的键可以为单独的名字，如 status，此时实际上放在根目录 / 下面，也可以为指定目录结构，如 /cluster1/node2/status，则将创建相应的目录结构。

数据库操作包含对键值和目录的 CRUD 完整生命周期的管理,采用标准的restful 接口，支持http 和 https两种协议。这里主要通过etcdctl和curl两种方式来做简单介绍。


**注：CRUD 即 Create, Read, Update, Delete，是符合 REST 风格的一套 API 操作.**

1. 给message 设置值
* 执行命令：`etcdctl set /message Hello` 返回结果：Hello
* 执行命令：`curl http://127.0.0.1:2379/v2/keys/message -XPUT -d value="Hello"` 返回结果:
{"action":"set","node":{"key":"/message","value":"Hello","modifiedIndex":4,"createdIndex":4}}

2. 读message的值：
* 执行命令：`etcdctl get /message` 返回结果：Hello
* 执行命令：`curl http://127.0.0.1:2379/v2/keys/message` 返回结果:
{"action":"get","node":{"key":"/message","value":"Hello","modifiedIndex":9,"createdIndex":9}}

3. 更新message的值：
* 执行命令：`etcdctl update /message Welcome` 返回结果：Welcome
* 执行命令：`curl http://127.0.0.1:2379/v2/keys/message -XPUT -d value=Welcome -d ttl= -d prevExist=true` 返回结果：
{"action":"update","node":{"key":"/message","value":"Welcome","modifiedIndex":55,"createdIndex":53},"prevNode":{"key":"/message","value":"Welcome","modifiedIndex":54,"createdIndex":53}}

4. 删除message key:
* 执行命令：`etcdctl  rm  /message` 返回结果：PrevNode.Value: Hello
* 执行命令：`curl http://127.0.0.1:2379/v2/keys/message -XDELETE` 返回结果：
{"action":"delete","node":{"key":"/message","modifiedIndex":17,"createdIndex":16},"prevNode":{"key":"/message","value":"Hello","modifiedIndex":16,"createdIndex":16}}


## 参考文档
- <https://coreos.com/etcd/docs/latest/>
- <https://coreos.com/etcd/docs/latest/clustering.html>
- <https://coreos.com/etcd/docs/latest/runtime-configuration.html>
- <https://coreos.com/etcd/docs/latest/admin_guide.html#disaster-recovery>
- 基本操作api: 
<https://github.com/coreos/etcd/blob/6acb3d67fbe131b3b2d5d010e00ec80182be4628/Documentation/v2/api.md>
- 集群配置api: 
<https://github.com/coreos/etcd/blob/6acb3d67fbe131b3b2d5d010e00ec80182be4628/Documentation/v2/members_api.md>
- 鉴权认证api:
<https://github.com/coreos/etcd/blob/6acb3d67fbe131b3b2d5d010e00ec80182be4628/Documentation/v2/auth_api.md>
- 配置项：<https://github.com/coreos/etcd/blob/master/Documentation/op-guide/configuration.md>
