# IO 测试

## fio工具的使用

IOPS 测试   : ` fio --name iops --group_reporting -rw=read -bs=4k -runtime=60 -iodepth 32 -filename /dev/sda6 -ioengine libaio -direct=1 `
文件读写测试: ` fio --name virtioblk  --group_reporting --rw=randread --bs=4k --numjobs=6 --iodepth=12 --runtime=300 --time_based --loops=1 --ioengine=libaio --direct=1 --invalidate=1 --randrepeat=1 --norandommap --exitall --filesize=5G --filename=file.data `


fio的参数说明

* rw=              读写模式，有顺序写write、顺序读read、随机写randwrite、随机读randread等。
* direct=1         测试过程绕过机器自带的buffer。使测试结果更真实。
* ioengine:        负载引擎，我们一般使用libaio，发起异步IO请求。
* bs:              单次io的块文件大小为 4k 16K ..
* bsrange=512-2048 同上，提定数据块的大小范围
* direct:          直写，绕过操作系统Cache。因为我们测试的是硬盘，而不是操作系统的Cache，所以设置为1。
* size:            寻址空间，IO会落在 [0, size)这个区间的硬盘空间上。这是一个可以影响IOPS的参数。一般设置为硬盘的大小。
* filename:        测试对象
* iodepth:         队列深度，只有使用libaio时才有意义。这是一个可以影响IOPS的参数。
* numjobs=30       本次的测试线程为30.
* runtime=1000     测试时间为1000秒，如果不写则一直将5g文件分4k每次写完为止。
* ioengine=psync   io引擎使用pync方式
* rwmixwrite=30    在混合读写的模式下，写占30%
* group_reporting  关于显示结果的，汇总每个进程的信息。

此外
lockmem=1g               只使用1g内存进行测试。
zero_buffers             用0初始化系统buffer。
nrfiles=8                每个进程生成文件的数量。

# RW 模式 

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


## DD 命令测试

dd if=/dev/zero of=/dev/sdd bs=4k count=300000 oflag=direct
dd bs=64k count=4k if=/dev/zero of=/tmp/dd-test oflag=direct 
dd bs=64k count=4k if=/dev/zero of=/tmp/dd-test oflag=dsync


如果要规避掉文件系统cache,直接读写,不使用buffer cache，需做这样的设置
iflag=direct,nonblock
oflag=direct,nonblock
iflag=cio
oflag=cio
direct 模式就是把写入请求直接封装成io 指令发到磁盘



