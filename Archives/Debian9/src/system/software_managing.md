# Yum

Yum是以RPM软件包管理器为基础的高级管理工具，可以从软件仓库获取软件包,完成软件依赖解析更新，安装或删除，卸载软件包,并可以更新整个系统到最新的可用版本! 

## 配置Yum和Yum Repository

和yum相关的配置文件位于`/etc/yum.conf` 其中项主要参考配置项如下：

```
[main]
cachedir=/var/cache/yum            #yum下载的RPM包的缓存目录
keepcache=0                        #缓存是否保存，1保存，0不保存。
debuglevel=2                       #调试级别(0-10)，默认为2
logfile=/var/log/yum.log           #yum的日志文件所在的位置
exactarch=1                        #在更新的时候，是否允许更新不同版本的RPM包，比如是否在i386上更新i686的RPM包。
obsoletes=1                        #这是一个update的参数，具体请参阅yum(8)，简单的说就是相当于upgrade，允许更新陈旧的RPM包。
gpgcheck=1                         #是否检查GPG(GNU Private Guard)，一种密钥方式签名。
plugins=1                          #是否允许使用插件，默认是1允许
installonly_limit=5                #允许保留多少个内核包。
exclude=selinux*                   #屏蔽不想更新的RPM包，可用通配符，多个RPM包之间使用空格分离。
```

## 添加软件源

和软件源（Yum Repository）相关的配置文件在`/etc/yum.repo.d/`，创建一个Repository配置文件`/etc/yum.repos.d/local.repo`，参考配置实例如下（假设本地仓库在/repo）：

```
[local]
name=local
baseurl=file:///repo/
gpgcheck=0
```

重新执行命令yum update之后就可以使用这个软件仓库了。

* 软件源格式

yum仓库配置文件扩展名是 .repo, 配置文件存放目录：/etc/yum.repos.d/。一个 repo 文件可以添加多个repository配置，repo文件中的 repository 配置遵循如下格式：

```
[serverid]
name=Some name for this server
baseurl=url://path/to/repository/
其他可选配置

```

* serverid 是用于区分不同的 repository ，必须有一个独一无二的名称；
* name 定义 repository 的描述部分
* baseurl 定义 repository 的访问方式
* baseurl 指向是repository服务器设置中最重要的部分，一个repository 配置中只能有一个baseurl, 只有设置正确，yum才能从上面获取软件。它的格式如下：
```
baseurl=url://server1/path/to/repository/
　　　   url://server2/path/to/repository/
　　　   url://server3/path/to/repository/
其中url 支持的协议有`http:// ftp:// file://`三种，baseurl 后可以跟多个url。
```


## yum 命令的常用操作

* `yum update`           #同步仓库索引到最新
* `yum check-update`     #检查是否有可用的更新 
* `yum list`             #查询仓库中的软件包列表
* `yum install tar`      #安装一个软件包
* `yum update tar`       #升级一个软件包
* `yum remove tar`       #卸载一个软件包
* `yum help`             #查看yum命令帮助信息



