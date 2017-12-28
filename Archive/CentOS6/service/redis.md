
redis概述
Redis是一个开源、支持网络、基于内存、键值对存储数据库，使用ANSI C编写。从2013年5月开始，Redis的开发由Pivotal赞助。在这之前，其开发由VMware赞助。Redis是最流行的键值对存储数据库。
 
支持语言
许多语言都包含Redis支持，包括：
    ActionScript 
    C
    C++
    C#
    Clojure
 
    Common Lisp
    Dart
    Erlang
    Go
    Haskell
 
    Haxe
    Io
    Java
    Node.js
    Lua
 
 
    Objective-C
    Perl
    PHP
    Pure Data
    Python
 
    R
    Ruby
    Scala
    Smalltalk
    Tcl
 
 
数据模型
Redis的外围由一个键、值映射的字典构成。与其他非关系型数据库主要不同在于：Redis中值的类型不仅限于字符串，还支持如下抽象数据类型：
    字符串列表
    无序不重复的字符串集合
    有序不重复的字符串集合
    键、值都为字符串的哈希表
值的类型决定了值本身支持的操作。Redis支持不同无序、有序的列表，无序、有序的集合间的交集、并集等高级服务器端原子操作。
 
持久化
Redis通常将全部的数据存储在内存中。2.4版本后可配置为使用虚拟内存，一部分数据集存储在硬盘上，但这个特性废弃了。目前通过两种方式实现持久化：
    使用快照，一种半持久耐用模式。不时的将数据集以异步方式从内存以RDB格式写入硬盘。
    1.1版本开始使用更安全的AOF格式替代，一种只能追加的日志类型。将数据集修改操作记录起来。Redis能够在后台对只可追加的记录作修改来避免无限增长的日志。
 
同步
Redis支持主从同步。数据可以从主服务器向任意数量的从服务器上同步，从服务器可以是关联其他从服务器的主服务器。这使得Redis可执行单层树复制。从盘可以有意无意的对数据进行写操作。由于完全实现了发布/订阅机制，使得从数据库在任何地方同步树时，可订阅一个频道并接收主服务器完整的消息发布记录。同步对读取操作的可扩展性和数据冗余很有帮助。
 
性能
当数据依赖不再需要，Redis这种基于内存的性质，与在执行一个事务时将每个变化都写入硬盘的数据库系统相比就显得执行效率非常高。写与读操作速度没有明显差别。
 
redis的安装
在深度服务器操作系统redis服务器的安装方式有两种：
Tasksel安装方式
1. 配置好软件源，配置软件源请参考本手册的2.3节。
2. 在命令行执行tasksel命令，在打开的tasksel软件选择界面，选中“redis 	database”，光标移动到“ok/确定”按钮，敲击回车键，系统就开始安装。
 
命令行安装方式
1. 配置好软件源，配置软件源请参考本手册的2.3节。
2. 在命令行执行命令apt-get install redis-server或
aptitude install redis-server，系统就开始安装。
 
redis的简单应用
1. root登录系统，执行cp /etc/redis/redis.conf /etc/，然后分别执行如下命令启动服务,可看到redis服务已经启动。
redis-server /etc/redis.conf #读取配置文件
ps -ef|grep redis	#查看redis进程
2. 执行如下命令打开一个Redis命令行。
redis-cli
3. 执行如下命令，给数据库中名称为name的key赋予值zhangsan。
127.0.0.1:6379> set name zhangsan
127.0.0.1:6379> get name