# Kafka

## 简介

Kafka是一个分布式、支持分区的（partition）、多副本的（replica），基于zookeeper协调的分布式消息系统，它的最大的特性就是可以实时的处理大量数据以满足各种需求场景：

* 比如基于hadoop的批处理系统、低延迟的实时系统
* storm/Spark流式处理引擎
* web/nginx日志、访问日志，消息服务等等

Kafka的特性:

- 高吞吐量、低延迟：kafka每秒可以处理几十万条消息，它的延迟最低只有几毫秒，每个topic可以分多个partition, consumer group 对partition进行consume操作。
- 可扩展性：kafka集群支持热扩展
- 持久性、可靠性：消息被持久化到本地磁盘，并且支持数据备份防止数据丢失
- 容错性：允许集群中节点失败（若副本数量为n,则允许n-1个节点失败）
- 高并发：支持数千个客户端同时读写

## 系统环境：

* OS: CentOS 7.４
* CPU：2核
* 内存：4G
* Software：java-1.8.0-openjdk
* kafka_2.12-1.1.0.tgz

## 角色分配

* 10.10.0.1 node1
* 10.10.0.2 node2
* 10.10.0.3 node3

## 准备工作

分别登录主机(node1,node2,node3)，完成以下操作:　

1. 创建好一个已有的zookeeper集群: 例如
   `47.105.63.78:2181,118.190.201.40:2181,47.105.60.191:2181`
2. 创建用于运行kafka的用户:`useradd kafka`
3. 创建工作目录 `mkdir -pv /data/kafka/logs ;chown -Rv kafka:kafka /data`
4. 以root安装JDK1.8执行命令，`yum install java-1.8.0-openjdk -y`
5. 下载kafka安装包，以zk用户操作并解压
```
su - zk
wget https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/1.1.0/kafka_2.12-1.1.0.tgz
tar -xvpf kafka_2.12-1.1.0.tgz -C /data/
```

$ cd kafka_2.10-0.8.1.1.tgz

### 配置server.properties

修改配置文件: config/server.properties 文件，主要定义以下几项配置：`broker.id listeners port log.dirs  zookeeper.connect`

* node1 参考配置 
`broker.id=1
listeners=PLAINTEXT://172.16.49.173:9092
port=9092
log.dirs=/data/kafka/logs/
zookeeper.connect=47.105.63.78:2181,118.190.201.40:2181,47.105.60.191:2181
`

* node2 参考配置 
`broker.id=2
listeners=PLAINTEXT://172.16.49.174:9092
port=9092
log.dirs=/data/kafka/logs/
zookeeper.connect=47.105.63.78:2181,118.190.201.40:2181,47.105.60.191:2181
`

* node3 参考配置 
`broker.id=3
listeners=PLAINTEXT://172.16.49.175:9092
port=9092
log.dirs=/data/kafka/logs/
zookeeper.connect=47.105.63.78:2181,118.190.201.40:2181,47.105.60.191:2181
`

备注：listeners一定要配置成为IP地址；如果配置为localhost或服务器的hostname,在使用java发送数据时就会抛出异 常：org.apache.kafka.common.errors.TimeoutException: Batch Expired 。因为在没有配置advertised.host.name 的情况下，Kafka并没有像官方文档宣称的那样改为广播我们配置的host.name，而是广播了主机配置的hostname。远端的客户端并没有配置 hosts，所以自然是连接不上这个hostname的

kafka server端config/server.properties参数说明和解释如下:（参考配置说明地址：http://blog.csdn.net/lizhitao/article/details/25667831）


### 启动


* node1: bin/kafka-server-start.sh -daemon config/server.properties 
* node2: bin/kafka-server-start.sh -daemon config/server.properties 
* node3: bin/kafka-server-start.sh -daemon config/server.properties 


## kafka 基本操作

* 创建topic `bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test`
* 验证topic是否创建成功:`bin/kafka-topics.sh --list --zookeeper localhost:2181`
* topic描述: `bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic test`
* 发送消息　kafka生产者客户端命令
  * 使用标准输入方式`bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test`
  * 从文件读取：`bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test < file-input.txt`
* 接收消息,kafka消费者客户端命令:`bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic test --from-beginning`
