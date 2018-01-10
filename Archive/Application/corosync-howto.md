# Corosync 概述 

Corosync 是一个源自OpenAIS项目，基于BSD许可证的集群引擎.核心功能是一个群组通信系统，具有实现应用程序高可用性的附加功能。该项目提供了四个 C API功能：

* 具有虚拟同步的封闭进程组通信模型保证了用于创建复制状态机。
* 一个简单的可用性管理器，在失败时重新启动应用程序进程。
* 内存数据库配置和统计信息，提供设置，检索和接收信息更改通知的功能。
* 达到法定人数或丢失时通知应用程序的法定人数系统。
* 该软件设计用于在UDP/IP 和 InfiniBand网络上运行。

## 前提准备工作

系统     : CentOS 7
前提     ：时间同步、防火墙关闭, selinux关闭；
集群模式 : 双机高可用
主机数量 ：2  

完成准备工作后，在每个主机都要安装软件包: `corosync`, 设置两台主机名解析（/etc/hosts），解析的结果必须要和本地使用的主机名保持一致.

例如 /etc/hosts
```
10.1.11.109 HA1
10.1.11.203 HA2
```
##  corosync的程序环境

* 配置文件：/etc/corosync/corosync.conf
* 密钥文件：/etc/corosync/authkey
* 服务配置：/lib/systemd/system/corosync.service

## corosync的配置实例及参数解析

主机1配置，编辑配置文件 /etc/corosync/corosync.conf 修改内容参考如下:

```
totem {
      version: 2
      crypto_cipher: aes256
      crypto_hash: sha1
      interface {
          ringnumber: 0
          bindnetaddr: <主机IP>
          mcastaddr: 239.255.100.1
          mcastport: 5405
          ttl: 1
      }
}                              

logging {
      fileline: off
      to_stderr: no
      to_logfile: yes
      logfile: /var/log/cluster/corosync.log
      to_syslog: no
      debug: off
      timestamp: on
      logger_subsys {
           subsys: QUORUM
           debug: off
      }
}

quorum {
      provider: corosync_votequorum
}

nodelist {
      node {
         ring0_addr: HA1
         nodeid: 1
      }
      node {
         ring0_addr: HA2
         nodeid: 2
      }
}
```

执行命令: `corosync-keygen` 生成用于双机通信互信密钥文件 /etc/corosync/authkey，至此主机1配置完成。

下面进行主机2的配置

* 将主机1的/etc/corosync/authkey 分发到主机相同位置，两台主机共用相同的密钥文件，
* 将主机1的配置 /etc/corosync/corosync.conf 分发到另一台主机，其中 bindnetaddr 修改为相应的IP 

## 启动Corosync服务

分别在两台主机上执行命令 `systemctl start corosync`  重启服务,观察两台主机的corosync日志，如果服务器运行正常，将会返回如下类似结果:

```
tail -f /var/log/cluster/corosync.log 
Jan 10 02:46:16 [2297] HA2 corosync notice  [SERV  ] Service engine loaded: corosync cluster quorum service v0.1 [3]
Jan 10 02:46:16 [2297] HA2 corosync info    [QB    ] server name: quorum
Jan 10 02:46:16 [2297] HA2 corosync warning [TOTEM ] JOIN or LEAVE message was thrown away during flush operation.
Jan 10 02:46:16 [2297] HA2 corosync notice  [TOTEM ] A new membership (10.1.11.203:16) was formed. Members joined: 2
Jan 10 02:46:16 [2297] HA2 corosync notice  [QUORUM] Members[1]: 2
Jan 10 02:46:16 [2297] HA2 corosync notice  [MAIN  ] Completed service synchronization, ready to provide service.
Jan 10 02:46:16 [2297] HA2 corosync notice  [TOTEM ] A new membership (10.1.11.109:20) was formed. Members joined: 1
Jan 10 02:46:16 [2297] HA2 corosync notice  [QUORUM] This node is within the primary component and will provide service.
Jan 10 02:46:16 [2297] HA2 corosync notice  [QUORUM] Members[2]: 1 2
Jan 10 02:46:16 [2297] HA2 corosync notice  [MAIN  ] Completed service synchronization, ready to provide service
```


## 验证Corosync配置

* 主机1执行命令：`corosync-cfgtool -s` 将会返回如下类似结果：

```
[root@HA1 ~]# corosync-cfgtool -s
Printing ring status.
Local node ID 1
RING ID 0
        id      = 10.1.11.109
        status  = ring 0 active with no faults

```

* 主机2执行命令：`corosync-cfgtool -s` 将会返回如下类似结果：

```
[root@HA2 ~]# corosync-cfgtool -s
Printing ring status.
Local node ID 2
RING ID 0
        id      = 10.1.11.203
        status  = ring 0 active with no faults

```

* 在其中任意一台主机执行命令：`corosync-cmapctl |grep member`

```
[root@HA2 ~]# corosync-cmapctl |grep member
runtime.totem.pg.mrp.srp.members.1.config_version (u64) = 0
runtime.totem.pg.mrp.srp.members.1.ip (str) = r(0) ip(10.1.11.109) 
runtime.totem.pg.mrp.srp.members.1.join_count (u32) = 1
runtime.totem.pg.mrp.srp.members.1.status (str) = joined
runtime.totem.pg.mrp.srp.members.2.config_version (u64) = 0
runtime.totem.pg.mrp.srp.members.2.ip (str) = r(0) ip(10.1.11.203) 
runtime.totem.pg.mrp.srp.members.2.join_count (u32) = 1
runtime.totem.pg.mrp.srp.members.2.status (str) = joined
```

以上就是corosync的配置过程, corosync 只是一个集群引擎，如果需要构建一个完整的应用集群，还需要和资源管理器Pacemaker 或者DRBD 以及具体的应用结合

## corosync配置文件参考

* totem{}       #节点间的通信协议，主要定义通信方式、通信协议版本、加密算法等 
  * version: 2         #定义协议版本
  * crypto_hash：      #哈希加密算法  md5, sha1, sha256, sha384 and sha512.
  * crypto_cipher：    #对称加密算法 aes256, aes192, aes128 and 3des
  * interface{}        #定义集群心跳信息传递的接口，可以有多组；
    * ringnumber       #环号
    * bindnetaddr      #绑定的网络地址
    * mcastaddr        #多播地址
    * mcastport        #实现多播地址的端口
    * ttl              #一个报文最多被中继转发多少次，一般设置为1
* logging {}           # 跟日志相关
  * fileline: off
  * to_stderr: no     # 表示是否需要发送到错误输出
  * to_logfile: yes   #是不是送给日志文件
  * to_syslog: no     #是不是送给系统日志
  * logfile: /var/log/cluster/corosync.log        #日志文件路径
  * debug: off        #是否启动调试
  * timestamp: on     #日志是否需要记录时间戳
  * logger_subsys {}  #日志的子系统
  * subsys: QUORUM    #是否记录子系统的QUORUM日志信息 
* quorum {}           #投票子系统 
  * provider: corosync_votequorum #指明使用哪一种算法完成投票选举
* nodelist {}         #节点列表 

## 参考资源

* 高可用集群基础概念: http://blog.csdn.net/tjiyu/article/details/52643096
* 官方主页：http://corosync.github.io/corosync/
