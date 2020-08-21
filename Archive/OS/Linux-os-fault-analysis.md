# 系统故障分析

## CPU 状态

uptime 开机运行时间
load average: 0.08, 0.09, 0.05 （系统的平均负载数，表示 1分钟、5分钟、15分钟到现在的平均数

```
* us (user CPU time)   用户空间CPU占用率）
* sy (system CPU time) 内核空间CPU占用率）
* ni (nice CPU time)   用户进程空间改变过优先级的进程CPU的占用率）
* id (idle)            空闲CPU占有率
* wa (iowait)          等待输入输出的CPU时间百分比）
* hi (hardware irq)    硬件中断请求
* si (software irq)     软件中断请求
* in：每秒的系统中断数，包括时钟中断。
* cs：系统为了处理所以任务而上下文切换的数量。
* st (steal time) 分配给运行在其它虚拟机上的任务的实际 CPU时间）
* VIRT （进程使用的虚拟内存总量，单位kb。VIRT=SWAP+RES）
* RES （进程使用的、未被换出的物理内存大小，单位kb。RES=CODE+DATA）
* SHR （共享内存大小，单位kb）
```

## 进程状态

* R (TASK_RUNNING)正在运行，或在队列中的进程
* S (TASK_INTERRUPTIBLE)，可中断的睡眠状态
* D 不可中断 Uninterruptible（通常是 IO 导致异常）
  ``` #include   void main() {  if (!vfork()) sleep(100);  } ``` 这段代码就可以模拟不可中断的进程
* T (TASK_STOPPED or TASK_TRACED)，暂停状态或跟踪状态
* Z (TASK_DEAD - EXIT_ZOMBIE)，退出状态，进程成为僵尸进程
  ``` #include   void main() {  if (fork())  while(1) sleep(100);  } ```这段代码就可以模拟僵尸进程
* W 进入内存交换（从内核2.6开始无效）
* X (TASK_DEAD - EXIT_DEAD)，退出状态，进程即将被销毁

## 内存 I/O 的状态

* total        内存总量    
* used         已经被使用的内存大小
* free         显示还有多少可用内存 
* Available    应用程序可用内存大小
* page cache   文件系统层级的缓存
* buffer cache 磁盘等块设备的缓冲
* shared 列显示被共享使用的物理内存大小。
* swap         使用的虚拟内存量。

* si：从磁盘交换的内存量（换入，从 swap 移到实际内存的内存）
* so：交换到磁盘的内存量（换出，从实际内存移动到 swap 的内存）
* bi：从块设备接收的块数
* bo：发送到块设备的块数

更多查看 /proc/meminfo free vmstat 等工具也是读取这个文件 

修改/proc/sys/vm/drop_caches的值来做到强制清除缓存
echo 1 > /proc/sys/vm/drop_caches 释放 pagecache,
echo 2 > /proc/sys/vm/drop_caches 释放 dentries  inodes, ;
echo 3 >/proc/sys/vm/drop_caches  释放 pagecache, dentries and inodes 

## TCP的网络状态

* LISTEN：侦听来自远方的TCP端口的连接请求
* SYN-SENT：再发送连接请求后等待匹配的连接请求（如果有大量这样的状态包，检查是否中招了）
* SYN-RECEIVED：再收到和发送一个连接请求后等待对方对连接请求的确认（如有大量此状态估计被flood攻击了）
* ESTABLISHED：代表一个打开的连接
* FIN-WAIT-1：等待远程TCP连接中断请求，或先前的连接中断请求的确认
* FIN-WAIT-2：从远程TCP等待连接中断请求
* CLOSE-WAIT：等待从本地用户发来的连接中断请求
* CLOSING：等待远程TCP对连接中断的确认
* LAST-ACK：等待原来的发向远程TCP的连接中断请求的确认（不是什么好东西，此项出现，检查是否被攻击）
* TIME-WAIT：等待足够的时间以确保远程TCP接收到连接中断请求的确认
* CLOSED：没有任何连接状态

* 统计当前TCP链接状态 netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}' 
* netstat -nat 
* netstat -tlnp
* netstat -tlng

## top

top 命令 实时查看系统总体负载运行状态 

# vmstat

## vmstat 常用命令

* vmstat
* vmstat -S m
* vmstat 2
* vmstat 2 10
* vmstat -a
* vmstat -d
* vmstat -D
* vmstat -p /dev/sdb1

## 常见参考诊断

1. 如果 r 经常大于cpu核心数 ，且 id 经常小于40，表示处理器的负荷很重,说明CPU不足,需要增加CPU
2. 如果 b 这个值一般为2-3倍cpu的个数就表明cpu排队比较严要了，常见的情况是由IO引起的
3. 如果 si，so 长期不等于0，表示物理内存容量太小,需要增加物理内存
4. 如果 bi, bo 这两个值比较大，说明io的压力也较大，cpu在io的等待可能也会大，
5. wa的参考值为20%，如果wa超过20%，说明I/O等待严重。
6. 如果 in cs 两个值比较大说明，说明消耗内核上cpu较多，可能应用在不合理的使用cpu

