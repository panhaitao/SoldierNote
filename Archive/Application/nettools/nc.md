
nc（netcat)，在网络工具中有“瑞士军刀”美誉，因为它短小精悍，功能实用，被设计为一个简单、可靠的网络工具，可通过TCP或UDP协议传输读写数据。同时，它还是一个网络应用Debug分析器，因为它可以根据需要创建各种不同类型的网络连接。
 
nc命令的有以下用法。
想要连接到某处:  nc [-options] hostname port[s] [ports] ... 
绑定端口等待连接:  nc -l -p port [-options] [hostname] [port] 
 
nc命令常用的参数包括-l、-p、-r、-v、-w、-p、-z，它们的具体意义请参见表1.19。
 
表1.19 nc命令参数说明
短参数
长参数
参数说明
-l
 
监听模式，用于入站连接
-p
 
port 本地端口号想要连接到某处:  nc [-options] hostname port[s] [ports] ... 
绑定端口等待连接:  nc -l -p port [-options] [hostname] [port] 
 
-r
 
任意指定本地及远程端口
-v
 
可得到更详细的内容
-w
 
secs timeout的时间
-p
 
port 本地端口号
-z
 
将输入输出关掉——用于扫描时，其中端口号可以指定一个或者用lo-hi式的指定范围。
wget [选项] ...[URL]... 
 
例如常见的使用方法是远程拷贝文件，从server1拷贝文件到server2上。需要先在server2上，用nc激活监听，
server2上运行： nc -l -p 1234 > testfile   
server1上运行： nc 10.1.11.240 1234 < test1.txt
注：server2上的监听要先打开(命令必须是nc -l -p 因nc命令链接到/bin/nc.traditional),这样server2上的test1.txt文件的内容就被传输到server2上testfile中了。
 
nc命令的其他参数及其意义，用户可以直接运行man nc即可查看。
