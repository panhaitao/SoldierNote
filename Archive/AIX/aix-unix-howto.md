# AIX 磁盘扩容

帮朋友一个忙，操作两台 AIX UNIX ，和LINUX的命令不同，记录下


* 创建LVM物理卷 : chdev -l hdisk2 -a pv=yes
* 加入LVM卷组   : extendvg rootvg hdisk2
* 调整逻辑卷大小: chfs -a size=+50G /mount_dir
* 设置卷组镜像  : mirrorvg -c 3 rootvg
* 取消卷组镜像  : unmirrorvg 

其他参考：

* AIX中LVM的管理:       <http://blog.csdn.net/fuwencaho/article/details/28114223>
* AIX查看CPU及内存参数: <http://blog.csdn.net/edifierliu/article/details/7247659>
