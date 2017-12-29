# LogAnalyzer简介：
  
LogAnalyzer 是一款syslog日志和其他网络事件数据的Web前端。它提供了对日志的简单浏览、搜索、基本分析和一些图表报告的功能。数据可以从数据库或一般的syslog文本文件中获取，所以LogAnalyzer不需要改变现有的记录架构。基于当前的日志数据，它可以处理syslog日志消息，Windows事件日志记录，支持故障排除，使用户能够快速查找日志数据中看出问题的解决方案。

LogAnalyzer 获取客户端日志会有两种保存模式，一种是直接读取客户端/var/log/目录下的日志并保存到服务端该目录下，一种是读取后保存到日志服务器数据库中，推荐使用后者。LogAnalyzer 采用php开发，所以日志服务器需要php的运行环境，本文采用LNMP(Linux Nginx Mariadb PHP)


## 系统环境：
 * 防火墙关闭
 * SElinux关闭
 * CentOS7.2
 * httpd-2.4.6-40.el7.centos.x86_64
 * mariadb-server-5.5.44-2.el7.centos.x86_64
 * php-5.4.16-36.el7_1.x86_64
 * php-mysql-5.4.16-36.el7_1.x86_64
 * rsyslog-7.4.7-12.el7.x86_64
 * loganalyzer-3.6.5

配置LAMP环境
    
第一步：安装相关包
1
# yum -y install httpd php php-mysql mariadb-server  php-gd
第二步：安装完成后，各项相关配置
①启动httpd服务：
1
[root@centos7 ~]# systemctl start httpd
②MySQL额外添加的配置项：
 跳过名称解析
1
2
3
4
5
[root@centos7 ~]# vim /etc/my.cnf
    [mysqld]
    ...
    skip_name_resolve = ON
    innodb_file_per_table=ON
③启动mysql
1
[root@centos7 ~]# systemctl start mariadb.service
查看是否开启：
1
2
3
[root@centos7 ~]# ss -tnl
State       Recv-Q Send-Q Local Address:Port               Peer Address:Port
LISTEN      0      50                *:3306                          *:*
  默认的管理员用户为：root，密码为空；首次安装后建议使用mysql_secure_installation命令进行安全设定；
1
④[root@centos7 ~]# mysql_secure_installation
使用命令“mysql -u用户名 -p密码”即可登录，

⑤重启HTTP服务
1
[root@centos7 ~]# systemctl start httpd

安装服务器端程序：
(1) 安装rsyslog连接至mysql server的驱动模块；
1
[root@centos7 ~]# yum -y install rsyslog-mysql
查看 rsyslog-mysql包生成哪些文件   
1
2
3
[root@centos7 ~]# rpm -ql rsyslog-mysql.x86_64
/usr/lib64/rsyslog/ommysql.so
/usr/share/doc/rsyslog-7.4.7/mysql-createDB.sql
    查看文件“/usr/share/doc/rsyslog-7.4.7/mysql-createDB.sql”
        CREATE DATABASE Syslog;
        USE Syslog;
        CREATE TABLE SystemEvents
        。。。
        CREATE TABLE SystemEventsProperties
        。。。
    可以看到这个文件是在数据库中定义了两张表

(2) 在mysql server准备rsyslog专用的用户账号；
1
2
3
4
5
[root@centos7 ~]#mysql -u用户名 -p密码
MariaDB [(none)]>  GRANT ALL ON Syslog.* TO 'rsyslog'@'127.0.0.1' IDENTIFIED BY 'rsyslogpass';
Query OK, 0 rows affected (0.00 sec)
MariaDB [(none)]> FLUSH PRIVILEGES
Query OK, 0 rows affected (0.00 sec)
(3) 生成所需要的数据库和表；
1
[root@centos7 ~]# mysql -ursyslog -h127.0.0.1 -prsyslogpass <  /usr/share/doc/rsyslog-7.4.7/mysql-createDB.sql
(4) 配置rsyslog使用ommysql模块
1
[root@centos7 ~]# vim /etc/rsyslog.conf
1
2
在 MODULES 模块中添加
        $ModLoad ommysql
(5) 配置RULES，将所期望的日志信息记录于mysql中；
1
2
在RULES模块中添加：
*.*                  :ommysql:127.0.0.1,Syslog,rsyslog,rsyslogpass
(6) 重启rsyslog服务；
1
[root@centos7 ~]# systemctl restart rsyslog.service
(7) 安装loganalyzer
①首先获取loganalyzer 
 http://download.adiscon.com/loganalyzer/loganalyzer-3.6.5.tar.gz
②解压缩，并进行相关配置
1
2
3
4
5
6
7
8
# tar -xf loganalyzer-3.6.5.tar.gz
# cd loganalyzer-3.6.5/
# cp -a src  /var/www/html/loganalyzer
# cd /var/www/html
# ln -sv loganalyzer log
# cd log
# touch config.php
# chmod 666 config.php
③在浏览器安装向导中安装LogAnalyzer,打开浏览器访问"服务器地址/log"
