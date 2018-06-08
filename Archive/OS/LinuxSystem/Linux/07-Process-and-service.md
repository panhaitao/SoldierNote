# Linux系统-第七章: 进程与服务

本章介绍服务和运行级别的概念，并介绍如何启动，停止和重新启动服务，并且涵盖了如何调整个服务的缺省运行级别。

## 了解守护进程和运行级别

守护进程（daemon）是指以后台方式启动，并且不能受到Shell退出影响而退出的进程。服务是一个概念，提供这些服务的程序是通常是由运行在后台的这些守护进程来执行的

* 基于sysvinit启动脚本通常在`/etc/init.d/`
* 基于xinet启动脚本的`/etc/xinetd.d/`目录下。
* 基于systemd 的服务启动脚本在 /lib/systemd/system/ 目录下，扩展名是 .service

运行级别（runlevel）是为了便于系统管理而定义的概念，不同的运行级别下运行的服务数量不同，能提供的功能不同。在深度服务器企业版中存在七个运行级别（索引为0），运行级别描述如下：

* 0用于停止系统。此运行级别是保留的，不能更改。
* 1用于在单用户模式下运行。此运行级别是保留的，不能更改。
* 2默认情况下不使用。你可以自由定义它。
* 3用于使用命令行用户界面在完整的多用户模式下运行。
* 4默认情况下不使用。你可以自由定义它。
* 5用于以完整的多用户模式运行图形用户界面。
* 6用于重新引导系统。此运行级别被保留，不能更改。


Sysvinit 命令	Systemd 命令	备注

service foo start	systemctl start foo.service	用来启动一个服务 (并不会重启现有的)

service foo stop	systemctl stop foo.service	用来停止一个服务 (并不会重启现有的)。

service foo restart	systemctl restart foo.service	用来停止并启动一个服务。

service foo reload	systemctl reload foo.service	当支持时，重新装载配置文件而不中断等待操作。

service foo condrestart	systemctl condrestart foo.service	如果服务正在运行那么重启它。

service foo status	systemctl status foo.service	汇报服务是否正在运行。

ls /etc/rc.d/init.d/	systemctl list-unit-files --type=service	用来列出可以启动或停止的服务列表。

chkconfig foo on	systemctl enable foo.service	在下次启动时或满足其他触发条件时设置服务为启用

chkconfig foo off	systemctl disable foo.service	在下次启动时或满足其他触发条件时设置服务为禁用

chkconfig foo	systemctl is-enabled foo.service	用来检查一个服务在当前环境下被配置为启用还是禁用。

chkconfig –list	systemctl list-unit-files --type=service	输出在各个运行级别下服务的启用和禁用情况

