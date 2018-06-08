# AIX 磁盘扩容

帮朋友一个忙，操作两台 AIX UNIX ，和LINUX的命令不同，记录下


* 创建LVM物理卷              : chdev -l hdisk2 -a pv=yes
* 查看逻辑卷占用的物理设备   : lslv -l fslv00
* 迁移逻辑卷条带             : migratelv -l fslv00 hdisk2 hdisk1
* 将设备hdisk2加入卷组       : extendvg rootvg hdisk2
* 将设备hdisk2从卷组中移除   : reducevg rootvg hdisk2
* 调整逻辑卷大小             : chfs -a size=+50G /mount_dir
* 调整逻辑卷大小             : chfs -a size=-50G /mount_dir
* 设置卷组镜像               : mirrorvg -c 3 rootvg
* 取消卷组镜像               : unmirrorvg 

其他参考：

* AIX中LVM的管理:             <http://blog.csdn.net/fuwencaho/article/details/28114223>
* AIX查看CPU及内存参数:       <http://blog.csdn.net/edifierliu/article/details/7247659>
* AIX.HPUNIX,LINUX 操作对照 : <http://blog.csdn.net/silentpebble/article/details/23759223> 
* AIX LVM 在线迁移            <http://blog.chinaunix.net/uid-10091060-id-2970554.html>
