# 多云容灾以及弹性扩容技术方案

# 方案背景

客户主要生产业务在阿里云，运行在阿里云侧业务应用, MySQL, Redis, MongoDB，现在需要将阿里云侧资源与部署在Ucloud云平台的资源组建多活容灾系统

## 客户资源现状

|  资源  |                部署形式                      |  实例数量  |  数据量   |  容灾策略  |
|-------|-------------------------------|------------|---------|-----------|
| 应用   | 大部分为普通应用,小部分容器 | 150台        |                | DNS负载均衡 |
| RDS   | MySQL 5.7 binlog默认开启       | 8主5从       | 2T          | PXC集群同步 |
| Redis | 主从版 4.0                                    | 5                 |4G           | 不做容灾处理 |
| MongoDB | MongoDB 4.0 副本集 | 1 | 50G | 单向同步容灾 |
| ES | 版本:6.8.6 数据节点4 | 1 | 300G左右 | 应用双写 |
| Oracle | 机器部署 Oracle 11G | 1 | 1T左右 | Rac方式同步 |

## 容灾方式

阿里云/ucloud 主从热备，默认阿里云主，ucloud从，故障后切换后，切换角色

## 容灾级别

基础设施容灾, Ucloud 支持多云组网能力，可以实现基础设施容灾，和提供数据库级容灾方案能力，对其他各个云厂商限制的应用可以实现定时备份的能力，

数据级容灾, 仅将生产中心的数据复制到容灾中心，在生产中心出现故障时，仅能实现存储系统的接管或是数据的恢复。容灾中心的数据可以是本地生产数据的完全复制（在同城实现），也可以比生产数据略微落后，差异的数据可以通过一些工具（如操作记录、日志等）可以手工补回。

应用级容灾, 是在数据级容灾的基础上，在Ucloud侧创建和阿里云侧生产中心系统的核心资源复制，包括主机、数据库、应用、当生产系统发生灾难时，依赖GTM实现故障切换，切换到备用可用区，实现应用级容灾. 

# 方案概述

1.  多云 不同 Region 内网互通，使用ucloud罗马打通
2.  使用GTM 做业务流量调度 -> SLB/ULB(两地中心入口地址) https://developer.aliyun.com/article/754825
3.  业务架构面向多活架构改造
4.  业务应用弹性扩缩容
    1.  容器化应用采用k8s集群的原生特性自动扩容(CA/HPA/VPA)
    2.  虚拟机扩容采用监控结合API方式扩容 
5.  数据集群分布式化
    1.  mysql采用强一致性的集群方案Percona XtraDB Cluster
    2.  MongoDB容灾采用 MongoShake 单向实时同步
    3.  Oracle 可以寻求商业支持，例如采用Oracle Rac高可用方案

## GTM流量调度

GTM 本质上是通过 DNS，结合监控，实现流量调度，为客户输出不同网络或地区用户访问实现就近接入、应用服务运行状态的健康检查、故障自动切换，等能力。

### GTM和LB**对比表**


| 对比项 | 网络层 | 后端地址 | 加权轮询 | 跨Region难度 | 故障间隔时间 | 会话保持 |
|-------|---------|------------|---------|-----------|---------|-----------|
| GTM | 3 层 | 域名、IP | 支持 | 简单 | 分钟级 | 不支持 |
| LB | 4层、7层 | IP | 支持 | 困难 | 秒级 | 支持 |

### GTM和GSLB **对比表**

无法复制加载中的内容

### GTM故障切换时间

GTM能在 5分钟内 将应用服务的90%左右的流量切换成功。GTM的故障切换生效时间 = 故障发现时间 + DNS切换同步时间 。

*   故障发现时间：目前默认的健康检查配置可以在故障的3分钟左右准确发现故障；
*   DNS切换同步时间：目前 GTM 的cname接入域名TTL设置为60秒，理论上域名切换后60秒内可以生效，但实际情况取决于全国各地运营商的缓存设置时间。

### GTM主要应用场景

*   应用主备容灾：建立两个地址池 Pool A 和 Pool B，设置默认地址池为 Pool A、备用地址池为 Pool B ，结合健康检查，即可以实现应用服务主备IP容灾切换
*   应用多活：建立一个地址池**Pool A**， 然后把 **1.1.1.1、2.2.2.2、3.3.3.3** 三个地址添加进地址池，并配置上健康检查，即可实现多个IP多活。
*   也适用于，高并发应用服务负载分摊，不同区域访问加速

## 业务应用系统面向多活架构改造

容灾说明：

