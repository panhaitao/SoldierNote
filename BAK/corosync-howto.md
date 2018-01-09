

# cp /etc/corosync/corosync.conf.example /etc/corosync.conf  复制一份corosync的样本配置文件
# vim /etc/corosync/corosync.conf   编辑配置文件修改如下内容

```
compatibility: whitetank    #这个表示是否兼容0.8之前的版本
totem {    #图腾，这是用来定义集群中各节点中是怎么通信的以及参数
        version: 2        #图腾的协议版本，它是种协议，协议是有版本的，它是用于各节点互相通信的协议，这是定义版本的
        secauth: on        #表示安全认证功能是否启用的
        threads: 0        #实现认证时的并行线程数，0表示默认配置
        interface {        # 指定在哪个接口上发心跳信息的，它是个子模块
                ringnumber: 0    #环号码，集群中有多个节点，每个节点上有多个网卡，别的节点可以接收，同时我们本机的别一块网卡也可以接收，为了避免这些信息在这样的环状发送，因此要为这个网卡定义一个唯一的环号码，以避免心跳信息环发送。
                bindnetaddr: 192.168.1.1        # 绑定的网络地址
                mcastaddr: 226.94.1.1    #多播地址，一对多通信
                mcastport: 5405        # 多播端口
                ttl: 1        # 表示只向外播一次
        }
}
logging {        # 跟日志相关
        fileline: off
        to_stderr: no        # 表示是否需要发送到错误输出
        to_logfile: yes        #是不是送给日志文件
        to_syslog: no        #是不是送给系统日志
        logfile: /var/log/cluster/corosync.log        #日志文件路径
        debug: off        #是否启动调试
        timestamp: on        #日志是否需要记录时间戳
        logger_subsys {        #日志的子系统
                subsys: AMF
                debug: off
        }
}
amf {        # 跟编程接口相关的
        mode: disabled
}
service {  #定义一个服务来启动pacemaker
    ver: 0    #定义版本
    name: pacemaker  #这个表示启动corosync时会自动启动pacemaker
}
aisexec {  #表示启动ais的功能时以哪个用户的身份去运行的
    user: root
    group: root  #其实这个块定义不定义都可以，corosync默认就是以root身份去运行的
}
```


复制代码
这里我们改一个随机数墒池，再把配置好的corosync的配置和认证文件复制到另一个节点上去：    

复制代码
# mv /dev/random /dev/m
# ln /dev/urandom /dev/random  如果这把这个随机数墒池改了可以会产生随机数不够用，这个就要敲击键盘给这个墒池一些随机数；生成完这个key后把链接删除，再把墒池改回来；不过这样改可以会有点为安全，不过做测试的应该不要紧；
# corosync-keygen
# rm -rf /dev/random
# mv /dev/m /dev/random
对于corosync而言，我们各节点之间通信时必须要能够实现安全认证的，要用到一个密钥文件：
# corosync-keygen    # 生成密钥文件，用于双机通信互信，会生成一authkey的文件
# scp authkey corosync.conf node2.tanxw.com:/etc/corosync/   在配置好的节点上把这两个文件复制给另一个节点上的corosync的配置文件中去

##
启动Corosync
Corosync 启动方法和普通的系统服务没有区别，根据 Linux 发行版的不同，可能是 LSB init 脚本、upstart 任务、systemd 服务。不过习惯上，都会统一使用 corosync 这一名称：

/etc/init.d/corosync start （LSB）

service corosync start （LSB，另一种方法）

start corosync （upstart）

systemctl start corosync （systemd）

使用以下两个工具检查 Corosync 连接状态。

corosync-cfgtool ，执行时加上 -s 参数，可以获取整个集群通信的健康情况：

# corosync-cfgtool -s
    Printing ring status.
Local node ID 435324542
RING ID 0
        id      = 192.168.42.82
        status  = ring 0 active with no faults
RING ID 1
        id      = 10.0.42.100
        status  = ring 1 active with no faults
corosync-objctl 命令可以列出 Corosync 集群的成员节点列表：

# corosync-objctl runtime.totem.pg.mrp.srp.members
    runtime.totem.pg.mrp.srp.435324542.ip=r(0) ip(192.168.42.82) r(1) ip(10.0.42.100)
runtime.totem.pg.mrp.srp.435324542.join_count=1
runtime.totem.pg.mrp.srp.435324542.status=joined
runtime.totem.pg.mrp.srp.983895584.ip=r(0) ip(192.168.42.87) r(1) ip(10.0.42.254)
runtime.totem.pg.mrp.srp.983895584.join_count=1
runtime.totem.pg.mrp.srp.983895584.status=joined
status=joined标示着每一个集群节点成员。

## 

启动 Pacemaker
Corosync 服务启动之后，一旦各节点正常建立集群通信，就可启动 pacemakerd （ Pacemaker 主进程）：

/etc/init.d/pacemaker start （LSB）

service pacemaker start （LSB，另一种方法）

start pacemaker （upstart）

systemctl start pacemaker （systemd）

Pacemaker 服务启动之后，会自动建立一份空白的集群配置，不包含任何资源。可以通过 crm_mon 工具查看 Packemaker 集群的状态：

============
Last updated: Sun Oct  7 21:07:52 2012
Last change: Sun Oct  7 20:46:00 2012 via cibadmin on node2
Stack: openais
Current DC: node2 - partition with quorum
Version: 1.1.6-9971ebba4494012a93c03b40a2c58ec0eb60f50c
2 Nodes configured, 2 expected votes
0 Resources configured.
============

Online: [ node2 node1 ]



## 参考

* 高可用集群基础概念: http://blog.csdn.net/tjiyu/article/details/52643096
