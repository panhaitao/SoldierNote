# Hadoop HDFS 简介 

当数据集超过一个单独的物理计算机的存储能力时，便有必要将它分不到多个独立的计算机上。管理着跨计算机网络存储的文件系统称为分布式文件系统。Hadoop 的分布式文件系统称为 HDFS，它是为以流式数据访问模式存储超大文件而设计的文件系统。

* “超大文件”是指几百 TB 大小甚至 PB 级的数据；
* 流式数据访问：HDFS 建立在这样一个思想上
* 一次写入、多次读取的模式是最高效的。一个数据集通常由数据源生成或者复制，接着在此基础上进行各种各样的分析。
* HDFS 是为了达到高数据吞吐量而优化的，这有可能以延迟为代价。对于低延迟访问，HBase是更好的选择。
* 商用硬件：即各种零售店都能买到的普通硬件。这种集群的节点故障率蛮高，HDFS需要能应对这种故障。

HDFS 不合适某些领域：

* 低延迟数据访问：需要低延迟数据访问在毫秒范围内的应用不合适 HDFS
* 大量的小文件：HDFS 的 NameNode 存储着文件系统的元数据，因此文件数量的限制也由NameNode 的内存量决定。
* 多用户写入、任意修改文件：HDFS 中的文件只有一个写入者，而且写操作总是在文件的末尾。它不支持多个写入者，或者在文件的任意位置修改。

## 角色分配和基本信息

| 主机名      |    IP　        |  角色 　 |　
|-------------|----------------|----------|
| name-node1  | 172.31.150.244 | NameNode |
| data-node1  | 172.31.150.245 | DataNode |
| data-node2  | 172.31.150.246 | DataNode |
| data-node3  | 172.31.150.247 | DataNode |


* HDFS部分术语:
  * NameNode  ：管理节点
  * DataNode  ：数据节点
  * SecondaryNamenode : 数据源信息备份整理节点
* HDFS 配置文件
  * core-site.xml	 common属性配置
  * hdfs-site.xml    HDFS属性配置
  * hadoop-env.sh    hadooop 环境变量配置
* HDFS 配置文件
  * HDFS 管理界面: 50070
  * HDFS 通信端口 : 9000

## 准备工作

* 所有主机
  1. 创建Hadoop 用户 `useradd hdfs`
  2. 创建工作目录`mkdir -pv /data/hadoop/{tmp,hdfs/{name,data}} ; chown -Rv hdfs:hdfs /data`
  3. 以root安装JDK1.8执行命令，`yum install java-1.8.0-openjdk -y`
  4. 下载hadoop二进制包
`su - hdfs
wget http://www.apache.org/dyn/closer.cgi/hadoop/common/hadoop-3.0.3/hadoop-3.0.3.tar.gz
tar -xpvf hadoop-3.0.3.tar.gz -C /data
`
  5. 编辑 
cat >> /etc/hosts << EOF 
172.31.150.244 name-node1
172.31.150.245 data-node1
172.31.150.246 data-node2
172.31.150.247 data-node3 
EOF

* namenode主机
  `
  su - hdfs 
  ssh-keygen
  ssh-copy-id hdfs@data-node1
  ssh-copy-id hdfs@data-node2
  ssh-copy-id hdfs@data-node3
  `
			
### 修改配置 hadoop-env.sh 添加
`
JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.171-8.b10.el7_5.x86_64/jre/
`

### 修改 core-site.xml 添加

```
  <configuration>
        <property>
             <name>fs.default.name</name>
             <value>hdfs://name-node1:9000</value>
        </property>
        <property>
             <name>hadoop.tmp.dir</name>
             <value>/data/hadoop/tmp/</value>
        </property>
    </configuration>
```

配置项解释

* fs.default.name: NameNode的URI。hdfs://主机名:端口/
* hadoop.tmp.dir: Hadoop的默认临时路径
* mapred.job.tracker: JobTracker的主机和端口。

### 修改配置文件 hdfs-site.xml

```
    <configuration>
        <property>
            <name>dfs.name.dir</name>
            <value>/data/hadoop/hdfs/name</value>
            <description>  </description>
        </property>
        <property>
            <name>dfs.data.dir</name>
            <value>/data/hadoop/hdfs/data</value>
            <description> </description>
        </property>
        <property>
            <name>dfs.replication</name>
            <value>3</value>
        </property>
    </configuration>
```
配置项解释

* dfs.name.dir: NameNode持久存储名字空间及事务日志的本地文件系统路径。当这个值是一个逗号分割的目录列表时，nametable数据将会被复制到所有目录中做冗余备份。
* dfs.data.dir是DataNode存放块数据的本地文件系统路径，逗号分割的列表。当这个值是逗号分割的目录列表时，数据将被存储在所有目录下，通常分布在不同设备上。
* dfs.replication是数据需要备份的数量，默认是3，如果此数大于集群的机器数会出错。

### 配置masters和workers结点
`
cat > etc/hadoop/masters <<EOF
name-node1
EOF
`					
   
` 					
cat > etc/hadoop/workers <<EOF
data-node1
data-node2
data-node2
EOF
`
### 复制配置文件

```
cd /data/hadoop-3.0.3/etc/hadoop/
scp hadoop-env.sh core-site.xml hdfs-site.xml masters workers root@data-node1:/data/hadoop-3.0.3/etc/hadoop/
scp hadoop-env.sh core-site.xml hdfs-site.xml masters workers root@data-node2:/data/hadoop-3.0.3/etc/hadoop/
scp hadoop-env.sh core-site.xml hdfs-site.xml masters workers root@data-node3:/data/hadoop-3.0.3/etc/hadoop/
```    					

### 启动 Hadoop hdfs

1. 格式化HDFS文件系统
`export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.171-8.b10.el7_5.x86_64/jre/
/data/hadoop-3.0.3/bin/hdfs namenode -format
`
2. 启动集群`/data/hadoop-3.0.3/sbin/start-dfs.sh`

### HDFS集群基本操作

查看集群状态 : `/data/hadoop-3.0.3/bin/hdfs dfsadmin -report`
列出根目录: `/data/hadoop-3.0.3/bin/hadoop fs -ls  /`
创建目录: `/data/hadoop-3.0.3/bin/hadoop fs -mkdir /data`
上传文件: `/data/hadoop-3.0.3/bin/hadoop fs -put data_file /`
下载文件: `/data/hadoop-3.0.3/bin/hadoop fs /data_file /data`
删除目录: `/data/hadoop-3.0.3/bin/hadoop fs -rm -r /data`


## 参考

官方文档

* https://hadoop.apache.org/docs/r3.1.0/hadoop-project-dist/hadoop-hdfs/HdfsDesign.html
* https://hadoop.apache.org/docs/r3.1.0/hadoop-project-dist/hadoop-hdfs/WebHDFS.html#HDFS_Configuration_Options

博客

* http://www.cnblogs.com/sammyliu/p/4396225.html
* https://www.jianshu.com/p/8621529e0cc5


