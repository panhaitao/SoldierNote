# Linux Net

## configuring a Linux gateway

1. 准备一个linux系统，需要两块网卡
2. 配置dhcpd server

* echo 1 > /proc/sys/net/ipv4/ip_forward 或者 echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
* modprobe iptable_nat
* iptables -F
* iptables -P INPUT ACCEPT
* iptables -P FORWARD ACCEPT
* iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE 在nat规则表中添加一个规则，该规则将所有外发的数据的源伪装成eth0接口的ip地址
* iptables -A FORWARD -i eth1 -o eth0 -s 192.168.0.0/24 -j ACCEPT
* 配置网卡
```
auto ens160
iface ens160 inet dhcp

auto ens192
iface ens192 inet static
    address 192.168.100.10
    netmask 255.255.255.0
    gateway 192.168.100.1
```
重启服务生效: systemctl restart networking 

* 配置 dhcpd

/etc/default/isc-dhcp-server INTERFACES="ens192"
/etc/dhcp/dhcpd.conf

```
option domain-name-servers 8.8.8.8, 8.8.8.4;

option subnet-mask 255.255.255.0;
option broadcast-address 192.168.100.255;
subnet 192.168.100.0 netmask 255.255.255.0 {
range 192.168.100.20 192.168.100.100;
option routers 192.168.100.10;
}
```
重启服务生效: service isc-dhcp-server restart


子网内的主机配置默认网关

route add -net 192.168.100.0/24 gw 192.168.100.10


## Configure Linux as a Static Router


1. 准备一个linux系统，需要两块网卡
2. 开启IP forwarding
3. 两块网卡配置静态IP
4. 重新配置路由
5. 添加防火墙规则


* /etc/network/interfaces

```
# Defining the first interface
auto eth0
iface <interface_name> inet static
address 192.168.190.1
netmask 255.255.255.0

# Defining the second interface
auto eth1
iface <interface_name> inet static
address 192.168.200.1
netmask 255.255.255.0
```

ip route delete <route>
ip route add 192.168.200.0/24 via 192.168.190.1
ip route add 192.168.190.0/24 via 192.168.200.1

iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT


## 参考文档

* https://www.cnblogs.com/EasonJim/p/8424731.html
* https://devconnected.com/how-to-configure-linux-as-a-static-router/#Creating_Static_Routes_using_ip
* https://www.cnblogs.com/taosim/articles/4444887.html


## 命令参考使用

* ip route 参考使用

ip route add default via 192.168.0.196   
ip route add 172.16.32.0/24 via 192.168.1.1 dev eth0                          

* route 命令使用举例

添加到主机的路由
route add -host 192.168.1.2 dev eth0 
route add -host 10.20.30.148 gw 10.20.30.40     #添加到10.20.30.148的网管

添加到网络的路由

route add -net 10.20.30.40 netmask 255.255.255.248 eth0   #添加10.20.30.40的网络
route add -net 10.20.30.48 netmask 255.255.255.248 gw 10.20.30.41 #添加10.20.30.48的网络
route add -net 192.168.1.0/24 eth1

添加默认路由

route add default gw 192.168.1.1

删除路由

route del -host 192.168.1.2 dev eth0:0
route del -host 10.20.30.148 gw 10.20.30.40
route del -net 10.20.30.40 netmask 255.255.255.248 eth0
route del -net 10.20.30.48 netmask 255.255.255.248 gw 10.20.30.41
route del -net 192.168.1.0/24 eth1
route del default gw 192.168.1.1