chkconfig foo –list	ls /etc/systemd/system/*.wants/foo.service	用来列出该服务在哪些运行级别下启用和禁用。

chkconfig foo –add	systemctl daemon-reload	当您创建新服务文件或者变更设置时使用。

telinit 3	systemctl isolate multi-user.target 

systemctl isolate runlevel3.target 

telinit 3	

    systemd 提供新的命令 systemctl 来替代传统的 service、chkconfig 以及 telinit 等命令，并可以完成同样的管理任务，以下是 systemd 命令和 sysvinit 命令的对照表





1.7.2.系统运行级别

   运行级别（runlevel）是为了便于系统管理而定义的概念，不同的运行级别下运行的服务数量不同，能提供的功能不同

深度服务器操作系统V16版本开始使用 systemd 替换传统的 sysvinit 但依然保留了对传统运行级别概念的支持，比如：

sysvinit运行级别3 使用 multi-user.target 替代；

sysvinit运行级别5 使用 graphical.target 替代；

runlevel3.target 和 runlevel5.target 分别是指向 multi-user.target 和 graphical.target 的符号链接。systemd 用目标（target）替代了运行级别的概念，提供了更大的灵活性。

    以下是 Sysvinit 运行级别和 systemd 目标的对应表：



Sysvinit 

(runlevel)	Systemd

(target)	备注

0	runlevel0.target

poweroff.target	关闭系统

1, s, single	runlevel1.target

rescue.target	单用户模式

    2 , 4	runlevel2.target

runlevel4.target 

multi-user.target	用户定义/域特定运行级别。默认等同于 3

      3	runlevel3.target

multi-user.target	多用户，非图形化。用户可以通过多个控制台或网络登录

      5	runlevel5.target

graphical.target	多用户，图形化。通常为所有运行级别 3 的服务外加图形化登录

6	runlevel6.target

reboot.target	重启

emergency	emergency.target	紧急 Shell





1.7.3.切换系统运行级别

传统的runlevel 命令在 systemd 下仍然可以工作。你可以继续使用它， systemd 使用 'target' 概念 (多个的 'target' 可以同时激活)替换了之前系统的 runlevel 。systemd 对应的等价命令是

systemctl list-units --type=target

执行命令切换到 运行级 3： 

systemctl isolate multi-user.target

执行命令切换到 运行级 5：

systemctl isolate graphical.target

1.7.4.设置默认启动级别

    systemd 不使用传统的 /etc/inittab 文件来定义默认启动级别，而是以 /etc/systemd/system/default.target 链接文件的指向来定义系统启动默认的运行级别。可以执行命令修改开机默认运行级别，例如：

systemctl set-default multi-user.target

更多配置请参考，man systemctl 




## 常用操作命令

`chkconfig`可以用来设置服务运行在不同级别，`service`可以用来管理服务器的启停，`runlevel`命令可以用来检查系统处于那个运行级别，`init 3`命令可以用来切换当前系统到运行级别3 


* 执行命令`chkconfig`会列出所有服务默认的服务及其运行级别 

```
NetworkManager 	0:关闭	1:关闭	2:启用	3:启用	4:启用	5:启用	6:关闭
abrt-ccpp      	0:关闭	1:关闭	2:关闭	3:启用	4:关闭	5:启用	6:关闭
abrtd          	0:关闭	1:关闭	2:关闭	3:启用	4:关闭	5:启用	6:关闭
acpid          	0:关闭	1:关闭	2:启用	3:启用	4:启用	5:启用	6:关闭
atd            	0:关闭	1:关闭	2:关闭	3:启用	4:启用	5:启用	6:关闭
auditd         	0:关闭	1:关闭	2:启用	3:启用	4:启用	5:启用	6:关闭
autofs         	0:关闭	1:关闭	2:关闭	3:启用	4:启用	5:启用	6:关闭
blk-availability	0:关闭	1:启用	2:启用	3:启用	4:启用	5:启用	6:关闭
bluetooth      	0:关闭	1:关闭	2:关闭	3:启用	4:启用	5:启用	6:关闭
certmonger     	0:关闭	1:关闭	2:关闭	3:启用	4:启用	5:启用	6:关闭
cpuspeed       	0:关闭	1:启用	2:启用	3:启用	4:启用	5:启用	6:关闭
crond          	0:关闭	1:关闭	2:启用	3:启用	4:启用	5:启用	6:关闭
cups           	0:关闭	1:关闭	2:启用	3:启用	4:启用	5:启用	6:关闭
dkms_autoinstaller	0:关闭	1:关闭	2:启用	3:启用	4:启用	5:启用	6:关闭
dnsmasq        	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
firstboot      	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
haldaemon      	0:关闭	1:关闭	2:关闭	3:启用	4:启用	5:启用	6:关闭
htcacheclean   	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
httpd          	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
ip6tables      	0:关闭	1:关闭	2:启用	3:启用	4:启用	5:启用	6:关闭
iptables       	0:关闭	1:关闭	2:启用	3:启用	4:启用	5:启用	6:关闭
irqbalance     	0:关闭	1:关闭	2:关闭	3:启用	4:启用	5:启用	6:关闭
kdump          	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
lvm2-monitor   	0:关闭	1:启用	2:启用	3:启用	4:启用	5:启用	6:关闭
mdmonitor      	0:关闭	1:关闭	2:启用	3:启用	4:启用	5:启用	6:关闭
messagebus     	0:关闭	1:关闭	2:启用	3:启用	4:启用	5:启用	6:关闭
netconsole     	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
netfs          	0:关闭	1:关闭	2:关闭	3:启用	4:启用	5:启用	6:关闭
network        	0:关闭	1:关闭	2:启用	3:启用	4:启用	5:启用	6:关闭
nfs            	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
nfs-rdma       	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
nfslock        	0:关闭	1:关闭	2:关闭	3:启用	4:启用	5:启用	6:关闭
ntpd           	0:关闭	1:关闭	2:启用	3:启用	4:启用	5:启用	6:关闭
ntpdate        	0:关闭	1:关闭	2:启用	3:启用	4:启用	5:启用	6:关闭
oddjobd        	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
portreserve    	0:关闭	1:关闭	2:启用	3:启用	4:启用	5:启用	6:关闭
postfix        	0:关闭	1:关闭	2:启用	3:启用	4:启用	5:启用	6:关闭
pppoe-server   	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
psacct         	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
quota_nld      	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
rdisc          	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
rdma           	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
restorecond    	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
rngd           	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
rpcbind        	0:关闭	1:关闭	2:启用	3:启用	4:启用	5:启用	6:关闭
rpcgssd        	0:关闭	1:关闭	2:关闭	3:启用	4:启用	5:启用	6:关闭
rpcsvcgssd     	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
rsyslog        	0:关闭	1:关闭	2:启用	3:启用	4:启用	5:启用	6:关闭
saslauthd      	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
smartd         	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
spice-vdagentd 	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:启用	6:关闭
sshd           	0:关闭	1:关闭	2:启用	3:启用	4:启用	5:启用	6:关闭
sssd           	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
sysstat        	0:关闭	1:启用	2:启用	3:启用	4:启用	5:启用	6:关闭
udev-post      	0:关闭	1:启用	2:启用	3:启用	4:启用	5:启用	6:关闭
wdaemon        	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
winbind        	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
wpa_supplicant 	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
ypbind         	0:关闭	1:关闭	2:关闭	3:关闭	4:关闭	5:关闭	6:关闭
```

* `chkconfig --level 35 httpd on`     #在3，5运行级别，开启httpd系统服务
* `chkconfig --level 01246 httpd off` #在0，1，2，4，6运行级别，开启httpd系统服务
* `service start httpd`               #启动http服务
* `service stop httpd`                #停止http服务
* `service restart httpd`             #重启http服务
