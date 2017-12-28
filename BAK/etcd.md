etcd 简介
---------

etcd是一个分布式可靠的键值存储，用于存储分布式系统的关键数据。主要特性如下：

-   基于HTTP+JSON的API
-   选SSL客户认证机制
-   使用Raft算法充分实现了分布式。
-   高效的读写性能

分布式系统中的数据分为控制数据和应用数据。etcd的使用场景默认处理的数据都是控制数据，对于应用数据，只推荐数据量很小，但是更新访问频繁的情况。典型应用场景有如下几类：

-   服务发现（Service Discovery）
-   消息发布与订阅
-   负载均衡
-   分布式通知与协调
-   分布式锁、分布式队列
-   集群监控与Leader竞选

etcd 工作原理
-------------

使用Raft协议来维护集群内各个节点状态的一致性。简单说，ETCD集群是一个分布式系统，由多个节点相互通信构成整体对外服务，每个节点都存储了完整的数据，并且通过Raft协议保证每个节点维护的数据是一致的。

etcd 的安装部署
---------------

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
