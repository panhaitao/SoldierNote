1.3.1 ss工具

ss是Socket Statistics的缩写。顾名思义，ss命令可以用来获取socket统计信息，它可以显示和netstat类似的内容。但ss的优势在于它能够比其他工具显示更多更详细的有关TCP和连接状态的信息，而且比netstat更快速更高效。
 
当服务器的socket连接数量变得非常大（如上万个）时，无论是使用netstat命令还是直接cat /proc/net/tcp，执行速度都会很慢，而用ss才是节省时间的。ss快的原因在于，它利用到了TCP协议栈中tcp_diag。tcp_diag是一个用于分析统计的模块，可以获得Linux 内核中第一手的信息，这就确保了ss的快捷高效。当然，如果你的系统中没有tcp_diag，ss也可以正常运行，只是效率会变得稍慢。
 
 
ss命令语法
深度服务器操作系统中管理员用户可使用ss命令获取socket的统计信息。其具体语法如下
ss的一般用法是 ss [options] [ FILTER ]
，其中在没有option选项的情况下，ss被用来显示一个打开的已经建立连接而非监听	TCP sockets的列表。
 
ss命令常用的参数及其意义如表1.3所示。
 
表1.3 ss命令option参数说明
短参数
长参数
参数说明
-h
--help
 
显示选项概要信息
-V
--version
输出版本信息
-n
--numeric
不解析服务名称
-r
--resolve
解析数字化地址/端口
-a
--all
既显示监听又显示非监听（对TCP这意味着已经建立了连接）的sockets套接字
-l
--listening
仅显示监听的sockets套接字（这是缺省默认）
-o
--options
显示计时器信息
-e
--extended
显示详细的套接字（socket）详细
-m
--memory
显示套接字（socket）的内存使用情况
-p
--processes
显示使用套接字（socket）的进程
-i 
--info
显示TCP内部信息
-s
--summary
显示套接字(socket)的使用概况
-b
--bpf
 
-4
--ipv4
仅显示ipv4的套接字（socket）
-6
--ipv6
仅显示ipv6的套接字（socket）
-t
--tcp
仅显示TCP套接字（socket）
-u
--udp
仅显示UDP套接字（socket）
-d
--dccp
显示dccp套接字（socket）
-w
--raw
显示RAW套接字（socket）
-x
--unix
显示unix域套接字（socket）
-f
--family=FAMILY
显示family类型套接字（socket），目前支持下列family类型套接字： unix, inet, inet6, link, netlink.
 
-A
--query=QUERY,--socket=QUERY
指定要列出的套接字列表，通过逗号分隔。可以识别下面的标识符：all, inet, tcp, udp,raw,unix,packet,netlink,unix_dgram,unix_stream,unix_seqpacket,              packet_raw, packet_dgram
 
-D
--diag=FILE
将原始TCP套接字（sockets）信息转储到文件
-F
--filter=FILE
从文件中读取过滤器信息
 
 
ss简单用法举例
例如运行如下命令，显示所有的TCP/UDP/RAW/UNIX socket：
ss -a {{-t/-u/-w/-x}}
 
运行如下命令，显示所有TCP套接字
ss -t -a
 
运行如下命令，显示所有已建立完成ssh连接的的套接字
ss -o state established '( dport = :ssh or sport = :ssh )'
 
例如运行如下命令，查找所有本地连接X server的进程
ss -x src /tmp/.X11-unix/*
 
ss命令的其他参数及其意义，用户可以直接运行man ss即可查看。