---
title: "进程与服务"
categories: 发行版
---

# 服务与守护进程

本章介绍服务和运行级别的概念，并介绍如何启动，停止和重新启动服务，并且涵盖了如何调整个服务的缺省运行级别。

## 了解守护进程和运行级别

守护进程（daemon）是指以后台方式启动，并且不能受到Shell退出影响而退出的进程。服务是一个概念，提供这些服务的程序是通常是由运行在后台的这些守护进程来执行的，大多数服务的启动脚本通常在`/etc/init.d/`目录或`/etc/xinetd.d/`目录下。

运行级别（runlevel）是为了便于系统管理而定义的概念，不同的运行级别下运行的服务数量不同，能提供的功能不同。在深度服务器企业版中存在七个运行级别（索引为0），运行级别描述如下：

* 0 : 用于停止系统。此运行级别是保留的，不能更改。
* 1 : 用于在单用户模式下运行。此运行级别是保留的，不能更改。
* 2 : 默认情况下不使用。你可以自由定义它。
* 3 : 用于使用命令行用户界面在完整的多用户模式下运行。
* 4 : 默认情况下不使用。你可以自由定义它。
* 5 : 用于以完整的多用户模式运行图形用户界面。
* 6 : 用于重新引导系统。此运行级别被保留，不能更改。

systemd 使用比 sysvinit 的运行级更为自由的 target 概念作为替代。第 3 运行级用 multi-user.target 替代。第 5 运行级用 graphical.target 替代。runlevel3.target 和 runlevel5.target 分别是指向 multi-user.target 和 graphical.target 的符号链接。systemd 用目标（target）替代了运行级别的概念，提供了更大的灵活性，如您可以继承一个已有的目标，并添加其它服务，来创建自己的目标。下表列举了 systemd 下的目标和常见 runlevel 的对应关系：

* Sysvinit 运行级别和 systemd 目标的对应表

| Sysvinit 运行级别(runlevel)	|    Systemd 目标(target)                                         |      备注                                                   |
|-------------------------------|--------------------------------------------|----------------------------------------------------------------------------------|
| 0             | runlevel0.target, poweroff.target,                         |  关闭系统                                                                        |       
| 1, s, single  | runlevel1.target, rescue.target                            |  单用户模式                                                                      |
| 2, 4          | runlevel2.target, runlevel4.target, <br> multi-user.target |  用户定义/域特定运行级别。默认等同于 3                                           |
| 3             | runlevel3.target, multi-user.target       	             |  多用户，非图形化。用户可以通过多个控制台或网络登录                              | 
| 5	        | runlevel5.target, graphical.target	                     |  多用户，图形化。通常为所有运行级别 3 的服务外加图形化登录                       |
| 6	        | runlevel6.target, reboot.target                            |  重启                                                                            |
| emergency	| emergency.target	                                     |  紧急 Shell                                                                      |


前者是符号链接指向了后面的target

```
runlevel3.target -> multi-user.target
runlevel5.target -> graphical.target
```

#切换到：运行级3 这两种都可以

```
systemctl isolate multi-user.target
systemctl isolate runlevel3.target
```

#切换到：运行级5 这两种都可以

```
systemctl isolate graphical.target
systemctl isolate runleve5.target
```
#修改开机默认运行级别systemd使用链接来指向默认的运行级别。由/etc/systemd/system/default.target文件中决定
切换到运行级3：

```
先删除:/etc/systemd/system/default.target
ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target
ln -sf /lib/systemd/system/runlevel3.target /etc/systemd/system/default.target
或 systemctl set-default multi-user.target
```

切换到运行级5

```
先删除:/etc/systemd/system/default.target
ln -sf /lib/systemd/system/graphical.target /etc/systemd/system/default.target
ln -sf /lib/systemd/system/runlevel5.target /etc/systemd/system/default.target
#用这个也可以
systemctl set-default graphical.target
```  
