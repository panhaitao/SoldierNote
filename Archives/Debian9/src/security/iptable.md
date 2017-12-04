# 防火墙

## 防火墙的工作原理

通常意义的防火墙实际是由两个组件组成(iptables和netfilter). iptables组件是用户空间（userspace）的工具，可以方便管理插入、修改和删除防火墙规则（也就是信息包过滤表），netfilter则是内核（kernelspace）的一部分，tcp/ip协议栈必须经过的地方这些模块,netfilter模块负责读取，并处理用户空间设置的规则集，在内核空间中有5个位置定义的数据包的流向，分别是：

* 从一个网络接口进来，到另一个网络接口去的
* 数据包从内核流入用户空间的
* 数据包从用户空间流出的
* 进入/离开本机的外网接口
* 进入/离开本机的内网接口

以上提及的这五个位置也被称为五个钩子函数（hook functions）,在防火墙规则中也称为五个规则链，任何一个数据包，只要经过本机，必将经过这五个链中的其中一个链，NetFilter规定的五个规则链的描述如下：
		
* PREROUTING (路由前)
* INPUT (数据包流入口)
* FORWARD (转发管卡)
* OUTPUT(数据包出口)
* POSTROUTING（路由后） 

为了方便维护管理，引入“表”的定义来区分各种不同的工作功能和处理方式。这4个表分别描述如下：

* filter：一般的过滤功能
* nat:用于nat功能（端口映射，地址映射等）
* mangle:用于对特定数据包的修改
* raw: 设置raw时一般是为了不再让iptables做数据包的链接跟踪处理，提高性能

以上也就是通常所说iptables包含4个表，5个链。再执行iptables命令工作管理访问规则的时候，没有指定表的时候默认操作filter表。表的处理优先级：`raw>mangle>nat>filter`，其中表是按照对数据包的操作区分的，链是按照不同的Hook点来区分的，表和链实际上是netfilter的两个维度。使用比较频繁有3个表：filter，nat，mangle

* 对于filter来讲一般只能做在3个链上：INPUT ，FORWARD ，OUTPUT
* 对于nat来讲一般也只能做在3个链上：PREROUTING ，OUTPUT ，POSTROUTING
* 而mangle则是5个链都可以做：PREROUTING，INPUT，FORWARD，OUTPUT，POSTROUTING


## 防火墙的操作和管理

防火墙策略一般分为两种，一种叫“通”策略，一种叫“堵”策略，下面是两条添加规则的操作实例：


* 允许本机80端口被访问
```
iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
```

* 禁止本机90端口被访问
```
iptables -t filter -A INPUT -p tcp --dport 90 -j DROP
```

## iptables的基本语法格式

`iptables [-t 表名] 命令选项 ［链名］ ［条件匹配］ ［-j 目标动作或跳转］`

|           | table      | command   | chain     |     parameter     |  target   |
|-----------|------------|:---------:|-----------|:-----------------:|-----------|
| iptables  | -t filter  |   -A      | INPUT     | -p tcp --dport 80 | -j ACCEPT |
| iptables  | -t filter  |   -A      | INPUT     | -p tcp --dport 90 | -j DROP   |

说明：表名、链名用于指定 iptables命令所操作的表和链，命令选项用于指定管理iptables规则的方式（比如：插入、增加、删除、查看等；条件匹配用于指定对符合什么样 条件的数据包进行处理；目标动作或跳转用于指定数据包的处理方式（比如允许通过、拒绝、丢弃、跳转（Jump）给其它链处理。更多细节请参考`man iptables`


深度服务器企业版本已经已经提供更方便的服务管理方式，常用操作实例如下：
		
* `service iptables status`  # 查看防火墙运行状态
* `service iptables start`   # 启用防火墙服务
* `service iptables stop`    # 停用防火墙服务 
* `service iptables restart` # 重启防火墙服务
* `service iptables save`    # 将修改后的iptable规则存储在 `/etc/sysconfig/iptables` 中
