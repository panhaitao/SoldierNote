# linux 存储IO

* io_uring 
* spdk
* libaio

## IO Bench

* 延迟测试
fio -direct=1 -iodepth=1 -rw=randwrite -ioengine=libaio -bs=4k -size=1G -numjobs=1 -runtime=30 -group_reporting -name=/tmp/1

* 吞吐性能测试(4k 4x32队列)
fio -direct=1 -iodepth=32 -rw=randwrite -ioengine=libaio -bs=4k -size=1G -numjobs=4 -runtime=30 -group_reporting -name=/tmp/1

* IOPS 测试(4k 4X32队列)
fio -direct=1 -iodepth=32 -rw=randwrite -ioengine=libaio -bs=4k -size=1G -numjobs=4 -runtime=30 -group_reporting -name=/tmp/1


## 参考

https://lore.kernel.org/linux-block/20190116175003.17880-1-axboe@kernel.dk/?spm=a2c6h.12873639.0.0.13aa3045smf5uA
