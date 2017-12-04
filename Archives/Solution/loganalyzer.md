---
title: "基于Rsyslog和LogAnalyzer的日志管理方案"
tags: 服务器技术
categories: 解决方案
---
# 基于Rsyslog和LogAnalyzer的日志管理方案
 
## 概述

在数据为王的时代，日志管理是一个绕不开的话题，相应的开源软件有不少，比如热门的三件套：Logstash、ElasticSearch、Kibana，虽然功能强大，但是配置复杂，是为大数据运维场景而生。相比较而言，rsyslog更容易快速上手,可以将收集日志存在mysql中，同时又有Web前端Loganalyzer开源软件的支持，方便搜索，分析、审计,用户可以基于日志数据快速定位解决问题，可以满足服务器量级从数十到百规模的运维场景。 

## 工作模式 

rsyslog+mysql＋loganalyzer组合型日志服务器，要求客户端生成的日志，由rsyslog服务器收集，写入mysql数据库，最后由loganalyzer工具在前端界面展示出来,日志数据流简单总结如下:
```
log => logserver => mysql => lognanlyzer
```

## 环境搭建

LogAnalyzer 获取客户端日志会有两种保存模式，一种是直接读取客户端/var/log/目录下的日志并保存到服务端该目录下，一种是读取后保存到日志服务器数据库中，推荐使用后者。LogAnalyzer 采用php开发，所以日志服务器需要php的运行环境，本文采用LNMP(Linux Nginx Mariadb PHP),部署在Debian9系统上

* 客户端软件:
  * rsyslog
* 服务端软件:
  * nginx
  * mariadb-server-10.1
  * php7.0
  * php7.0-gd
  * php7.0-fpm
  * php7.0-mysql
  * rsyslog
  * rsyslog-mysql
  
### 客户端配置

客户端，也就是实际需要收集日志的业务主机，这里配置很简单，只需要在所有业务主机Rsyslog配置文件`/etc/rsyslog.conf`，加入一行,重启服务即可，参考配置如下：

```
*.*	        @logserver_ip	
```

其中: `*.*` 表示收集所有默认系统日志 ; `logserver_ip`　替换为实际logserver服务器的IP 

### 服务端配置

本实例中 logserver,mariadb,loganalyzer 都部署在同一个系统中,安装相关包:
```
apt install nginx mariadb-server-10.1 php7.0 php7.0-gd php7.0-fpm php7.0-mysql rsyslog-mysql -y
```
 
#### Rsyslog 服务端配置

1. 配置rsyslog使用imudp模块,新增配置文件`/etc/rsyslog.d/server.conf`，添加如下参考配置： 
```
$ModLoad imudp                                 #加载模块
$UDPServerRun 514                              #监听UDP端口，接受来自其他服务器的记录日志请求
```

2. 配置rsyslog使用ommysql模块,新增配置文件 `/etc/rsyslog.d/mysql.conf`,添加如下参考配置： 
``` 
$ModLoad ommysql                               #加载模块
*.* :ommysql:127.0.0.1,syslog,lognan,password  #和数据库相关的配置
```

配置中　`*.*:ommysql｀表示所有默认系统日志都写入数据库。之后分别是,数据库服的IP地址，数据库名称，登录数据库的用户名，登录数据库的密码,后续数据库的配置用到这里的配置。

3. 执行命令`systemctl restart rsyslog.service`,重启rsyslog服务，可以通过`tail -f /var/log/syslog`观察是否能看到来其他主机的日志，来验证imudp模块配置是否生效，在配置完数据库后来可以进行ommysql模块配置验证，在后文配置数据库中会提到。这里是基于Rsyslog 的imudp模块和ommysql模块完成logserver配置,其他还有`imtcp,imrelp`等模块，读者可以根据具体需求变更配置，详细可参考官方文档<http://www.rsyslog.com/doc/>。

#### 数据库配置

登录 MariaDB 服务器，创建初始的库表的连接用户,这里的数据名，用户，密码需要和`/etc/rsyslog.d/mysql.conf`配置中定义的一致，

```
root@logserver:~# mysql -u root -p
Enter password: 
...
MariaDB [(none)]> 

MariaDB [(none)]>create database if not exists syslog;
MariaDB [(none)]>grant select,insert,update on syslog.* to lognan@'127.0.0.%' identified by 'password';
MariaDB [(none)]>use syslog;
MariaDB [(none)]>\. /usr/share/dbconfig-common/data/rsyslog-mysql/install/mysql

```
会建立起两张表：SystemEvents、SystemEventsProperties，日志也记录在第一张表里。现在可以完整rsyslog服务ommysql模块的验证，登录 MariaDB 服务器,看表里已有的日志: `MariaDB [(none)]> SELECT * from SystemEvents\G`，如果有数据，说明以上配置生效。

#### 部署LogAnalyzer


1. 配置 php7.0-fpm 编辑配置文件｀/etc/php/7.0/fpm/pool.d/www.conf`,参考配置如下：

```
[www]
user = www-data
group = www-data
listen = 127.0.0.1:9000

listen.owner = www-data
listen.group = www-data

pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

2. 配置 nginx 编辑配置文件`/etc/nginx/sites-available/default`, 参考配置如下：

```
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;
        index index.php index.html index.htm index.nginx-debian.html;
        server_name _;

        location / {
                try_files $uri $uri/ =404;
        }

        location ~ \.php$ {
                fastcgi_pass 127.0.0.1:9000;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                include fastcgi_params;
        }
}
```

3. 启动服务

```
root@logserver:~# systemctl restart php7.0-fpm.service
root@logserver:~# systemctl restart nginx.service
```
检查服务项启动,确认`80,3306,9000`端口已启用。

```
root@logserver:~# ss -tnl
State      Recv-Q Send-Q                         Local Address:Port                                        Peer Address:Port
LISTEN     0      128                                127.0.0.1:9000                                                   *:*
LISTEN     0      80                                 127.0.0.1:3306                                                   *:*
LISTEN     0      128                                        *:80                                                     *:*
LISTEN     0      128                                        *:22                                                     *:*
LISTEN     0      128                                       :::80                                                    :::*
LISTEN     0      128                                       :::22                                                    :::* 
```

４. 安装loganalyzer，获取源码包，解压到服务器根目录
```
wget http://download.adiscon.com/loganalyzer/loganalyzer-4.1.5.tar.gz
tar -xf loganalyzer-3.6.5.tar.gz
cp -a loganalyzer-3.6.5/src  /var/www/html/log/
touch /var/www/html/log/config.php
chmod 666 /var/www/html/log/config.php
```

打开浏览器访问,"http://server-ip/log/install.php"，在安装向导中完成LogAnalyzer的配置:

1. 步骤一，开始安装
![step1](/images/loganalyzer-installer-step1.png)

2. 步骤二,检查配置文件是否可写
![step2](/images/loganalyzer-installer-step2.png)

3. 步骤三,完整基本配置，默认即可
![step3](/images/loganalyzer-installer-step3.png)

4. 步骤四,配置数据库，如图所示
![step4](/images/loganalyzer-installer-step7.png)

5. 步骤五,完成Loganalyzer的安装
![step5](/images/loganalyzer-installer-step8.png)

6. 安装完成后，打开浏览器访问，"http://server-ip/log/" ,Loganalyzer 的运行状态示例如下:
![running](/images/loganalyzer-running-status.png)

后续调整LogAnalyzer配置可修改`/var/www/html/log/config.php`文件。 
