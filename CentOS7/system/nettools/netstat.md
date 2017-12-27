
netstat后跟不同参数时，能够显示网络连接状态、路由表、接口状态、无效连接和多播成员。
 
netstat命令有以下几种用法：
netstat  [ -vWeenNcCF] [<AF>]  -r 或：
Netstat [-vwnNcaeol] [<Socket>... ] 或：
Netstat { [-vweenNac] -i |  [ -cWnNe] -M | -s } 或
Netstat { -V |--version | h| --help}
 
netstat命令常用的参数包括-a、-c、-e、-i、-l、-v、-w、-n、-r它们的具体意义请参见表1.18。
 
表1.18 netstat命令参数说明
短参数
长参数
参数说明
-a
--all
显示所有连线中的Socket
-c
--continuous 
持续列出网络状态
-e
--extend
显示网络其他相关信息
-w
--wide
显示RAW传输协议的连线状况
-i
--interfaces 
显示网络界面信息表单
-l
--listening 
显示监控中的服务器的Socket
-n
--numeric 
直接使用IP地址，而不通过域名服务器
-r
--route 
显示Routing Table
-v
--verbose 
显示指令执行过程
 
例如运行下面命令列出所有端口：
# netstat -a
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         	State      
tcp        0      0 *:ssh                   *:*                     	LISTEN     
tcp        0      0 *:8889                  *:*                     	LISTEN     
tcp        0      0 localhost:smtp          *:*                     	LISTEN     
tcp        0      0 *:9000                  *:*                     	LISTEN     
tcp        0      0 10.1.11.240:ssh         10.1.11.245:32824       	ESTABLISHED
tcp6       0      0 [::]:ssh                [::]:*                  	LISTEN     
tcp6       0      0 localhost:smtp          [::]:*                  	LISTEN 
......
省略部分结果
 	例如运行下面命令显示网卡列表：

# netstat -i
Kernel Interface table
Iface   MTU Met   RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP 	TX-OVR Flg
eth0       1500 0     75737      0      0 0         20547      0      0      	0 BMRU
lo        65536 0    347945      0      0 0        347945      0      0      	0 LRU
 
 
netstat命令的其他参数及其意义，用户可以直接运行man netstat即可查看。
