# 查找系统中的大文件

## 查找找到占用空间大的目录　

1. du -alh --max-depth 1 ./　需要逐级分析判断, 找到大文件的路径，确认用途，不需要的可以删掉
2. 分析根分区目录空间占用，排除proc,dev, run 等目录： du -alh --max-depth=1 / --exclude=/proc --exclude=/run --exclude=/dev
3. 分析/var/lib/目录空间占用, 排除docker kubelet等目录: du -alh --max-depth=1 /var/lib/ --exclude=/var/lib/docker --exclude=/var/lib/kubelet

## 获取某个目录下大于800M的所有文件 

1. find . -type f -size +800M `

如上命令所示，我们仅仅能看到超过800M大小的文件的文件名称，但是对文件的信息（例如，文件大小、文件属性）一无所知，那么能否更详细显示一些文件属性或信息呢，当然可以，使用如下命令：

2. find . -type f -size +800M -print0 | xargs -0 ls -l

## xfs 根分区已满，占用空间与实际使用空间不符,使用xfs工具修复

某台服务器centos7，通过df查看空间基本被占满

解决过程：

使用du查询 du -sh /* 2>/dev/null | sort -hr | head -3 发现占用磁盘的文件最大只有几G，怀疑是多个小文件，然而经过查询，发现/只占用了4G的内存
查资料发现网上大多数的都说是进程打开的正在使用的文件被删除，没有释放
我执行lsof命令发现根本不是这个问题
怀疑是文件系统出了问题，通过 df -aT查看到/挂载点使用的文件系统是xfs

首先安装xfs工具
yum install xfsdump
yum install xfsprogs-devel
yum install xfsprogs

检测/分区的碎片
xfs_db -c frag -r /dev/sda3
显示的数据是10%左右，尝试使用修复整理碎片

xfs_fsr /dev/sda3
再次查看，发现文件系统正常恢复
原挂载点仍有数据也可能导致看起来磁盘空间占用异常

是关于挂载点的问题。那个挂载点原先就有122G的数据，负责管理的人，没有把其上的数据移除，就挂载了新的硬盘，所以就给觉得磁盘好像无形中被占用似的。希望后来人在遇到跟我相似的问题，不用像我这样头疼了


磁盘：

docker镜像
　　删除机器上没有被容器使用的本地docker镜像。执行命令： docker rmi $(docker images -q)

容器内部
　　找到容器中大文件的位置，一般都是容器中的日志文件比较大（ var/log/mathilde）　

　　以.log结尾的，只能清空不能删除文件

　　以.log后跟数字的可以删除文件

关于es服务器磁盘处理参考办法

　　rm -rf log-2017041*
　　rm -rf metric-2017041*
　　rm -rf .marvel-2017.04.1*
　　rm -rf event-2017041*

json-file格式 ES日志处理方法: echo "" > /var/lib/docker/containers/containerID/containerID-json.log
