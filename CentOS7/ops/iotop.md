iotop概述
iotop命令是一个用来监视磁盘I/O使用状况的top类工具。iotop具有与top相似的用户界面接口，其中包括PID、用户、I/O、进程等相关信息。Linux下的IO统计工具如iostat，nmon等大多数是只能统计到每个设备的读写情况，如果你想知道每个进程是如何使用IO的就比较麻烦，使用iotop命令可以很方便的查看。 iotop使用Python语言编写而成，要求Python2.5（及以上版本）和Linux kernel2.6.20（及以上版本）。
 
iotop安装
深度服务器操作系统默认已经集成了iotop工具。
 
iotop用法
Iotop语法
iotop [OPTIONS]
 
iotop常用的OPTION及其含义如表5.8所示。
 
表5.8 iotop常用的OPTION及其含义
短参数
长参数
含义
 
--version
显示版本号信息
-h
--help
显示帮助信息
-o
--only
仅显示实际上正在操作I/O的进程或者线程，而不是全部的进程或线程，可以随时按o进行切换
-b
--batch
运行在非交互模式
-n
--iter=num
在非交互式模式下，设置显示的次数
-d
--delay
设置显示的间隔秒数，支持非整数值
-p
--pid
只显示指定PID的信息
-u
--user
显示指定的用户的进程的信息
-P
--processes
只显示进程，一般为显示所有的线程
-a
--accumulated
显示从iotop启动后每个线程完成了的IO总数
-k
--kilobytes
以千字节显示
-t
--time
在每一行前添加一个当前的时间
 
iotop命令的其他更多选项参数及其含义，用户可以直接运行man iotop即可查看。
 
iotop应用
1. root登录深度服务器操作系统，在tty1执行命令iotop，显示系统中操作磁盘I/O的进程的实时状态。
2. 切换到tty2，root执行如下命令对磁盘进行写操作，可以看到进程列表中多了一行“dd if=/dev/zero....”，并且实时监控磁盘的写速度。
cd /tmp
 	dd if=/dev/zero of=bigfile bs=1M count=5000
3. 在tty2，root执行如下命令对磁盘进行读操作，可以看到进程列表中多了一行“dd if=bigfile2....”，并且实时监控磁盘的读速度。
cd /tmp
dd if=bigfile of=/dev/null bs=1M
