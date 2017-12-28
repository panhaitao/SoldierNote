
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
