# Zookeeper

## 简介

Zookeeper是一个高效的分布式协调服务，可以提供配置信息管理、命名、分布式同步、集群管理、数据库切换等服务。它不适合用来存储大量信息，可以用来存储一些配置、发布与订阅等少量信息。典型应用场景如下:

* Hadoop
* Storm
* 消息中间件
* RPC服务框架
* 分布式数据库同步系统

## 系统环境：

* OS: CentOS 7.４
* CPU：2核
* 内存：4G
* Software：java-1.8.0-openjdk
* zookeeper-3.3.6.tar.gz

## 角色分配

* 10.10.0.1 node1
* 10.10.0.2 node2
* 10.10.0.3 node3

## 准备工作

分别登录主机(node1,node2,node3)，完成以下操作:　

1. 创建用于运行zookeeper的用户:`useradd zk`
2. 创建工作目录`mkdir -pv /data ; chown -Rv zk:zk /data`
3. 以root安装JDK1.8执行命令，`yum install java-1.8.0-openjdk -y`
4. 下载zookeeper安装包，以zk用户操作并解压
```
su - zk
wget http://mirror.bit.edu.cn/apache/zookeeper/stable/zookeeper-3.4.12.tar.gz
tar -xvpf zookeeper-3.4.12.tar.gz -C /data/
```

### 单机模式

单机模式较简单，是指只部署一个zk进程，客户端直接与该zk进程进行通信。 
```
su - zk
cd /data/zookeeper-3.4.12/
touch conf/zoo.cfg
bin/zkServer.sh start
```

* 检查端口：2181,执行命令`netstat -nat`查看
* 检查集群状态，执行命令`/data/zookeeper-3.4.12/bin/zkServer.sh status` 返回结果
```
Using config: /data/zookeeper-3.4.12/bin/../conf/zoo.cfg
Mode: standalone
```
* 连接测试，执行命令`bin/zkCli.sh -server localhost:2181`

### 集群模式

Zookeeper集群中节点个数一般为奇数个（>=3），若集群中Master挂掉，剩余节点个数在半数以上时，就可以推举新的主节点，继续对外提供服务。


* 配置集群：在集群模式下，所有节点主机上可以使用相同的配置文件。

分别登录主机(node1,node2,node3)，，切换到zk用户`su - zk`, 以zk用户身份完成如下操作：

编辑文件/data/zookeeper-3.4.12/bin/conf/zoo.cfg
```
tickTime=2000
dataDir=/data/zookeeper
clientPort=2181
initLimit=5
syncLimit=2
server.1=10.10.0.1:2888:3888
server.2=10.10.0.2:2888:3888
server.3=10.10.0.3:2888:3888
```
* 启动服务
需要先在每台机器的 dataDir 目录下创建 myid 文件，文件内容即为该机器对应的 Server ID 数字

  * node1主机: 执行命令
`su -zk
 echo 1 > /data/zookeeper/myid
 /data/zookeeper-3.4.12/bin/zkServer.sh start
`

  * node2主机: 执行命令
`su -zk
 echo 2 > /data/zookeeper/myid
 /data/zookeeper-3.4.12/bin/zkServer.sh start
`

  * node3主机: 执行命令
`su -zk
 echo 3 > /data/zookeeper/myid
 /data/zookeeper-3.4.12/bin/zkServer.sh start
`

* 测试集群
  * 检查端口：2181,2888,3888,执行命令`netstat -nat`查看
  * 检查集群状态,分别登录主机(node1,node2,node3)，切换到zk用户`su - zk`,执行命令:`/data/zookeeper-3.4.12/bin/zkServer.sh status` 返回结果为:
  
 ```
  ZooKeeper JMX enabled by default                
  Using config: /data/zookeeper-3.4.12/bin/../conf/zoo.cfg
  Mode: leader  
  ```
    或
  ```
  ZooKeeper JMX enabled by default               
  Using config: /data/zookeeper-3.4.12/bin/../conf/zoo.cfg
  Mode: follower  
  ```

* 集群连接测试
  * 执行命令:`bin/zkCli.sh -server 10.10.0.1:2181,10.10.0.2:2181,10.10.0.3:2181`,返回结果包含如下部分：
  ```
  2018-06-27 18:37:51,587 [myid:] - INFO  [main- SendThread(10.10.0.3:2181):ClientCnxn$SendThread@1302]
  ```
 从日志输出可以看到，客户端连接的是10.10.0.3:2181进程（连接上哪台机器的zk进程是随机的），客户端已成功连接上zk集群。

## 使用ansible部署集群

1. 在当前系统安装ansible
2. 获取配置库 `git clone git@github.com:panhaitao/SoldierSuit.git`
3. 编辑SoldierSuit/hosts,添加zk分组配置
`
[zk]
node1 id=1 ansible_host=47.105.47.111  intra_ip=172.31.150.241
node2 id=2 ansible_host=47.105.44.0    intra_ip=172.31.150.242
node3 id=3 ansible_host=47.104.215.75  intra_ip=172.31.150.243
`
配置项参考
* id 定义的ZK节点配置`/data/zookeeper/myid`
* ansible_host定义ZK节点登录IP
* intra_ip定义ZK节点内网IP

4. 执行部署`cd SoldierSuit; ansible-playbook roles/zookeeper/zookeeper.yaml` 完成部署，阿里云主机测试通过


# 参考资料

* http://zookeeper.apache.org/doc/current/zookeeperStarted.html
* http://zookeeper.apache.org/doc/current/zookeeperAdmin.html
* ZooKeeper基本操作 <https://www.jianshu.com/p/bbacb558371a>
* 简单的分布式server <http://www.cnblogs.com/good-temper/p/5656866.html>
