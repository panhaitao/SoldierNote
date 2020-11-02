# LINUX 时间设置(待完善)

## 概念

* 系统时间和硬件时间

同步系统时间和硬件时间，可以使用hwclock命令。

* 以系统时间为基准，修改硬件时间, hwclock --systoh
* 以硬件时间为基准，修改系统时间, hwclock --hctosys

* Unix时间戳

Unix时间戳(Unix timestamp)，或称Unix时间(Unix time)、POSIX时间(POSIX time)，是一种时间表示方式，定义为从格林威治时间1970年01月01日00时00分00秒起至现在的总秒数. 在 Unix/Linux中,获取现在的Unix时间戳 date +%s, 通过Unix时间戳换算普通时间date -d @Unix timestamp 其他常用和系统时间相关的命令

* 设置时间 date -s "20120523 01:01:01"  
* 显示时间 date +"%Y/%m/%d %H:%M:%S"
* 显示纳秒 date +%s%N 

## 时间同步

### NTP 协议

chrony是一个较新ntp协议的实现程序,替代传统的ntpd

* ntpdate -d -u 172.17.30.100
* 查看同步情况 ntpq -p

### PTP

云平台节点时间同步ms级别精度做到零误差,，解决办法，使用ptp替换ntp做时间同步
     
1. 所有节点停用ntp服务，移除ntp软件包，安装 ptpd软件包，由于云平台不支持网络多播，单播模式配置可用
2. 选一个节点做主时钟，执行命令 ptpd2 -u 10.10.73.110,10.10.110.72 -i eth0 -m -C &> /tmp/log &   ###10.10.73.110,10.10.110.72 为其他节点IP
3. 其他节点做从时钟，执行命令 ptpd2 -u 10.10.36.45 -i eth0 -s -C &> /tmp/log &  ###10.10.36.45 为主时钟节点IP

### 验证

clockdiff 节点ip，可以验证节点间毫秒级时间差是多少
