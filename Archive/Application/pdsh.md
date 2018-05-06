# pdsh 使用笔记

```
#!/bin/bash

export hostfile=$1
export command=$2

pdsh -R ssh -w `cat $hostfile` -l root $command | dshbak -c
```

* -R ssh    : 指定rcmd的模块名，默认使用rsh, 在这里我们要使用 ssh
* dshbak -c : pdsh的缺省输出格式为主机名加该主机的输出，在主机或输出多时会比较混乱，可以采用dshbak做一些格式化，让输出更清晰。


## Pdsh 使用方法

PDSH(Parallel Distributed SHell)可并行的执行对目标主机的操作，对于批量执行命令和分发任务有很大的帮助，在使用前需要配置ssh无密码登录

pdsh -h
Usage: pdsh [-options] command ...
-S                return largest of remote command return values
-h                output usage menu and quit                获取帮助
-V                output version information and quit       查看版本
-q                list the option settings and quit         列出pdsh执行的一些信息
-b                disable ^C status feature (batch mode)
-d                enable extra debug information from ^C status
-l user           execute remote commands as user           指定远程使用的用户
-t seconds        set connect timeout (default is 10 sec)   指定超时时间
-u seconds        set command timeout (no default)          类似-t
-f n              use fanout of n nodes                     设置同时连接的目标主机的个数
-w host,host,...  set target node list on command line      指定主机，host可以是主机名也可以是ip
-x host,host,...  set node exclusion list on command line   排除某些或者某个主机
-R name           set rcmd module to name                   指定rcmd的模块名，默认使用dsh
-N                disable hostname: labels on output lines  输出不显示主机名或者ip
-L                list info on all loaded modules and exit  列出pdsh加载的模块信息
-a                target all nodes                          指定所有的节点
-g groupname      target hosts in dsh group "groupname"     指定dsh组名
-X groupname      exclude hosts in dsh group "groupname"    排除组，一般和-a连用

available rcmd modules: exec,xcpu,ssh (default: rsh)        可用的执行命令模块，默认为rsh

## 分组执行
 
对于-g组，把对应的主机写入到/etc/dsh/group/或~/.dsh/group/目录下的文件中即可，文件名就是对应组名

```
$ cat ~/.dsh/group/dsh-test
192.168.0.231
192.168.0.232
192.168.0.233
192.168.0.234

$ pdsh -g dsh-test -l root uptime
192.168.0.232:  16:21:38 up 32 days, 22:22, ? users,  load average: 0.01, 0.15, 0.21
192.168.0.231:  16:21:38 up 32 days, 22:19, ? users,  load average: 0.17, 0.16, 0.16
192.168.0.234:  16:21:39 up 32 days, 22:21, ? users,  load average: 0.15, 0.19, 0.19
192.168.0.233:  16:21:40 up 32 days, 22:22, ? users,  load average: 0.15, 0.15, 0.10
```
