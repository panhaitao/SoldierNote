
# MySQL概述

MySQL是一个开源的关系型数据库管理系统，最早由瑞典MySQL AB 公司开发，目前属于 Oracle 旗下产品

## MySQL的安装和基础配置

* 安装MySQL`yum install -y mysql-server`
* 设置MySQL管理员root用户密码`/usr/bin/mysqladmin -u root password '密码'`

## MySQL数据库管理的操作实例

* 执行命令`mysql -u root -p`输入刚刚创建的密码，登录MySQL，

* 创建一个库名为testdatabase的库。
```
mysql> create database test_db;
```
* 列出全部数据库
```
mysql> show databases; 
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| test               |
| test_db            |
+--------------------+
4 rows in set (0.00 sec)

```

* 在test_db库中创建users表。
```
mysql> use test_db;
mysql> create table users (`id` int(11), `name` char(255));
```

* 列出test_db库中的全部表
```
mysql> show tables；
+-------------------+
| Tables_in_test_db |
+-------------------+
| users             |
+-------------------+
1 row in set (0.00 sec)
```
* 向表中插入记录。
```
mysql> insert into users values(001,'zhang');
mysql> insert into users values(002,'wang');
mysql> insert into users values(003,'zhao');
mysql> insert into users values(004,'li');
```
* 查询`users`表中的数据记录如下。
```
mysql> select * from users;
+------+-------+
| id   | name  |
+------+-------+
|    1 | zhang |
|    2 | wang  |
|    3 | zhao  |
|    4 | li    |
+------+-------+
4 rows in set (0.00 sec)
``` 
* 执行exit命令，即可退出MySQL。

## MySQL数据库的备份和还原

* 备份全部数据库：`mysqldump -uroot -p -A > backup.sql`
* 从备份文件还原：`mysql -u root -p < backup.sql` 

其他更多参考`man mysql`
