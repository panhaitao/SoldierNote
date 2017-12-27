---
title: "pacemaker"
categories: CentOS7
tags: 集群管理
---

# Pacemaker 集群软件

Pacemaker 是一个集群资源管理器。它利用集群基础构件(OpenAIS 、 heartbeat 或 corosync)
提供的消息和成员管理能力来探测并从节点或资源级别的故障中恢复,以实现群集服务(亦称资源)的
最大可用性。

## Pacemaker 概述

Pacemaker 的主要特点包括:主机和应用程序级别的故障检测和恢复,几乎支持任何冗余配置,同时支持多种集群配置模式,配置策略处理法定人数损失(多台机器失败时),支持应用启动/关机顺序,支持在同一台机器上运行不同的应用程序,支持多种模式的应用程序(如主/从) ,可以测试任何故障或群集的群集状态。

Pacemaker 的常用配置方式包括如下:

1. 主/从架构:许多高可用性的情况下,使用 Pacemaker 和 DRBD 的双节点主/从集群是一个
符合成本效益的解决方案。
2. 多节点备份集群:支持多少节点,Pacemaker 可以显着降低硬件成本通过允许几个主/从群
集要结合和共享一个公用备份节点。
3. 共享存储集群,有共享存储时,每个节点可能被用于故障转移。Pacemaker 甚至可以运行多
个服务。
4. 站点集群,将包括增强简化设立分站点集群。

Pacemaker 支持的内部架构包括:支持基于 OpenAIS 的集群,以及基于心跳信息的传统集群架
构。Pacemaker 群集组件包括如下:

* stonithd:心跳系统。
* lrmd:本地资源管理守护进程,提供通用的接口支持的资源类型,直接调用资源代理(脚本)。
* pengine:政策引擎。根据当前状态和配置集群计算的下一个状态。产生一个过渡图,包含
行动和依赖关系的列表。
* CIB:群集信息库。包含所有群集选项,节点,资源,他们彼此之间的关系和现状的定义。同
步更新到所有群集节点。
* CRMD:集群资源管理守护进程。主要是消息代理的 PEngine 和 LRM,还选举一个领导者(DC)
统筹活动(包括启动/停止资源)的集群。
* OpenAIS:OpenAIS 的消息和成员层。
* Heartbeat:心跳消息层,OpenAIS 的一种替代。
* CCM:共识群集成员,心跳成员层。

CIB 使用 XML 表示集群的集群中的所有资源的配置和当前状态。CIB 的内容会被自动在整个集群
中同步,使用 PEngine 计算集群的理想状态,生成指令列表,然后输送到 DC (指定协调员)。 Pacemaker
集群中所有节点选举的 DC 节点作为主决策节点。如果当选 DC 节点宕机,它会在所有的节点上, 迅
速建立一个新的 DC。DC 将 PEngine 生成的策略,传递给其他节点上的 LRMd(本地资源管理守护程
序)或 CRMD 通过集群消息传递基础结构。当集群中有节点宕机,PEngine 重新计算的理想策略。在
某些情况下,可能有必要关闭节点,以保护共享数据或完整的资源回收。为此,Pacemaker 配备了
stonithd 模块,通常可以实现其它节点的远程电源控制。Pacemaker 会将 stonithd 配置为资源保存
在 CIB 中,使他们可以更容易地监测资源失败或宕机。

##  安装和基本配置

部署 Pacemaker 集群软件需要安装以下软件: pcs, pacemaker, corosync, fence-agents-all。
此外,如果需要配置相关服务,也要安装对应的软件。
版权所有©武汉深之度科技有限公司

1. 添加防火墙规则

    firewall-cmd --permanent --add-service=high-availability
    firewall-cmd --add-service=high-availability

2. 禁用防火墙
    systemctl disable firewalld
    systemctl stop firewalld

3. 禁用 selinux

修改/etc/sysconfig/selinux 确保 SELINUX=disabled,执行 setenforce 0 或重启系统以生效。

4. 各节点之间主机名互相解析

编辑配置文件/etc/hostname,将两台主机名分别设置为 node1 和 node2,然后重启网络服务
即可。两台主机分别在/etc/hosts 配置文件中加入域名解析,参考配置如下:

    10.1.11.101 node1
    10.1.11.102 node2

5. 配置 ssh

生成一个密码为空的公钥和一个密钥,把公钥复制到对方节点上,完成各节点之间 ssh 无密码密
钥访问的配置。执行如下命令:

* node1 主机:
    ssh-keygen -t rsa -P ""
    ssh-copy-id root@node2
* node2 主机:

    ssh-keygen -t rsa -P ""
    ssh-copy-id root@node2
6. 管理高可用集群

为集群用户设置密码为了有利于各节点之间通信和配置集群,在每个节点上创建一个 hacluster 的用户,各个节点上
的密码必须是同一个。node1, node2 主机分别执行如下命令完成设置:
  
    passwd hacluster

6. 设置 pcsd 开机自启动

    systemctl start pcsd.service
    systemctl enable pcsd.service

7. 集群各节点之间进行认证

在其中任意一个节点执行如下命令,完成节点之间进行认证:

    [root@node2 ~]#
    pcs cluster auth node1 node2

执行命令会提示输入用户密码,输入 hacluster 和对应的密码,完成认证后,显示信息如下:

    Username: hacluster
    Password:
    node1: Authorized
    node2: Authorized

8. 创建并启动集群

在其中任意一个节点执行如下命令,完成节点之间进行认证:
 
   [root@node2 ~]# pcs cluster setup --start --name my_cluster node1 node2