## lsof

* lsof  -i                   显示所有链接
* lsof  -i :599              显示与指定端口相关的网络信息
* lsof  -i@172.16.12.5       使用@host来显示指定到指定主机的连接
* lsof  -i -sTCP:LISTEN      找出正等候连接的端口
* lsof  -i -sTCP:ESTABLISHED 显示任何已经连接的连接
* lsof  -u ubnutu            显示指定用户打开了什么 
* lsof  -c syslog            使用-c查看指定的命令正在使用的文件和网络连接
* lsof  /var/log/messages
* lsof | grep -i delete      找出正在被删除状态的文件

## nc

* nc -vz 2 10.0.1.161 9999 查看端口是否通

## iostat/iotop/pidstat

* iotop -p $PID -d 1
* pidstat -p $PID -d 1
* iostat  查看系统总体IO读写

## iftop

iftop -i netdev

## ps 

ps -ef
ps aux

## 日志

* dmesg  -T
* journalctl -fu 服务名
* tail -f /var/log/syslog

## Linux 工具汇总

![linux-analysis-and-tools](http://www.brendangregg.com/Perf/linux_observability_tools.png)

## 场景

### 场景1 磁盘写满

系统cpu，内存，负载，未见异常，但是服务总是莫名的异常，最常见的情况也应用程序或者用户把某些分区目录或者系统目录写满了
* 用 df -h 定位分区 
* du -hs * ./ 找到子目录
* find . -type f -size +800M  找出大文件 
* 做相应处理即可，例如调整应用程序的日志或者数据写入位置，或者扩容数据分区

### 场景2 内核crash

/var/lib/crash 目录又很多文件，uptime 可见运行时间较短，系统内核反复奔溃重启，如果有能力分析，用crash工具run以下转储的core文件，跟踪中定位原因

### 场景3 内核softlock
现象 dmesg 可见如下错误信息
```
kernel:BUG: soft lockup - CPU#0 stuck for 38s! [kworker/0:1:25758]
kernel:BUG: soft lockup - CPU#7 stuck for 36s! [java:16182]
```
1. CPU太忙或磁盘IO太高，
2. 内核bug导致，升级内核修复

### 场景4 内核hard lock

硬件死锁，只在国产cpu见过，硬件设计原因，从内核层面修改代码只能降低几率，无法杜绝

### 场景5 IO死锁

top 查看系统负载非常高，free查看内存正常, cpu 总体使用率未见明显异常 

ps -ef | grep  D  可见异常进程，这个进程无法杀死，只能重启主机
1. 如果这个进程是业务应用，基本可以判定是应用程序逻辑错误导致的IO死锁，联系对应开发人员调试跟踪
2. 如果这个进程是系统应用，也可能是高IO负载导致的异常，比如 遇见rsync的方式 删除某个TB级别的分区下的大量子目录，结果触发IO死锁

### 场景6 linux hung 住

dmesg 频繁可见
echo 0 > /proc/sys/kernel/hung_task_timeout_secs disables this message

默认情况下， Linux会最多使用40%的可用内存作为文件系统缓存。当超过这个阈值后，文件系统会把将缓存中的内存全部写入磁盘， 导致后续的IO请求都是同步的。

将缓存写入磁盘时，有一个默认120秒的超时时间。 出现上面的问题的原因是IO子系统的处理速度不够快，不能在120秒将缓存中的数据全部写入磁盘。IO系统响应缓慢，导致越来越多的请求堆积，最终系统内存全部被占用，导致系统失去响应。 

缓解办法：

调整如下两个参数:

sysctl -w vm.dirty_ratio=10
sysctl -w vm.dirty_background_ratio=5
sysctl -p

vm.dirty_ratio:指定了当文件系统缓存脏页数量达到系统内存百分之多少时（如10%），系统开始处理缓存脏页，将数据写入硬盘等外部存储，在此过程中很多应用进程可能会因为系统转而处理文件IO而阻塞。

vm.dirty_background_ratio:这个参数指定了当文件系统缓存脏页数量达到系统内存百分之多少时（如5%）就会触发pdflush/flush/kdmflush等后台回写进程运行，将一定缓存的脏页异步地刷入外存；

### 场景7 Dmesg可见OOM

从 RHEL /var/log/message 或者 Debian /var/log/syslog 中
或者 Dmesg 不短刷出信息，Out of Memory: Killed process [PID] [process name]. 

根据内核打印的信息，初步判断是什么类型的进程，如果系统内存资源充足，是只是应用 oom 找到 适当调大应用配置，增加可以资源限制即可 比如 java应用比较常见，更改jvm参数即可  

### 场景8 应用内存泄漏

还有一种，free查看内存可用的不多，top查看找不到内存占用高的，cpu使用率不高，系统负载无异常，重启之后，过段时间还是慢慢发现内存不组，那很可能就是应用程序内存泄漏了，最笨的用排除法找到具体的业务应用


# 参考部分

* http://www.brendangregg.com/linuxperf.html
* https://ysshao.cn/Linux/Linux_performance/
* https://blog.csdn.net/wufaliang003/article/details/102382117

