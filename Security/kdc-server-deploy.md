# KDC-Server 的部署指南

# Kerberos概述

Kerberos是一种计算机网络认证协议，它允许某实体在非安全网络环境下通信，向另一个实体以一种安全的方式证明自己的身份，协议基于**对称密码学**，并需要一个**值得信赖的第三方（KDC**）。它主要包含：认证服务器（AS）和票据授权服务器(TGS)组成的密钥分发中心（KDC），以及提供特定服务的SS。相关概念描述：

*   AS（Authentication Server）= 认证服务器
*   KDC（Key Distribution Center）= 密钥分发中心
*   TGT（Ticket Granting Ticket）= 授权票据
*   TGS（Ticket Granting Server）= 票据授权服务器
*   SS（Service Server）= 特定服务提供端

KDC持有一个密钥数据库；每个网络实体——无论是客户还是服务器——共享一套只有他自己和KDC知道的密钥。密钥的内容用于证明实体的身份。对于两个实体间的通信，KDC产生一个会话密钥，用来加密他们之间的交互信息。

例如 Hadoop使用Kerberos实现认证的流程简要描述如下：


|   步骤   |  Kerberos认证与授权阶段  |       备注说明         |
|--------|---------------------------|------------------| 
|   1   | **[Login]** 用户输入用户名/密码信息进行登录| 在**Client**端完成对密码信息的单向加密|
|  2   | **[Client/AS]** Client到AS进行认证，获取TGT | 基于**JAAS**进行认证|
|  3  |  **[Client/TGS]** Client基于TGT以及Client/TGS Session Key去TGS去获取Service Ticket(Client-To-Server Ticket) | 基于**GSS-API**进行交互 |
| 4  |  **[Client/Server]** Client基于 Client-To-Server Ticket以及Client/Server SessionKey去Server端请求建立连接，该过程Client/Server可相互进行认证 | 基于GSS-API进行交互| 
| 5 |  **[Client/Server]** 连接建立之后，Client可正常往Server端发送服务请求 |  立连接与发送服务请求的过程，则通常基于**SASL**框架 |

## Kerberos相关术语

*   principal ：认证的主体，简单来说就是"用户名"。 格式： 服务/主机@域
*   realm：域，类似于namespace的作用，可以看成是principal的一个"容器"或者"空间"。 在kerberos, 大家都约定成俗用大写来命名realm, 比如"EXAMPLE.COM"
*   keytab文件：存储了多个principal的加密密码文件

## Kerberos 工作原理

