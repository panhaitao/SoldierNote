# linux 存储IO

* io_uring 
* spdk
* libaio


## 磁盘性能指标

* 延迟（latency) ：一次I/O操作所消耗的时间
* 带宽(Bandwidth) ：单位时间内传输的数据量
* IOPS(tps)  ：每秒完成的I/O操作次数

## IO 测试工具

* fio

## fio 工具使用

* 如何使用fio的在线帮助
```
--help          ：获得帮助信息。
--cmdhelp       ：获得命令的帮助文档。
--enghelp       ：获得引擎的帮助文档。
--debug         ：通过debug方式查看测试的详细信息。（process, file, io, mem, blktrace, verify, random, parse, diskutil, job, mutex, profile, time, net, rate）
--output        ：测试结果输出到文件。
--output-format ：设置输出格式。（terse, json, normal）
--crctest       ：测试crc性能。（md5, crc64, crc32, crc32c, crc16, crc7, sha1, sha256, sha512, xxhash:）
--cpuclock-test ：CPU始终测试。
```

* FIO的IO引擎介绍：

sync（同步阻塞I/O，这是默认的），Linux下一般测试 libaio I/O引擎（Linux的native异步I/O), fio 支持19种不同的I/O引擎（可以使用 fio--enghelp 进行查看）

### 测试场景参考

* 测试IO 延迟,设置参数 -iodepth=1 -numjobs=1  用来评估存储设备最低延迟
* 测试IO 带宽,设置参数 -bs=256k -iodepth=32 -numjobs=4 用来评估存储最大带宽
* 测试IOPS,设置参数 -iodepth=128 -numjobs=4  用来评估最大IOPS
* -filename 可以指定设备文件例如 /dev/sdb 或者普通文件，分别用来评估裸设备/文件读写能力

### 单条命令方式

* IO 延迟测试
fio -direct=1 -iodepth=1 -rw=randwrite -ioengine=libaio -bs=4k -size=10G -numjobs=1 -runtime=30 -group_reporting -filename=/tmp/1

* IO 带宽测试(256k 4x32队列)
fio -direct=1 -iodepth=32 -rw=randwrite -ioengine=libaio -bs=256k -size=10G -numjobs=4 -runtime=30 -group_reporting -filename=/tmp/1

* IOPS 测试(4k 4X32队列)
fio -direct=1 -iodepth=32 -rw=randwrite -ioengine=libaio -bs=4k -size=10G -numjobs=4 -runtime=30 -group_reporting -filename=/tmp/1

### 使用配置文件方式

执行命令 fio fio.conf 配置文件参考如下:  

```
[global]
ioengine=libaio
size=500g
iodepth=1
time_based
direct=1
thread=1
group_reporting
randrepeat=0
norandommap
numjobs=1
timeout=600
runtime=300

[randrw]
rw=randrw
bs=4k
filename=/dev/vdb
rwmixread=70
rwmixwrite=30
stonewall


[randread]
rw=randread
bs=4k
filename=/dev/vdb
rwmixread=100
stonewall

[randwrite]
rw=randwrite
bs=4k
filename=/dev/vdb
stonewall

[read]
rw=read
bs=4k
filename=/dev/vdb
stonewall

[write]
rw=write
bs=4k
filename=/dev/vdb
stonewall

```

### 测试结果解读