1.  业务应用需要清晰的解耦分层，web应用(无状态)，缓存/消息队列，ES日志，DB 云主机资源
2.  阿里云/Ucloud云 VPC网络使用ipsecVpn 或者罗马打通vpc
3.  业务域名入口采用阿里云GTM做跨Region 流量调度和故障切换
4.  业务阿里云/Ucloud云容灾，其中阿里云BGP入口为主，Ucloud云BGP入口为备用，阿里云杭州可用区和UC上海可用区使用罗马打通VPC网络，延时4-6ms
5.  阿里云资源故障后，GTM将流量切换到Ucloud云BGP入口
6.  Ucloud云资源全新部署，建议web应用采用容器集群，充分利用k8s原生的特性实现节点自动扩容，应用实例扩容
    1.  Cluster Autoscaler：集群node节点扩容/缩容 
    2.  HPA： Pod个数自动扩/缩容
    3.  VPA ：Pod配置自动扩/缩容，主要是CPU、内存 addon-resizer组件
7.  虚拟机扩容采用监控结合API方式扩容 (节点监控(cpu/mem/connet) -> monitor -> altermanager-webhook-API操作扩容 ) 
8.  MySQL数据层建议采用兼容InnoDB引擎的Percona XtraDB Cluster集群模式来保证强一致性
9.  MongoDB容灾采用 MongoShake实现实时从阿里云侧同步到Ucloud云侧

问题：

1、网络抖动或短时故障，不建议切业务主备，影响时间将更长

2、都云异构的容灾方式后续维护成本较高，包括物理环境、网络环境、自建系统环境等，需要业务侧投入人力更大

3、Percona XtraDB Cluster保证了强一致性能，但是牺牲了部分性能

