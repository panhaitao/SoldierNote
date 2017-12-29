ient 就和它名字一样，用来通过 dhcp 协议配置本机的网络接口。
 
dhclient的一般用法：
dhclient  [  -4 | -6 ] [ -S ] [ -N [ -N...  ] ] [ -T [ -T...  ] ] [ -P [-P...  ] ] [ -i ] [ -I ] [ -D LL|LLT ] [ -p port-number ] [ -d ]  [ -df duid-lease-file  ]  [  -e  VAR=value  ]  [ -q ] [ -1 ] [ -r | -x ] [ -lf lease-file ] [ -pf pid-file ] [ --no-pid ] [ -cf  config-file  ]  [  -sf script-file ] [ -s server-addr ] [ -g relay ] [ -n ] [ -nw ] [ -w ] [ -v ] [ --version ] [ if0 [ ...ifN ] ]
 
其中ifN 就是 ifconfig 中输出的接口名称,如eth0,wlan0 ...
 
dhclient常用的参数包括-d、-nw、-q、-4、-6、-1、-r、-x，它们的意义如表1.13所示。
 
 
表1.13 dhclient命令常用参数说明
短参数
长参数
参数说明
-d
 
强制dhclient作为一个前台程序运行
-nw
 
即时守护进程而不是等待获得ip地址
-q
 
安静启动方式，这是默认的
-4
 
指定使用的网络层协议是IPv4协议
-6
 
指定使用的网络层协议是IPv6协议
-1
 
尝试获得一次租赁
-r
 
释放当前租赁，停止运行的DHCP客户端之前先记录到控制文件。
-x
 
停止运行的DHCP客户端，但不释放当前租赁
-p
 
DHCP客户端应该监听和传递UDP端口号。
 
例如指定dhclient 只支持 ipv4协议，命令如下：
#dhclient -4 eth0
 
例如运行下面命令释放当前ip：
#dhclient -r
 
dhclient 命令的其他参数及其意义，用户可以直接运行man dhclient 即可查看。
 
route工具程序  
在深度服务器操作系统中管理员用户可以使用route显示或操作ip路由表。
 
route的一般用法： 
route [-CFvnee] 
 
或:route  [-v] [-A family] add [-net|-host] target [netmask Nm] [gw Gw] [metric N] [mss M] [window W] [irtt I] [reject] [mod] [dyn] [reinstate] [[dev] If] 
 
或：route  [-v] [-A family] del [-net|-host] target [gw Gw] [netmask Nm] [metric N] [[dev] If] 
 
或：route  [-V] [--version] [-h] [--help]
 
其中，route add--命令，可以将新路由项目添加给路由表；route delete--命令可以从路由表中删除路由。
 
route常用的参数包括-c、-n、-v、-F、-e、del、add。它们的意义如表1.14所示。
 
表1.14 route命令参数说明
短参数
长参数
参数说明
-F
 
显示发送信息
-C
 
显示路由缓存
-v
 
显示详细的处理信息
-n
 
不解析名字
-e
 
显示更多信息
del
 
删除一条路由
add
 
添加一条新路由
target
 
目标网络或主机
-net
 
目标地址是一个网络
gw GW
 
路由数据包通过网关。注意，你指定的网关必须能够达到
host
 
目标地址是一个主机
 
例如添加网关/设置网关:
#route add -net 224.0.0.0 netmask 240.0.0.0 dev eth0
#route
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    	Use Iface
default         gateway.bj.sndu 0.0.0.0         UG    1024   0        	0 eth0
10.1.11.0       *               255.255.255.0   U     0      0        	0 eth0
224.0.0.0       *               240.0.0.0       U     0      0        	0 eth0
 
例如删除路由记录:
#route del -net 224.0.0.0 netmask 240.0.0.0
#route
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    	Use Iface
default         gateway.bj.sndu 0.0.0.0         UG    1024   0        	0 eth0
10.1.11.0       *               255.255.255.0   U     0      0        	0 eth0
route命令的其他参数及其意义，用户可以直接运行man route即可查看。