操作完成,集群启动,并显示信息如下:
    
    [13/1605]
    Destroying cluster on nodes: node1, node2...
    node1: Stopping Cluster (pacemaker)...
    node2: Stopping Cluster (pacemaker)...
    node2: Successfully destroyed cluster
    node1: Successfully destroyed cluster
    Sending 'pacemaker_remote authkey' to 'node1', 'node2'
    node1: successful distribution of the file 'pacemaker_remote authkey'
    node2: successful distribution of the file 'pacemaker_remote authkey'
    Sending cluster config files to the nodes...
    node1: Succeeded
    node2: Succeeded
    Starting cluster on nodes: node1, node2...
    node1: Starting Cluster...
    node2: Starting Cluster...
    Synchronizing pcsd certificates on nodes node1, node2...
    node1: Success
    node2: Success
    Restarting pcsd on the nodes in order to reload the certificates...
    node1: Success
    node2: Success

9. 设置集群自启动

在其中任意一个节点执行如下命令,设置集群自启动设置:
    [root@node2 ~]# pcs cluster enable --all
操作完成,显示信息如下:
    node1: Cluster Enabled
    node2: Cluster Enabled

10. 查看集群状态信息

    [root@node2 ~] pcs cluster status 

回显信息如下:
    Cluster Status:
    Stack: corosync
    Current DC: node2 (version 1.1.16-12.el7_4.2-94ff4df) - partition with quorum
    Last updated: Mon Nov 20 15:54:08 2017
    Last change: Mon Nov 20 15:46:53 2017 by hacluster via crmd on node2
    2 nodes configured
    0 resources configured
    PCSD Status:
    node2: Online
    node1: Online

11. 配置浮点 IP

设置一个固定的地址来提供服务。在这里选择 10.1.11.199 作为浮动 IP,给它取一个好记的名
字 ClusterIP,并且告诉集群每 30 秒检查它一次,在其中任意一个节点执行如下命令,如下:
[root@node2 ~]# pcs resource create VIP ocf:heartbeat:IPaddr2 ip=10.1.11.199 cidr_netmask=24 op monitor
interval=30s

12. 配置 apache 服务

在 node1 和 node2 上安装 httpd
    yum install httpd -y
配置 httpd 监控页面,分别在 node1 和 node2 上执行:

    cat >> /etc/httpd/conf/httpd.conf << EOF
    <Location /server-status>
    SetHandler server-status
    Order deny,allow
    Deny from all
    Allow from localhost
    </Location>
    EOF

node1 节点修改如下:

    cat > /var/www/html/index.html << "EOF"
    <html>
    <body>Hello node1</body>
    </html>
    EOF

node2 节点修改如下:

    cat > /var/www/html/index.html << "EOF"
    <html>
    <body>Hello node2</body>
    </html>
    EOF

完成以上配置后,分别在 node1 和 node2 重启 httpd 服务,并设置 httpd 服务默认启动,执

行命令如下:
    systemctl restart httpd.service
    systemctl enable httpd.service

13. 将 httpd 作为资源添加到集群中:

    pcs resource create WEB apache configfile="/etc/httpd/conf/httpd.conf" statusurl="http://127.0.0.1/server-status"

至此,一个典型的双机高可用集群已经配置完成,可以通过浏览器访问 http://10.1.11.199 测试配置是否生效。

## 常用命令和可选配置

Pacemaker常用命令包括如下：

* 查看集群状态：      pcs status
* 查看集群当前配置：  pcs config
* 开机后集群自启动：  pcs cluster enable –all
* 启动集群：          pcs cluster start –all
* 查看集群资源状态：  pcs resource show
* 验证集群配置情况：  crm_verify -L -V
* 测试资源配置：      pcs resource debug-start resource
* 设置节点为备用状态：pcs cluster standby node1

Pacemaker可选配置包括如下：

* 创建服务器组 ( group ) 将VIP和WEB resource捆绑到这个group中，使之作为一个整体在集群中切换。

    pcs resource group add MyGroup VIP
    pcs resource group add MyGroup WEB

* 配置服务启动顺序以避免出现资源冲突

    pcs constraint order start VIP then start WEB

* 配件置节点权重 

Pacemaker并不要求机器的硬件配置是相同的，可能某些机器比另外的机器配置要好。这种状况下我们会希望设置：当某个节点可用时，资源就要跑在上面之类的规则。为了达到这个效果我们创建location约束，通过设置一个描述性的名字（例如，prefer-node1），指明权值。例如，指定分值为50，但是在双节点的集群状态下，任何大于0的值都可以达到想要的效果。

    pcs constraint location WEB prefers node1=60
    pcs constraint location WEB prefers node2=45

这里指定分值越大，代表更倾向于在对应的节点上运行。

* 资源粘性

一些环境中会要求尽量避免资源在节点之间迁移。迁移资源通常意味着一段时间内无法提供服务,某些复杂的服务,比如 Oracle 数据库,这个时间可能会很长。为了达到这个效果,Pacemaker 有一个叫做”资源粘性值”的概念,它能够控制一个服务(资源)有多想呆在它正在运行的节点上。

Pacemaker为了达到最优分布各个资源的目的，默认设置这个值为0。我们可以为每个资源定义不同的粘性值，但一般来说，更改默认粘性值就够了。资源粘性表示资源是否倾向于留在当前节点，如果为正整数，表示倾向，负数则会离开，-inf表示负无穷，inf表示正无穷。

    pcs resource defaults resource-stickiness=100

