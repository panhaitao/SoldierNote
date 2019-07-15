# LINUX 系统运维

## 发行版概述

## 软件包

## 日志

使用 sysvinit 或 systemd 的Linux发行版日志处理流程如下：

```
service daemon ---> rsyslog ---> /var/log
systemd --> systemd-journald --> ram DB --> rsyslog -> /var/log
```

* 系统日志（syslog）架构:
 * 进程和操作系统内核需能够为发生的事件记录日志,可用于系统审计和故障排除
 * RHEL6版本之前的日志系统基于 syslog 协议，许多程序使用此系统记录事件，默认日志存储在 /var/log 目录中
* 系统日志（systemd-journald)架构:
 * 一种改进的日志管理服务，是 syslog 的补充，收集来自内核、启动过程早期阶段、标准输出、系统日志，守护进程启动和运行期间错误的信息
 * 默认情况下，systemd将消息写入到结构化的事件日志中（数据库),保存在 /run/log/journal 中，系统重启就会清除，可以通过新建 /var/log/journal ，日志会自动记录到这个目录中，并永久存储。
 * RHEL7之后的日志系统由systemd-journald和 rsyslog 共同组成，syslog 的信息可以由 systemd-journald 转发到 rsyslog 中进一步处理,保持向后兼容

* 配置 systermd-journald 将日志 

由于RHEL7 版本之后，journald 缺省配置是 Storage=auto ，日志默认是存在内存数据库，重启会消失，可以修改/etc/systemd/journald.conf 设置配置项 Storage=persistent 重启服务systemctl restart systemd-journald.service 生效 ，可以让日志全部写入 /var/log/journal/ 目录下，不会因为系统重启而无法查看历史日志。

## 文件系统



## 内核配置 