![image](https://upload-images.jianshu.io/upload_images/5592768-97564b32277ab038?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image](https://upload-images.jianshu.io/upload_images/5592768-3267f039ad383a64?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

 不支持在 Docs 外粘贴 block 

## MongoDB 容灾

MongoShake从源库抓取oplog数据，然后发送到各个不同的tunnel通道。源库支持：ReplicaSet，Sharding，Mongod，目的库支持：Mongos，Mongod。

MongoDB同步方式采用 Direct通道类型，直接写入目的MongoDB

## DB容灾方案

Percona XtraDB Cluster(简称PXC)，是由percona公司推出的mysql集群解决方案。特点是每个节点都能进行读写，且都保存全量的数据。也就是说在任何一个节点进行写入操作，都会同步给其它所有节点写入到自己的磁盘，选择PXC作为容灾方案的理由是:

1.  PXC 强一致性特性，在故障转移，恢复等自动化程度高
2.  支持 IST 增量传输，适合在跨地域，网路延迟较高的场景做同步
3.  阿里云侧和Ucloud侧各自配置了一个4层LB来作为DB请求的入口，轮询方式(避免)

### **PXC特性和优点**

*   完全兼容 MySQL。
*   同步复制，事务要么在所有节点提交或不提交。
*   多主复制，可以在任意节点进行写操作。
*   在从服务器上并行应用事件，真正意义上的并行复制。
*   节点自动配置，数据一致性，不再是异步复制。
*   故障切换：因为支持多点写入，所以在出现数据库故障时可以很容易的进行故障切换。
*   自动节点克隆：在新增节点或停机维护时，增量数据或基础数据不需要人工手动备份提供，galera cluster会自动拉取在线节点数据，集群最终会变为一致；

PXC最大的优势：强一致性、无同步延迟，适合订单，交易系统等场景

### **PXC的局限和劣势**

*   复制只支持InnoDB 引擎，其他存储引擎的更改不复制
*   短板效应
    *   集群写入性能取决于性能最差那台机器，所以建议配置相同
*   锁冲突严重
    *   建议单节点写+负载均衡，或者写不同的库
*   全量SST时，donor节点性能影响较为严重，receiver恢复较慢
    *   尽量避免SST
*   维护成本高，限制和注意事项较多

**PXC与Replication的区别**

无法复制加载中的内容

### PXC 使用**注意事项**

1.  PXC各个节点默认是不会记录全量日志的，只会记录当前节点变化数据的binlog：想要节点记录全量binlog日志需要添加该配置：log_slave_updates, 在PXC集群中，官方推荐使用相同的server-id
2.  PXC支持两种同步方式：
    1.  SST 全量传输支持 XtraBackup、mysqldump、rsync三种方式， 
    2.  IST 增量传输支持 XtraBackup
3.  群集的最小建议大小是3个节点。第三个节点会是仲裁者
4.  复制仅适用于InnoDB存储引擎。其他存储引擎的表的写入都不复制(包括mysql.*表)。但是，DDL语句会在statement级别进行复制，对mysql.*表的更改将以这种方式进行复制。因此您使用CREATE USER...命令，而不应该使用INSERT INTO mysql.user...。
5.  不支持的查询：
    1.  在多主设置中，不支持LOCK TABLES和UNLOCK TABLES
    2.  Lock functions如GET_LOCK(),RELEASE_LOCK()也不支持
6.  general.log、slow.log不支持输出到TABLE，如果启用general.log、slow.log，则必须将日志输出到文件：

```
log_output  =  FILE

```

> 设置输出到table，会有严重的锁冲突，导致性能问题，严重时导致mysqld崩溃。

*   允许的最大事务大小由wsrep_max_ws_rows和wsrep_max_ws_size变量定义。LOAD DATA INFILE处理将(按参数设置)每10000行提交一次。因此大事务LOAD DATA时将被拆分为一系列小事务。
*   由于集群级的乐观并发控制，事务在COMMIT阶段可能仍会中止。可以有两个事务写入相同的行并在单独的Percona XtraDB Cluster节点中提交，并且只有其中一个可以成功提交。失败的将被中止。对于集群级中止，Percona XtraDB Cluster提供了死锁错误代码：

```
(Error: 1213 SQLSTATE: 40001  (ER_LOCK_DEADLOCK)).

```

*   由于可能在提交时回滚，因此不支持XA事务。
*   整个集群的写吞吐量受最弱节点的限制。如果一个节点变慢，则整个群集速度变慢。如果您对稳定的高性能有要求，则应该由相应的硬件支持。
*   不支持InnoDB虚假更改功能。enforce_storage_engine=InnoDB与wsrep_replicate_myisam=OFF（默认）不兼容 。
*   在群集模式下运行Percona XtraDB群集时，请避免ALTER TABLE ... IMPORT/EXPORT操作。如果未在所有节点上同步执行，则可能导致节点数据不一致。
*   所有表必须具有主键。这可确保相同的行在不同节点上以相同的顺序出现。DELETE没有主键的表的语句不被支持。

无法复制加载中的内容

# POC 环境以及测试数据

## GTM故障切换

这里采用阿里云的GTM服务做业务流量调度，和

1.  首先需要开通阿里云GTM服务，购买GTM实例，完成基本配置域名和配置地址池

![image](https://upload-images.jianshu.io/upload_images/5592768-11b80b70a1b3950c?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image](https://upload-images.jianshu.io/upload_images/5592768-19a7d88743743b5a?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2.  为地址池IP 添加健康检查，支持ping tcp http https 

![image](https://upload-images.jianshu.io/upload_images/5592768-76847a451ab26625?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

3.  设置访问策略

![image](https://upload-images.jianshu.io/upload_images/5592768-44dace7cb36b7473?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

4.  模拟故障，停掉 主地址池IP 业务应用服务，业务域名解析会切换到备用地址池IP

阿里云 GTM 标准版本TTL需要10分钟，健康检查最小间隔分钟级，需要更快切换，建议购买阿里云 GTM 旗舰版服务

![image](https://upload-images.jianshu.io/upload_images/5592768-b814249b1dd9b6d6?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

5.  故障恢复后，业务域名会重新恢复到主地址池

## 业务应用扩容

业务应用弹性扩容分两个场景, 容器方式部署的应用和虚拟机部署的应用：

### 容器应用扩容

首先将应用转变容器应用，然后部署在k8s集群中，可以充分k8s集群的能力，实现自动扩缩容：

1.  集群节点的自动扩容
2.  应用资源配额的横向/纵向扩容
3.  通过配置uk8s的集群伸缩，可以实现集群node节点扩容/缩容(Cluster Autoscaler) 

![image](https://upload-images.jianshu.io/upload_images/5592768-12c1deb4bdcd4183?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2.  Metrics-server 已经内置，Pod个数自动扩/缩容(HPA)，只需要对应用配置 HPA 即可，示例如下:

创建一个nginx服务，ULB 由 cloudprovider-ucloud 自动创建，和公有云相关配置在名为uk8sconfig的configmap中,创建 test-nginx.yaml

```
apiVersion: v1
kind: Service
metadata:
  name: ucloud-nginx
  labels:
    app: ucloud-nginx
spec:
  type: LoadBalancer
  ports:
    - protocol: TCP
      port: 80
  selector:
    app: ucloud-nginx
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ucloud-nginx
spec:
  selector:
    matchLabels:
      app: ucloud-nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: ucloud-nginx
    spec:
      containers:
      - name: ucloud-nginx
        image: uhub.service.ucloud.cn/ucloud/nginx:1.9.2
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 80

```

执行命令: kubectl apply -f test-nginx.yaml 创建资源，

执行命令: kubectl get services 可以查询到 EXTERNAL-IP 即创建服务生成ULB外网IP

创建HPA配置，参考如下：

```
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: ucloud-nginx
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ucloud-nginx
  minReplicas: 1
  maxReplicas: 1000
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 2
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 500
        periodSeconds: 15
      - type: Pods
        value: 10
        periodSeconds: 15
      selectPolicy: Max
    scaleDown:
      stabilizationWindowSeconds: 10
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15

```

1.  缩容策略: 稳定窗口的时间为 *300* 秒，允许 100% 删除当前运行的副本，
2.  扩缩策略: 立即扩容，每 15 秒添加 4 个 Pod 或 100% 当前运行的副本数，直到 HPA 达到稳定状态。
3.  https://kubernetes.io/zh/docs/tasks/run-application/horizontal-pod-autoscale/

使用AB压测验证:

操作压测集群节点执行命令: ab -n 100000 -c 300 http://nginx_server_ip/

集群初始状态:

![image](https://upload-images.jianshu.io/upload_images/5592768-4ae858df59c0a9d7?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

压测过程中，随着请求带来对pod带来的压力，会触发Pod快速扩容个数，同时集群node节点的请求值达到扩容阈值的时候，会自动新增node节点

![image](https://upload-images.jianshu.io/upload_images/5592768-485a1b16d8d3ea13?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

在压测结束后，稳定窗口时间结束后，集群内pod数量，node节点数会恢复到初始状态

3.  Pod配置自动扩/缩容(VPA) 需要部署**vertical-pod-autoscaler控制器 参考**https://github.com/kubernetes/autoscaler VPA示例以及VPA使用限制

```
apiVersion: autoscaling.k8s.io/v1beta2
kind: VerticalPodAutoscaler
metadata:
  name: nginx-vpa
  namespace: vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: nginx
  updatePolicy:
    updateMode: "Off"
  resourcePolicy:
    containerPolicies:
    - containerName: "nginx"
      minAllowed:
        cpu: "250m"
        memory: "100Mi"
      maxAllowed:
        cpu: "2000m"
        memory: "2048Mi"

```

1.  不能与HPA（Horizontal Pod Autoscaler ）一起使用
2.  Pod比如使用副本控制器，例如属于Deployment或者StatefulSet

### 非容器应用扩容

虚拟机节点扩容目前没有标准的服务，可以结合监控，调用API方式扩容，需要结合具体业务监控做ucloud平台接口对接实现。

## 部署 PXC 集群

部署第一个节点

```
docker run -d                    \
-p 3306:3306                     \
-e MYSQL_ROOT_PASSWORD=abc123456 \
-e CLUSTER_NAME=PXC              \
-e XTRABACKUP_PASSWORD=abc123456 \
-v /data/:/var/lib/mysql         \
--privileged                     \
--name=pxc-node-1                \
--net=host                       \
percona/percona-xtradb-cluster:5.7

```

加入其他节点

```
docker run -d                    \
-p 3306:3306                     \
-e MYSQL_ROOT_PASSWORD=abc123456 \
-e CLUSTER_NAME=PXC              \
-e XTRABACKUP_PASSWORD=abc123456 \
-e CLUSTER_JOIN=pxc-node-1       \
--privileged                     \
--name=pxc-node-4                \
--net=host                       \
percona/percona-xtradb-cluster:5.7

```

### 可用性测试

1.  停掉任一节点，PXC集群服务不中断，业务应用无感知
2.  如需PXC升级集群配置，逐台离线升级，重建加入集群即可

### sysbench压力测试

```
mysql -h 10.10.114.135 -uroot -pabc123456
create database sbtest;

sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua \
--mysql-host=10.10.114.135  \
--mysql-port=3306           \
--mysql-user=root           \
--mysql-password=abc123456  \
--oltp-test-mode=complex    \
--oltp-tables-count=10      \
--oltp-table-size=10000     \
--threads=10                \
--time=120                  \
--report-interval=10 prepare

sysbench /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua \
--mysql-host=10.10.114.135  \
--mysql-port=3306           \
--mysql-user=root           \
--mysql-password=abc123456  \
--oltp-test-mode=complex    \
--oltp-tables-count=10      \
--oltp-table-size=100000    \
--threads=10                \
--time=120                  \
--report-interval=10 run >> /root/sysbench-mysql.log

```

## POC 应用环境

整个 POC 环境使用，wordpress / redis插件/ PXC DB集群 北京/上海两地 多活部署方式

1.  北京/上海两地网络延迟 平均30ms
2.  北京/上海 两地k8s集群规模 3master 5node 
3.  PXC DB 集群 单节点配置 4核8G sysbench测试结果

```
   SQL statistics:
    queries performed:
        read:                            304850
        write:                           54616
        other:                           76002
        total:                           435468
    transactions:                        21760  (181.25 per sec.)
    queries:                             435468 (3627.15 per sec.)
    ignored errors:                      15     (0.12 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          120.0560s
    total number of events:              21760

Latency (ms):
         min:                                   52.43
         avg:                                   55.16
         max:                                  110.09
         95th percentile:                       56.84
         sum:                              1200266.64

Threads fairness:
    events (avg/stddev):           2176.0000/14.59
    execution time (avg/stddev):   120.0267/0.02

```

