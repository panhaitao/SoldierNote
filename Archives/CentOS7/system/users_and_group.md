---
title: "用户与权限管理"
categories: CentOS7
tags: 系统管理
---
# 用户与权限管理

## 概述 

用户和组的控制是Linux系统管理的核心元素。组内的用户可以这个组对应的读/写/执行权限等，一个用户组可以拥有多个成员，每一个用户可以从属于多个组，但只能有一个主组。

用户标志（user identifier，一般缩写为UID)是系统内核用来辨识用户身份的唯一的数字识别号码.深度服务器操作系统用户UID的值的范围在0～65535之内，且有如下限制：

* 超级用户: UID值为0,是系统中权限最高的用户；
* 系统用户：UID值为1～499，预留给系统或特定服务使用；
* 普通用户：UID值为500~65535,系统创建第一个普通用户时,默认为之分配的UID则为500;


组标识(Group identifier,一般缩些为GID）是系统内核用来定义用户组身份的唯一的数字识别号码，和UID类似，深度服务器操作系统对GID也有如下限制：

* 超级用户: GID值为0,是系统中权限最高的用户组；
* 系统用户：GID值为1～499，预留给系统或特定服务使用；
* 普通用户：GID值为500~65535,系统创建第一个普通用户组时,默认为之分配的GID则为500;

常用的管理功能有添加用户、设置密码，修改用户信息，删除用户，添加用户组、删除用户组和修改用户组。

## 使用命令行工具管理用户

通过命令行管理用户时，会用到以下命令：useradd，usermod，userdel，passwd。操作涉及的文件包含，存储用户帐户信息的/etc/passwd和存储安全用户帐户信息的/etc/shadow。
 
### 创建用户
useradd命令可以用来创建新用户,创建一个新用户时，会完成如下步骤，自动生成一个数值相等的UID和GID，默认主目录设置为/home/<用户名>/，默认shell设置为/bin/bash，并自动创建对应用户目录，将配置写入/etc/passwd和/etc/shadow文件中. 以下是创建一个用户名为deepin的操作实例：
```
[root@deepin-server ~]# useradd deepin
```
运行`useradd deepin`命令创建一个名为deepin的用户后。

查看 `/etc/passwd`文件内容，可以到新增一行`deepin:x:501:501::/home/deepin:/bin/bash`
以`:`为分隔符，各字段含义分别如下：
1. 用户名称：deepin
2. 口令：`x`表示使用了影子密码，（散列密码存储在/etc/shadow） 
3. 用户标识号（UID）：501
4. 组标识号GID：501
5. 注释性描述：
6. 主目录:/home/deepin 
7. 默认shell：/bin/bash

查看 `/etc/shadow`文件内容，可以到新增一行`deepin:!!:17336:0:99999:7:::`以`:`为分隔符，各字段含义分别如下：
1. 用户名称: deepin
2. 散列密码字段：`!!`，表示这个用户没有密码，不可用于登陆
3. 最近更动密码的日期（这里的日期是1970年1月1日为起点的总日数）
4. 密码不可被更动的天数：       0 表示密码随时可以更动的意思
5. 密码需要重新变更的天数：     99999 表示密码不需变更
6. 密码需要变更期限前的警告期限：7表示则是密码到期之前的7天之内，系统会警告该用户。
7. 密码过期的宽限时间：        空字段表示不设限制
8. 帐号失效日期：             空字段表示不设限制
9. 保留字段：

### 设置密码
使用`useradd`创建的用户的没有密码，不可以登陆的，需要以root身份执行`passwd`命令完成用户密码的设置，操作如下：
```
[root@deepin-server ~]# passwd deepin
更改用户 shenlan 的密码 。
新的 密码：
重新输入新的 密码：
```
操作完成后，可以注意到`/etc/shadow`文件中,deepin用户对应配置行中嗯，散列密码字段从`!!`变为类似`$6$YmiEgHGFo5w2Swfy$PeNylGykOKGu4EgeVEiKUupw2wm03zWNT8nakndK38M69Wge9NJLK/RGonPRCY8dnv95tO6/Z0IDvuoxN0dDM.`的字符串

## 使用命令行工具管理用户组

通过命令行管理用户组时，会用到以下命令：groupadd，groupmod，groupdel，操作涉及的文件包含，存储用户组信息的/etc/group。

### 添加用户组

groupadd命令可以用来创建新的用户组，创建一个新用户组时，会完成如下步骤，自动生成一个新的GID，并将配置写入/etc/group. 操作如下：

```
groupadd Webserver
```

查看 /etc/group 会看到新增一行，类似`Webserver:x:502:` 以`:`为分隔符

1. 用户组名： Webserver
2. 用户组密码：`x`表示使用使用了影子密码,（散列密码存储在/etc/shadow） 
3. GID：502
4. 所有属于该组的用户:

## 其他实例参考如下：

* 修改用户信息`usermod -G ftp deepin` 将deepin用户添加到ftp组中
* 修改用户组信息`groupmod -n server Webserver` 将组名由Webserver变更为server
* 删除用户`userdel -r deepin`, 执行后,会清空和用户相关的配置或目录 
* 删除用户组`groupdel server`,执行后会清空和用户组相关的配置 

