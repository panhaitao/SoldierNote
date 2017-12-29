# DHCP概述

动态主机设置协议（Dynamic Host Configuration Protocol，DHCP）是一种使网络管理员能够集中管理和自动分配IP网络地址的通信协议，通常被应用在大型的局域网络环境中，主要作用是集中的管理、分配IP地址，使网络环境中的主机动态的获得IP地址、Gateway地址、DNS服务器地址等信息。

## 配置实例

* 安软件包`yum install dhcp -y`
* 修改dhcp服务器配置，编辑配置文件`/etc/dhcp/dhcpd.conf`
```
option domain-name "example.com";                # DNS服务器域名
option domain-name-servers 172.16.213.2;         # DNS服务器的IP地址
 
default-lease-time 360000;                       # 默认租约时间
max-lease-time 720000;                           # 最大租约时间
ddns-update-style none;
log-facility local7;
 
#配置地址池配置
subnet 172.16.213.0 netmask 255.255.255.0 {      # 分配的网段192.168.1.0/24
  range 172.16.213.100 172.16.213.230;           # 分配的ip地址区间；
  option routers 172.16.213.1;                   # 网关ip；
  option broadcast-address 172.16.213.255;       # 广播地址；
}
 
#指定主机给其分配ip
host boss {                                      # boss为主机名，随便取；
  hardware ethernet 00:0C:29:6C:A6:F8;           # 主机网卡的mac地址；
  fixed-address 192.168.1.10;                    # 给其分配的ip；
}

```

* 重启服务`service dhcpd restart`，
* 测试验证，在其他处于同一网络内的主机执行命令`dhclient eth0`，确认能分配得到正确配置，可以验证ＤＨＣＰ服务器工作正常，更多配置请参考`/usr/share/doc/dhcp-4.1.1/dhcpd.conf.sample`
