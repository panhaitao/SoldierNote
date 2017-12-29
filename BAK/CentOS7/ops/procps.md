
procps概述
procps是一个使用proc文件系统的公用软件包，而不是一个单独的应用程序。此软件包被成功安装后，安装的程序如下：
Ø slabtop	实时显示内核slab cache信息
Ø pgrep	按照匹配的选项标准查找并列出当前运行的进程
Ø skill	发送一个信号给进程
Ø top	动态实时的显示系统中进程的状态
Ø vmstat	报告关于进程、内存、页、块io、陷阱、磁盘和cpu的活动信息
Ø uptime	给出一行信息，显示系统当前时间、系统已经运行了多长时间、当前系统登录了多少个用户、在过去1分钟/5分钟/15分钟系统的平均负载
Ø watch	周期性的执行某个程序，并全屏显示其运行
Ø w.procps	显示谁登录了系统，他们正在干什么
Ø free	显示系统中可用内存和已使用内存
Ø tload	在指定tty图形化显示系统的平均负载
Ø pwdx	报告一个进程的当前工作目录
Ø pmap	报告一个进程的内存映射
Ø kill	发送一个信号给一个进程
Ø ps	系统中当前活动进程的快照
Ø sysctl	运行时修改内核参数
Ø pkill	按照匹配的选项标准查找并列出当前运行的进程
Ø snice	发送一个信号并报告进程状态
 
procps安装
深度服务器操作系统默认已经集成了procps工具。
 
procps所包含应用程序用法
slabtop语法
slabtop [options]
 
pgrep语法
pgrep [options] pattern
 
skill语法
 skill [signal] [options] expression
 
 
top语法
top -hv|-bcHiOSs -d secs -n max -u|U user -p pid -o fld -w [cols]
 
vmstat语法
vmstat [options] [delay [count]]
 
uptime语法
uptime [options]
 
watch语法
watch [options] command
 
w.procps语法
w [options] user [...]
 
free语法
free [options]
 
tload语法
tload [options] [tty]
 
pwdx语法
pwdx [options] pid [...]
pmap语法
pmap [options] pid [...]
 
kill语法
kill [options] <pid> [...]
 
ps语法
ps [options]
 
sysctl语法
sysctl [options] [variable[=value]] [...]
sysctl -p [file or regexp] [...]
 
pkill语法
pkill [options] pattern
 
snice语法
snice [new priority] [options] expression
 
 
procps所包含应用程序应用举例
实例1  显示显示某个进程的内存映射
pmap 3612(dhclient进程的pid)