```
#io方式，io：总的IO量, bw：带宽KB/s, iops：每秒钟的IO数, runt：总运行时间, lat (msec)：延迟(毫秒), msec毫秒, usec 微秒
  read : io=4096.0MB, bw=62504KB/s, iops=15625, runt= 67105msec

#提交延迟（submission latency）：表示需要多久将IO提交给linux的kernel做处理
    slat (usec): min=3, max=152, avg= 3.92, stdev= 1.19

#完成延迟（completion latency）：表示提交给kernel后到IO做完之间的时间，不包括submission latency，这是评估延迟性能最好指标

    clat (usec): min=19, max=39381, avg=59.45, stdev=71.22
     lat (usec): min=35, max=39384, avg=63.46, stdev=71.23

#完成延迟百分数
    clat percentiles (usec):
     |  1.00th=[   46],  5.00th=[   48], 10.00th=[   49], 20.00th=[   50],
     | 30.00th=[   50], 40.00th=[   51], 50.00th=[   57], 60.00th=[   58],
     | 70.00th=[   59], 80.00th=[   62], 90.00th=[   66], 95.00th=[   68],
     | 99.00th=[  133], 99.50th=[  434], 99.90th=[  462], 99.95th=[  466],
     | 99.99th=[  588]

#带宽
    bw (KB  /s): min=46200, max=63704, per=100.00%, avg=62509.19, stdev=2276.96

#下面三行，这是一组组数据，表示延迟，只是单位不同
    lat (usec) : 20=0.01%, 50=17.88%, 100=80.80%, 250=0.64%, 500=0.67%
        表示80.80%的request延迟小于100微秒，延迟小于50微秒的请求request占17.88%（下面也一样）
    lat (usec) : 750=0.01%, 1000=0.01%
    lat (msec) : 2=0.01%, 4=0.01%, 10=0.01%, 20=0.01%, 50=0.01%

#用户/系统CPU占用率，进程上下文切换(context switch)次数，主要和次要(major and minor)页面错误数量(page faults)。（若使用直接IO，page faults数量应该极少）
  cpu          : usr=2.03%, sys=6.82%, ctx=1048671, majf=0, minf=9

#Fio有一个iodepth设置，用来控制同一时刻发送给OS多少个IO。这完全是纯应用层面的行为，和盘的IO queue不是一回事。这里iodepth设成1，所以IO depth在全部时间都是1
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%

#submit和complete代表同一时间段内fio发送上去和已完成的IO数量。对于产生这个输出的垃圾回收测试用例来说，iodepth是默认值1，所以100%的IO在同一时刻发送1次，放在1-4栏位里。通常来说，只有iodepth大于1才需要关注这一部分数据
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued    : total=r=1048576/w=0/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=1
```

### 选项及参数说明：

```
filename=/dev/sdb1  #对整个磁盘或分区测试，也可以用于对裸设备进行测试（会损坏数据的，除非你知道你的目的，否在请不要使用）
directory=/root/ss  #对本地磁盘的某个目录进行测试（ filename | directory 二者选一）

direct=1            #测试过程绕过机器自带的buffer。使测试结果更真实。（布尔型）
rw=read             #测试顺序读的I/O，下面是可选的参数
                   （ write 顺序写 | read 顺序读 | rw,readwrite 顺序混合读写 | randwrite 随机写 | randread 随机读 | randrw 随机混合读写）
ioengine=libaio     #定义使用哪种IO，此为libaio，（默认是sync）
userspace_reap      #配合libaio，提高异步io的收割速度（只能配合libaio引擎使用）

iodepth=16          #设置IO队列的深度，表示在这个文件上同一时刻运行16个I/O，默认为1。如果ioengine采用异步方式，该参数表示一批提交保持的io单元数。
iodepth_batch=8     #当队列里面的IO数量达到8值的时候，就调用io_submit批次提交请求，然后开始调用io_getevents开始收割已经完成的IO
iodepth_batch_complete=8    #每次收割多少呢？由于收割的时候，超时时间设置为0，所以有多少已完成就算多少，最多可以收割iodepth_batch_complete值个
iodepth_low=8               #随着收割，IO队列里面的IO数就少了，那么需要补充新的IO，当IO数目降到iodepth_low值的时候，就重新填充，保证OS可以看到至少iodepth_low数目的io在电梯口排队着
thread               #fio使用线程而不是进程
bs=4k                #单次io的块文件大小为4k
bsrange=512-2048     #同上，提定数据块的大小范围（单位：字节）
size=5g              #本次的测试文件大小为5g，以每次4k的io进行测试（可以基于时间，也可以基于容量测试）
runtime=120          #测试时间为120秒，如果不定义时间，则一直将5g文件分4k每次写完为止。。
numjobs=4            #本次的测试线程为4
group_reporting      #关于显示结果的，汇总每个（线程/进程）的信息

max-jobs=10          #最大允许的作业数线程数        
rwmixwrite=30        #在混合读写的模式下，写占30%
bssplit=4k/30:8k/40:16k/30  #随机读4k文件占30%、8k占40%、16k占30%
rwmixread=70         #读占70% 
name=ceshi           #指定job的名字，在命令行中表示新启动一个job
invalidate=1         #开始io之前就失效buffer-cache（布尔型）
randrepeat=0         #设置产生的随机数是不可重复的
ioscheduler=psync    #将设备文件切换为这里指定的IO调度器（看场合使用）

lockmem=1g           #只使用1g内存进行测试。
zero_buffers         #用0初始化系统buffer。
nrfiles=8            #每个进程生成文件的数量。 
```

## 参考

* 部分文档摘录于 https://www.wsfnk.com/archives/293.html
* https://lore.kernel.org/linux-block/20190116175003.17880-1-axboe@kernel.dk/?spm=a2c6h.12873639.0.0.13aa3045smf5uA
