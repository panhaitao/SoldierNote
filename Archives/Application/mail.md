# 邮件服务器

深度服务器企业版提供许多高级应用程序来提供和访问电子邮件。本章介绍当今使用的现代电子邮件协议，以及旨在发送和接收电子邮件的一些程序。

* SMTP协议
SMTP的全称是“Simple Mail Transfer Protocol”，即简单邮件传输协议。它是一组用于从源地址到目的地址传输邮件的规范，通过它来控制邮件的中转方式。SMTP 协议属于TCP/IP协议簇，它帮助每台计算机在发送或中转信件时找到下一个目的地。SMTP 服务器就是遵循SMTP协议的发送邮件服务器。SMTP认证，简单地说就是要求必须在提供了账户名和密码之后才可以登录 SMTP 服务器，这就使得那些垃圾邮件的散播者无可乘之机。增加 SMTP 认证的目的是为了使用户避免受到垃圾邮件的侵扰。

* POP协议
POP邮局协议负责从邮件服务器中检索电子邮件。它要求邮件服务器完成下面几种任务之一：从邮件服务器中检索邮件并从服务器中删除这个邮件；从邮件服务器中检索邮件但不删除它；不检索邮件，只是询问是否有新邮件到达。POP协议支持多用户互联网邮件扩展，后者允许用户在电子邮件上附带二进制文件，如文字处理文件和电子表格文件等，实际上这样就可以传输任何格式的文件了，包括图片和声音文件等。在用户阅读邮件时，POP命令所有的邮件信息立即下载到用户的计算机上，不在服务器上保留。POP3(Post Office Protocol 3)即邮局协议的第3个版本,是因特网电子邮件的第一个离线协议标准。

* IMAP协议
互联网信息访问协议（IMAP）是一种优于POP的新协议。和POP一样，IMAP也能下载邮件、从服务器中删除邮件或询问是否有新邮件，但IMAP克服了POP的一些缺点。例如，它可以决定客户机请求邮件服务器提交所收到邮件的方式，请求邮件服务器只下载所选中的邮件而不是全部邮件。客户机可先阅读邮件信息的标题和发送者的名字再决定是否下载这个邮件。通过用户的客户机电子邮件程序，IMAP可让用户在服务器上创建并管理邮件文件夹或邮箱、删除邮件、查询某封信的一部分或全部内容，完成所有这些工作时都不需要把邮件从服务器下载到用户的个人计算机上。



## 实例一 搭建邮件发送服务器

实例中没有提到添加防火墙配置，这里以关闭防火墙为前提`service iptables stop`

1. 安装软件包 `yum install postfix`
2. 修改基础配置，编辑配置文件：`/etc/postfix/main.cf` 将`inet_interfaces = localhost` 修改为 `inet_interfaces = all`
3. 重启服务`service postfix restart`
4. 本机使用mail命令发送测试邮件功能是否可用，如果接收到测试邮件，说明SMTP服务器基本搭建完成,更多配置参考`man postfix`

## 实例二 搭建邮件接收服务器

实例中没有提到添加防火墙配置，这里以关闭防火墙为前提`service iptables stop`

1. 安装软件包 `yum install dovecot`
2. 修改参考配置配置dovecot 收取邮件
* 编辑配置文件`/etc/dovecot/dovecot.conf`，将如下部分配置修改为：
```
protocols = imap pop3 lmtp
listen = *, ::
login_trusted_networks =0.0.0.0/0
```
* 编辑配置文件`/etc/dovecot/conf.d/10-mail.conf`，将如下部分配置修改为：
```
mail_location = maildir:~/Maildir #只定邮箱路径
```
* 编辑配置文件`/etc/dovecot/conf.d/10-auth.conf`，将如下部分配置修改为：
```
auth_mechanisms = plain login    #允许验证和登录
disable_plaintext_auth = yes     #允许明文登录
```
* 编辑配置文件`/etc/dovecot/conf.d/10-master.conf`，将如下部分配置修改为：
```
unix_listener auth-userdb {     #允许运行的数据库
    #mode = 0600
    user =postfix
    group =postfix
  }
```
3. 重启服务`service dovecot restart`
4. 测试验证,新建一个用户并设置密码，使用mail命令向刚刚创建的用户发送一封邮件，客户端配置略，用户密码就是刚刚创建的用户和密码。
