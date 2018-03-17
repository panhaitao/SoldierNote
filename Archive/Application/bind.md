# BIND与DNS服务器概述

BIND是一种开源的DNS（Domain Name System）协议的实现，包含对域名的查询和响应所需的所有软件，它是互联网上最广泛使用的一种DNS服务器。DNS服务器的类型有如下三种类型：
* Primary DNS Server(Master)  一个域的主服务器保存着该域的zone配置文件，该域所有的配置、更改都是在该服务器上进行
* Secondary DNS Server(Slave) 一个域的从服务器一般都是作为冗余负载使用，从该域的主服务器上同步记录，从服务器不会进行任何信息的更改
* Caching only Server         DNS缓存服务器不存在任何的zone配置文件，仅仅依靠缓存来为客户端提供服务，它通常用于负载均衡及加速访问操作


## 基础概念

1. 递归查询
2. 迭代查询

## 域名服务器分类
  * 权威域名服务器
  * 缓存域名服务器
  * 转发域名服务器 

* 基础配置
* 安全加固配置(chroot方式)
* 简单负载均衡
* 全局负载均衡(GSLB)
* DNS服务监控

## 实例一：BIND的基本安装和配置

* 安装`yum install bind -y`
* 配置bind
   * 添加一个正向解析zone文件`/var/named/deepin.com.zone`
```
$TTL    604800
@       IN      SOA     deepin.com. root.deepin.com. (
                              3         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      deepin.com.
@       IN      A       192.168.1.1
www     IN      A       192.168.1.2
ftp     IN      A       192.168.1.3

```


* $TTL 1D ；缓存时间  
* @       IN SOA  @ rname.invalid. (               ；SOA是Start Of Authority 的缩写  
*                                          0       ; serial 序号 如果master上的zone文件序号比slave上的大，那么数据就会同步。  
*                                          1D      ; refresh 刷新Slave的时间  
*                                          1H      ; retry Slave更新失败后多久再进行一次更新  
*                                          1W      ; expire 失败多少次后不再尝试更新，一周  
*                                          3H )    ; minimum 缓存时间，如果没有设定$TTL 这个值就可当作$TTL  
*          NS      @  ；就是zone中定义的域名，如localhost.localdomain和localhost 




   * 添加一个反向解析库文件`/var/named/1.168.192.zone`
```
$TTL    604800
@       IN      SOA     deepin.com. root.deepin.com. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      deepin.com.
1       IN      PTR     deepin.com.
2       IN      PTR    www.deepin.com. 
3       IN      PTR    ftp.deepin.com.
```

* 配置注意事项：
   * 配置文件中的 "@" 符号前不能有任何空白字符
   * 配置文件中的 "IN" 字符前必须有空格或TAB

将zone数据记录配置添加到`/etc/named.conf`
```
zone "deepin.com" IN {
        type master;
        file "deepin.com.zone";
};

zone "1.168.192.in-addr.arpa" IN {
        type master;
        file "1.168.192.zone";
};
```

* 检查配置zone文件格式语法正确，确保设置正确的权限，执行命令如下：
   * `named-checkzone  "www.deepin.com" /var/named/deepin.com.zone`
   * `named-checkzone "192.168.1.2" /var/named/1.168.192.zone `
   * `chmod 640 deepin.com.zone 3.168.192.zone`
   * `chown named:named deepin.com.zone 3.168.192.zone`
* 如果以上步骤没有任何错误提示，最后重启服务`service named restart`
* 测试验证
   * 验证域名解析`dig @127.0.0.1 www.deepin.com`，如果执行成功返回结果，类似如下：
```
; <<>> DiG 9.8.2rc1-RedHat-9.8.2-0.47.rc1.deepin15 <<>> @127.0.0.1 www.deepin.com
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 48256
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 1

;; QUESTION SECTION:
;www.deepin.com.                        IN      A

;; ANSWER SECTION:
www.deepin.com.         604800  IN      A       192.168.1.2

;; AUTHORITY SECTION:
deepin.com.             604800  IN      NS      deepin.com.

;; ADDITIONAL SECTION:
deepin.com.             604800  IN      A       192.168.1.1

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Thu Jun 29 14:50:50 2017
;; MSG SIZE  rcvd: 78

```
   * 验证域名解析`dig @127.0.0.1 -x 192.168.1.1`，如果执行成功返回结果，类似如下： 
```
; <<>> DiG 9.8.2rc1-RedHat-9.8.2-0.47.rc1.deepin15 <<>> @127.0.0.1 -x 192.168.1.1
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 20838
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 1

;; QUESTION SECTION:
;1.1.168.192.in-addr.arpa.      IN      PTR

;; ANSWER SECTION:
1.1.168.192.in-addr.arpa. 604800 IN     PTR     deepin.com.

;; AUTHORITY SECTION:
1.168.192.in-addr.arpa. 604800  IN      NS      deepin.com.

;; ADDITIONAL SECTION:
deepin.com.             604800  IN      A       192.168.1.1

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Thu Jun 29 14:51:48 2017
;; MSG SIZE  rcvd: 96

```

至次，bind的基本配置已经完成，更多配置参考`man 5 named.conf`。
