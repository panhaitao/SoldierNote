# 简介

* 官网：http://www.elasticsearch.org

ElasticSearch是一个开源的分布式搜索引擎，具备高可靠性，支持非常多的企业级搜索用例。像Solr4一样，是基于Lucene构建的。支持时间时间索引和全文检索。它对外提供一系列基于java和http的api，用于索引、检索、修改等配置.

## 角色分配

10.10.0.1 es-node1
10.10.0.2 es-node2
10.10.0.3 es-node3

##　准备工作

分别登录主机(es-node1,es-node2,es-node3)，完成以下操作:　

1. 创建配置`/etcs/sysctl.d/es-sysctl.conf`写入`vm.max_map_count=655360`,执行`sysctl -p
` 生效
2. 修改配置`/etc/security/limits.conf`写入
\* soft nofile 65536
\* hard nofile 131072
\* soft nproc  2048
\* hard nproc  4096
3. 创建用于运行elasticsearch的用户:`useradd es`
4. 创建工作目录`mkdir /data　&& chown -Rv es:es /data`
5. 以root安装JDK1.8执行命令，`yum install java-1.8.0-openjdk -y`
6. 下载elasticsearch安装包，以es用户操作并解压
```
su - es
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.3.0.tar.gz
tar -xvpf elasticsearch-6.3.0.tar.gz 
```
### es-node1 操作 

以es用户身份,编辑配置文件 elasticsearch-6.3.0/config/elasticsearch.yml

```
cluster.name:  elasticsearch
node.name: es-node1 
network.host: 0.0.0.0
http.port: 9200
discovery.zen.ping.unicast.hosts: ["10.10.0.1", "10.10.0.2","10.10.0.3"]
```
以es用户身份启动：`su -l es -c "/data/elasticsearch-6.3.0/bin/elasticsearch -d"`

### es-node2 操作 

以es用户身份,编辑配置文件 elasticsearch-6.3.0/config/elasticsearch.yml

```
cluster.name:  elasticsearch
node.name: es-node2 
network.host: 0.0.0.0
http.port: 9200
discovery.zen.ping.unicast.hosts: ["10.10.0.1", "10.10.0.2","10.10.0.3"]
```
以es用户身份启动：`su -l es -c "/data/elasticsearch-6.3.0/bin/elasticsearch -d"`

### es-node3 操作 

以es用户身份,编辑配置文件 elasticsearch-6.3.0/config/elasticsearch.yml

```
cluster.name:  elasticsearch
node.name: es-node3 
network.host: 0.0.0.0
http.port: 9200
discovery.zen.ping.unicast.hosts: ["10.10.0.1", "10.10.0.2","10.10.0.3"]
```
以es用户身份启动：`su -l es -c "/data/elasticsearch-6.3.0/bin/elasticsearch -d"`

##  ES集群状态检查  

分别登录主机(es-node1,es-node2,es-node3)

1. 检查进程　elasticsearch 是否运行，执行命令`ps aux | grep java`　
2. 检查端口，9200,9300端口是否启用，执行命令`netstat -nat`
3. 检查日志　tail -f /data/elasticsearch-6.3.0/logs/elasticsearch.log 确认是否运行正常
4. 检查集群状态: `curl http://node_ip:9200/_cluster/health` 其中status字段提供一个综合的指标来表示集群的的服务状况。三种颜色各自的含义：
* green	    所有主要分片和复制分片都可用
* yellow1   所有主要分片可用，但不是所有复制分片都可用
* red	    不是所有的主要分片都可用

## 基本操作

**几个基本名词**
1. `index` es里的index相当于一个数据库。 
2. `type`  相当于数据库里的一个表。 
3. `id`    唯一，相当于主键。 
4. `node`  节点是es实例，一台机器可以运行多个实例，但是同一台机器上的实例在配置文件中要确保http和tcp端口不同（下面有讲）。 
5. `cluster`代表一个集群，集群中有多个节点，其中有一个会被选为主节点，这个主节点是可以通过选举产生的，主从节点是对于集群内部来说的。 
6. `shards`代表索引分片，es可以把一个完整的索引分成多个分片，这样的好处是可以把一个大的索引拆分成多个，分布到不同的节点上，构成分布式搜索。分片的数量只能在索引创建前指定，并且索引创建后不能更改。 
7. `replicas`代表索引副本，es可以设置多个索引的副本，副本的作用一是提高系统的容错性，当个某个节点某个分片损坏或丢失时可以从副本中恢复。二是提高es的查询效率，es会自动对搜索请求进行负载均衡。

