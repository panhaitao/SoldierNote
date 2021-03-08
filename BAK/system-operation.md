# LINUX 系统运维

## 发行版概述

## 软件包

## 日志

使用 sysvinit 或 systemd 的Linux发行版日志处理流程如下：

```
service daemon ---> rsyslog ---> /var/log
systemd --> systemd-journald --> ram DB --> rsyslog -> /var/log
```

### 系统日志（syslog）架构:
 * 进程和操作系统内核需能够为发生的事件记录日志,可用于系统审计和故障排除
 * RHEL6版本之前的日志系统基于 syslog 协议，许多程序使用此系统记录事件，默认日志存储在 /var/log 目录中

### 系统日志（systemd-journald)架构:
 * 一种改进的日志管理服务，是 syslog 的补充，收集来自内核、启动过程早期阶段、标准输出、系统日志，守护进程启动和运行期间错误的信息
 * 默认情况下，systemd将消息写入到结构化的事件日志中（数据库),保存在 /run/log/journal 中，系统重启就会清除，可以通过新建 /var/log/journal ，日志会自动记录到这个目录中，并永久存储。
 * RHEL7之后的日志系统由systemd-journald和 rsyslog 共同组成，syslog 的信息可以由 systemd-journald 转发到 rsyslog 中进一步处理,保持向后兼容

### 配置 systermd-journald 将日志 

由于RHEL7 版本之后，journald 缺省配置是 Storage=auto ，日志默认是存在内存数据库，重启会消失，可以修改/etc/systemd/journald.conf 设置配置项 Storage=persistent 重启服务systemctl restart systemd-journald.service 生效 ，可以让日志全部写入 /var/log/journal/ 目录下，不会因为系统重启而无法查看历史日志。

## 文件系统

### 使用mount bind 挂在迁移文件目录

```
mkdir -pv /new-dir
rsync -av /old-dir/  /new-dir
mv /old-dir/ /old-dir.bak
rm -rvf /old-dir.bak
mkdir -pv /old-dir/
mount --bind /new-dir/ /old-dir/
echo "/new-dir/ /old-dir/ none defaults,bind 0 0" >> /etc/fstab
mount -a
```
find命令（查找系统中的大文件）
获取某个目录下大于800M的所有文件

find . -type f -size +800M

如上命令所示，我们仅仅能看到超过800M大小的文件的文件名称，但是对文件的信息（例如，文件大小、文件属性）一无所知，那么能否更详细显示一些文件属性或信息呢，当然可以，使用如下命令：

find . -type f -size +800M -print0 | xargs -0 ls -l

使用df du 查询大目录
df -h; du -h --max-depth=1 /home

xfs 根分区已满，占用空间与实际使用空间不符,使用xfs工具修复
background：
某台服务器centos7，通过df查看空间基本被占满

此台机器的分区当时我偷懒，500G的空间就只划了个Boot, 划了个Swap，其他都分了/

解决过程：

使用du查询
du -sh /* 2>/dev/null | sort -hr | head -3
发现占用磁盘的文件最大只有几G，怀疑是多个小文件，然而经过查询，发现/只占用了4G的内存

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


## 内核配置 

