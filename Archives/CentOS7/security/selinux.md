---
title: "SELINUX基础"
categories: CentOS7
tags: 系统管理
---

# SElinux

SELinux（全称 Security Enhanced Linux）是基于LSM(Linux Security Modules)的一种实现方式，提供了一种灵活的强制访问控制(MAC)系统，且内嵌于Linux Kernel中。SELinux定义了系统中每个用户、进程、应用和文件的访问和转变的权限，然后它使用一个安全策略来控制这些实体(用户、进程、应用和文件)之间的交互，安全策略指定如何严格或宽松地进行检查。

强制访问控制系统的用途在于增强系统抵御 0-Day 攻击(利用尚未公开的漏洞实现的攻击行为)的能力。所以它不是网络防火墙或 ACL 的替代品，在用途上也不重复。举例来说，系统上的 Apache 被发现存在一个漏洞，使得某远程用户可以访问系统上的敏感文件(比如 /etc/passwd 来获得系统已存在用户)，而修复该安全漏洞的 Apache 更新补丁尚未释出。此时 SELinux 可以起到弥补该漏洞的缓和方案。因为 /etc/passwd 不具有 Apache 的访问标签，所以 Apache 对于 /etc/passwd 的访问会被 SELinux 阻止。

相比其他强制性访问控制系统，SELinux 有如下优势：

* 控制策略是可查询而非程序不可见的。
* 可以热更改策略而无需重启或者停止服务。
* 可以从进程初始化、继承和程序执行三个方面通过策略进行控制。
* 控制范围覆盖文件系统、目录、文件、文件启动描述符、端口、消息接口和网络接口。

另外，开启SELinux的会给系统带来一定的性能损失，

## 获取当前 SELinux 运行状态

执行命令：`getenforce`

可能返回结果有三种：Enforcing、Permissive 和 Disabled。

* Disabled   代表 SELinux 被禁用
* Permissive 代表仅记录安全警告但不阻止可疑行为，
* Enforcing  代表记录警告且阻止可疑行为。

可以通过执行`ls –Z |ps –Z | id –Z`来查看文件、进程和用户的SELinx属性。最常用的是`ls -Z`.

## 改变 SELinux 运行状态

执行命令： `setenforce Enforcing` 或 `setenforce Permissive`

该命令可以立刻改变 SELinux 运行状态，在 Enforcing 和 Permissive 之间切换，结果保持至关机。若是想要永久变更系统 SELinux 运行环境，可以通过更改配置文件 /etc/sysconfig/selinux 实现。注意当从 Disabled 切换到 Permissive 或者 Enforcing 模式后需要重启计算机并为整个文件系统重新创建安全标签(touch /.autorelabel && reboot)。

## SELinux 运行策略

配置文件 /etc/sysconfig/selinux 还包含了 SELinux 运行策略的信息，通过改变变量 SELINUXTYPE 的值实现，该值有两种可能：

* targeted 代表仅针对预制的几种网络服务和访问请求使用 SELinux 保护
* strict 代表所有网络服务和访问请求都要经过 SELinux。

深度服务器操作系统默认设置为 targeted，包含了对几乎所有常见网络服务的SELinux策略配置，已经默认安装并且可以无需修改直接使用。


## Apache SELinux 配置实例一，让 Apache 可以访问位于非默认目录下的网站文件


执行命令`ls -Z /var/ | grep www` 获知默认Apache网站根目录 `/var/www`SELinux 上下文：

```
drwxr-xr-x. root root system_u:object_r:httpd_sys_content_t:s0 www
```

从中可以看到 Apache 只能访问包含 httpd_sys_content_t 标签的文件。假设希望 Apache 使用 /srv/www 作为网站文件目录，完成如下操作：
```
chcon -t httpd_sys_content_t /srv/www/ # 目录下的文件添加默认标签类型
restorecon -Rv /srv/www                # 起到恢复文件默认标签的作用 
```
然后更改Apache 配置，重启服务就可以使用该目录下的文件构建网站了。


## Apache SELinux 配置实例二：让 Apache 侦听非标准端口

首先执行命令安装 `yum install policycoreutils-python -y` SELinux 管理配置工具

1. 添加一个888端口为例，执行命令`semanage port -a -t http_port_t -p tcp 888`
2. 执行完毕后`semanage port -l|grep http`来确认
```
[root@deepin-server ~]# semanage port -l|grep http_port_t
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
```
然后更改Apache 配置，重启服务就可以使用888端口来发访问Web服务器了。更多详细内容参考 `man semanage`手册


