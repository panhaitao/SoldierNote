## FIO 的基本使用
FIO是测试IOPS的非常好的工具，用来对硬件进行压力测试和验证，支持13种不同的I/O引擎，包括:sync,mmap, libaio, posixaio, SG v3, splice, null, network, syslet, guasi, solarisaio 等等。
fio 官网地址：http://freshmeat.net/projects/fio/

一，FIO安装
wget http://brick.kernel.dk/snaps/fio-2.2.5.tar.gz 

yum install libaio-devel
tar -zxvf fio-2.2.5.tar.gz
cd fio-2.2.5
make
make install

二，FIO用法：

随机读：(可直接用，向磁盘写一个2G文件，10线程，随机读1分钟，给出结果)
fio -filename=/tmp/test_randread -direct=1 -iodepth 1 -thread -rw=randread -ioengine=psync -bs=16k -size=2G -numjobs=10 -runtime=60 -group_reporting -name=mytest

说明：
filename=/dev/sdb1       测试文件名称，通常选择需要测试的盘的data目录。
direct=1                 测试过程绕过机器自带的buffer。使测试结果更真实。
rw=randwrite             测试随机写的I/O
rw=randrw                测试随机写和读的I/O
bs=16k                   单次io的块文件大小为16k
bsrange=512-2048         同上，提定数据块的大小范围
size=5g    本次的测试文件大小为5g，以每次4k的io进行测试。
numjobs=30               本次的测试线程为30.
runtime=1000             测试时间为1000秒，如果不写则一直将5g文件分4k每次写完为止。
ioengine=psync           io引擎使用pync方式
rwmixwrite=30            在混合读写的模式下，写占30%
group_reporting          关于显示结果的，汇总每个进程的信息。

此外
lockmem=1g               只使用1g内存进行测试。
zero_buffers             用0初始化系统buffer。
nrfiles=8                每个进程生成文件的数量。

 

 

read 顺序读

write 顺序写

rw,readwrite 顺序混合读写

 

randwrite 随机写

randread 随机读

randrw 随机混合读写

 

 

io总的输入输出量 

bw：带宽   KB/s 

iops：每秒钟的IO数

runt：总运行时间

lat (msec)：延迟(毫秒)

msec： 毫秒

 

usec： 微秒

 

 

 

顺序读：
fio -filename=/dev/sdb1 -direct=1 -iodepth 1 -thread -rw=read -ioengine=psync -bs=16k -size=2G -numjobs=10 -runtime=60 -group_reporting -name=mytest

随机写：
fio -filename=/dev/sdb1 -direct=1 -iodepth 1 -thread -rw=randwrite -ioengine=psync -bs=16k -size=2G -numjobs=10 -runtime=60 -group_reporting -name=mytest

顺序写：
fio -filename=/dev/sdb1 -direct=1 -iodepth 1 -thread -rw=write -ioengine=psync -bs=16k -size=2G -numjobs=10 -runtime=60 -group_reporting -name=mytest

混合随机读写：
fio -filename=/dev/sdb1 -direct=1 -iodepth 1 -thread -rw=randrw -rwmixread=70 -ioengine=psync -bs=16k -size=2G -numjobs=10 -runtime=60 -group_reporting -name=mytest -ioscheduler=noop

 

三，实际测试范例：

[root@localhost ~]# fio -filename=/dev/sdb1 -direct=1 -iodepth 1 -thread -rw=randrw -rwmixread=70 -ioengine=psync -bs=16k -size=200G -numjobs=30 -runtime=100 -group_reporting -name=mytest1
