# 网络管理

## 设置主机名

为了便于区分主机，设置主机名是服务器管理的基础工作之一，更改主机名请更改/etc/sysconfig/network文件，参考实例如下,更多配置参考`man hostname`：

```
HOSTNAME = deepin.example.com 
```
 
关于修改主机名的建议：
* 主机名与DNS中用于机器的完全限定域名（FQDN）匹配，如host.example.com。
* 主机名仅由7位ASCII小写字符组成，不含空格或点，并将其自身限制为DNS域名标签允许的格式，不允许下划线。


## 域名解析

/etc/hosts 配置文件是用来把主机名字映射到IP地址的方法，但只是本地机查询,适合简单的管理数量不多的主机，添加一条主机名解析的实例如下：

```
192.168.1.1 deepin.example.com 
```

/etc/resolv.conf 是DNS客户机配置文件，用于设置DNS服务器的IP地址及DNS域名，还包含了主机的域名搜索顺序。该文件是由域名解析器（resolver，一个根据主机名解析IP地址的库）使用的配置文件。参考实例如下：

```
domain example.com
search example.com localdomain
nameserver 10.0.0.1
```

参数及其意义：

* nameserver 设置DNS服务器的IP地址，nameserver可以设置多个，在查询时就按nameserver在本文件中的顺序进行，且只有当第一个nameserver没有反应时才查询下面的nameserver
* domain　　　声明主机的域名，很多程序用到它，如邮件系统；当为没有域名的主机进行DNS查询时，也要用到。如果没有域名，主机名将被使用，删除所有在第一个点( .)前面的内容。 
* search　　　当提供了一个不包括完全域名的主机名时，在该主机名后添加声明的域（以上例子中是example.com）作为后缀 

深度服务器企业版没有提供缺省的/etc/resolv.conf文件，它的内容是依据当前网络动态创建的,更多配置参考`man resolv.conf`.


## 主机的FQDN解析顺序

名称切换服务（Name Service Switch 通常缩写为 NSS) 这个服务规定了通过哪些途径以及按照什么顺序通过这些途径来查询特定类型的信息。还可以指定某个方法奏效或失效时系统将采取什么动作
`/etc/nsswitch.conf` 是这个服务的配置文件，其中和主机名查询相关的配置如下： 

```
hosts: files dns
```
配置声明查询主机的FQDN依次从`/etc/hosts`，`/etc/resolv.conf`定义的配置中获取结果，如果查询成功将直接返回，不再继续查询。也就是`/etc/hosts`中的主机名相关的配置会覆盖DNS服务器中的记录，更过配置参考`man nsswitch.conf `.

### 网络配置文件 

用于激活和停用这些网络接口的脚本和配置文件位于/etc/sysconfig/network-scripts/目录中。这些文件通常命名为ifcfg-name，其中name是指配置文件控制的设备的名称。最常见的接口配置文件之一是`/etc/sysconfig/network-scripts/ifcfg-eth0`，它控制系统中的第一个以太网接口卡或NIC。在具有多个NIC的系统中，有多个ifcfg-ethX文件（其中X是与特定接口对应的唯一编号）。接口配置文件控制各个网络设备的软件接口。系统启动时，它将使用这些文件来确定要引导的接口以及如何配置它们。因为每个设备都有自己的配置文件，管理员可以控制每个接口的功能。以下是使用固定IP地址的系统的ifcfg-eth0文件示例：
 
```
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
IPADDR=192.168.1.100
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
USERCTL=no
``` 
配置文件中所需的值可以根据其他值进行更改。例如，使用DHCP的接口的ifcfg-eth0文件看起来是不同的，因为IP信息是由DHCP服务器提供的： 

```
DEVICE=eth0
BOOTPROTO=dhcp
ONBOOT=yes
``` 
其中各个配置参考如下,更多配置请阅读`/usr/share/doc/initscripts-9.03.53/sysconfig.txt`：
```
DEVICE=物理设备名
IPADDR=IP地址
NETMASK=掩码值
GATEWAY=网关地址
ONBOOT=[yes|no]（引导时是否激活设备）
USERCTL=[yes|no]（非root用户是否可以控制该设备）
BOOTPROTO=[none|static|bootp|dhcp]（引导时不使用协议|静态分配|BOOTP协议|DHCP协议）
HWADDR = 你的MAC地址
```

可以执行命令`service network restart`来重启网络服务，有关启动，停止和管理服务和运行级别的更多信息，请参阅服务和守护程序。