![image](https://upload-images.jianshu.io/upload_images/5592768-5898fb6c90124e72?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# Kerberos的安装部署

## KDC-Server 服务端

**登陆OPS节点**，进入/data/Playbook-Performance-Test工作目录，执行如下命令完成KDC-Server安装部署：

```
ansible-playbook  todo/init_kdc_master -D

```

### KDC-Server 配置过程参考

登陆kdc-master-1节点，执行操作

1.  /var/kerberos/krb5kdc/kdc.conf 将 [realms] 配置项改为 HADOOP.COM (可以根据需要自定义)
2.  /var/kerberos/krb5kdc/kadm5.acl 修改为  ***/admin@HADOOP.COM**** ***

第一列为用户名，第二列为权限分配，*以* /admin@HADOOP.COM *结尾的用户，UNP可以执行任何操作*

3.  /etc/krb5.conf
    1.  [libdefaults] 配置项添加如下配置 default_realm = HADOOP.COM
    2.  [realms] 配置项，修改如下部分

```
[realms]
 HADOOP.COM = {
  kdc = kdc-master-1:88          
  admin_server = kdc-master-1:749
  default_domain = HADOOP.COM
 }

 [domain_realm]
 .hadoop.com = HADOOP.COM
 hadoop.com = HADOOP.COM

```

*   **端口88** KDC使用默认使用
*   **端口749** 标识运行管理服务器的主机，在集群模式，通常这是主Kerberos服务器。必须为此标签赋予一个值，以便与该领域的kadmind服务器通信

### KDC-Server 的初始化

登陆kdc-master-1节点，执行操作

3.  启动 KDC 服务，执行命令: ***systemctl start krb5kdc***
4.  初始化KDC数据库
    1.  执行命令： **kdb5_util create -r ****HADOOP.COM**** -s**
    2.  输入并确认 KDC database master key 后将在/var/kerberos/krb5kdc/目录下生成多个principal*文件 
5.  在 KDC 服务器上添加超级管理员账户，和对应的**keytab，**执行命令:

```
 kadmin.local -q "addprinc admin/admin@HADOOP.COM"
 kadmin.local -q "ktadd -k /var/kerberos/krb5kdc/kadm5.keytabadmin/admin@HADOOP.COM"

```

### KDC-Server 服务验证

登陆kdc-master-1节点，执行命令： kinit admin/admin 输入密码，执行 klist 将返回如下结果：

![image](https://upload-images.jianshu.io/upload_images/5592768-00f621ee3c3d3eae?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## Kerberos客户端

客户端需要安装软件包 krb5-workstation

1.  客户端配置文件: /etc/krb5.conf
2.  提供客户端命令: klist kinit 

Kerberos支持两种认证模式，

1.  一种是使用principal + Password: 适合用户进行交互式应用，例如hadoop fs -ls 这种
2.  一种使用principal + keytab : 适合服务，例如yarn的rm、nm等。principal + keytab就类似于ssh免密码登录，登录时不需要密码了。

用于 HDFS服务 客户端组件 /etc/krb5.conf 参考(默认禁用了aes256-cts，JAVA应用支持不好，需要引入第三方jar包)

```
includedir /etc/krb5.conf.d/

[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 dns_lookup_realm = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true
 rdns = false
 pkinit_anchors = FILE:/etc/pki/tls/certs/ca-bundle.crt
 default_realm = HADOOP.COM
 default_ccache_name = KEYRING:persistent:%{uid}
 default_tkt_enctypes = aes128-cts-hmac-sha1-96 des3-cbc-sha1 arcfour-hmac-md5 camellia256-cts-cmac camellia128-cts-cmac des-cbc-crc des-cbc-md5 des-cbc-md4
 default_tgs_enctypes = aes128-cts-hmac-sha1-96 des3-cbc-sha1 arcfour-hmac-md5 camellia256-cts-cmac camellia128-cts-cmac des-cbc-crc des-cbc-md5 des-cbc-md4
 permitted_enctypes = aes128-cts-hmac-sha1-96 des3-cbc-sha1 arcfour-hmac-md5 camellia256-cts-cmac camellia128-cts-cmac des-cbc-crc des-cbc-md5 des-cbc-md4

[realms]
 HADOOP.COM = {
  kdc = kdc-master-1.hadoop.com:88
  admin_server = kdc-master-1.hadoop.com:749
  default_domain = HADOOP.COM
 }

 [domain_realm]
 .hadoop.com = HADOOP.COM
 hadoop.com = HADOOP.COM

```

# Kerberos的运维管理

## 管理 principal

登陆kdc-master-1节点，执行命令：

```

kadmin.local -q "addprinc -randkey hdfs/hdfs-namenode-1.hadoop.com@HADOOP.COM"
kadmin.local -q "addprinc -randkey http/hdfs-namenode-1.hadoop.com@HADOOP.COM"
kadmin.local -q "addprinc -randkey hdfs/hdfs-datanode-1.hadoop.com@HADOOP.COM"
kadmin.local -q "addprinc -randkey hdfs/hdfs-datanode-2.hadoop.com@HADOOP.COM"
kadmin.local -q "addprinc -randkey hdfs/hdfs-datanode-3.hadoop.com@HADOOP.COM"

kadmin.local -q "ktadd -norandkey -kt hdfs-namenode.keytab  hdfs/hdfs-namenode-1.hadoop.com@HADOOP.COM"
kadmin.local -q "ktadd -norandkey -kt http-namenode.keytab  http/hdfs-namenode-1.hadoop.com@HADOOP.COM"
kadmin.local -q "ktadd -norandkey -kt hdfs-datanode.keytab  hdfs/hdfs-datanode-1.hadoop.com@HADOOP.COM hdfs/hdfs-datanode-2.hadoop.com@HADOOP.COM hdfs/hdfs-datanode-3.hadoop.com@HADOOP.COM"

```

## 客户端验证

klist -k -e -t xxx. keytab

通过提供keytab获取ticket： kinit -kt xxx. keytab

http://www.microhowto.info/howto/create_a_host_principal_using_mit_kerberos.html

最后将生成的 hdfs-namenode.keytab http-namenode.keytab文件，分发到运行 HDFS NameNode 的服务器

最后将生成的 hdfs-datanode.keytab 文件，分发到运行 客户端

# Troubleshooting

Kerberos is hard to set up —and harder to debug. Common problems are

1.  Network and DNS configuration.
2.  Kerberos configuration on hosts (/etc/krb5.conf).
3.  Keytab creation and maintenance.
4.  Environment setup: JVM, user login, system clocks, etc.

参考 http://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SecureMode.html#Troubleshooting

可以在JVM启动参数中添加了如下3个参数:

-Djava.security.krb5.kdc=node1:8080 \

-Djava.security.krb5.realm=KFC.com \

https://docs.oracle.com/javase/8/docs/technotes/guides/security/jgss/tutorials/KerberosReq.html

JDK-8237647 : LoginException: Message stream modified (41) for uppercase username with krb5

https://bugs.java.com/bugdatabase/view_bug.do?bug_id=8237647

Further response from the submitter:

It's not a bug, it is related to <u>[https://bugs.openjdk.java.net/browse/JDK-8215032](https://bugs.openjdk.java.net/browse/JDK-8215032)</u>

OpenJDK Implementation:

> [https://github.com/AdoptOpenJDK/openjdk-jdk11u/commit/37ad8d8b82b6199fa254e941243cc722cc2a35fb](https://github.com/AdoptOpenJDK/openjdk-jdk11u/commit/37ad8d8b82b6199fa254e941243cc722cc2a35fb)

Got it fixed by adding -Dsun.security.krb5.disableReferrals=true

https://www.linuxidc.com/Linux/2016-09/134948.htm

