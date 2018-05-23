# VPN 翻墙


## shadowsocks 

* 项目主页: https://github.com/shadowsocks/
* 国外VPS推荐：Vultr 

## 服务端配置

* ubuntu server 

```
apt-get update
apt-get install python-pip
pip install --upgrade pip
pip install setuptools
pip install shadowsocks
```
* centos server

```
yum install python-pip
pip install --upgrade pip
pip install shadowsocks

```

* 编辑配置文件

```
cat > /etc/shadowsocks.json << EOF
{
    "server":"my_server_ip",
    "server_port":8388,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"your_password",
    "timeout":300,
    "method":"aes-256-cfb"
}
EOF
```

* name 	        info
* server   	服务器 IP (IPv4/IPv6)，注意这也将是服务端监听的 IP 地址
* server_port 	服务器端口,默认是8388，如果不行可以换成1024试试（这句注释删除）
* local_port 	本地端端口
* password 	用来加密的密码
* timeout 	超时时间（秒）
* method 	加密方法，可选择 “bf-cfb”, “aes-256-cfb”, “des-cfb”, “rc4″, 等等。默认是一种不安全的加密，推荐用 “aes-256-cfb”


* 赋予文件权限 `chmod 755 /etc/shadowsocks.json`
* 安装以支持这些加密方式 `apt-get install python-m2crypto`
* 后台运行 `ssserver -c /etc/shadowsocks.json -d start`
* 停止命令 `ssserver -c /etc/shadowsocks.json -d stop`

   
* 设置开机自启动

vim /etc/rc.local

#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
ssserver -c /etc/shadowsocks.json -d start
exit 0

## 客户端


* windows配置

下载地址: https://shadowsocks.org/en/download/clients.html

安装好客户端后，在状态栏右击shadowsocks，勾选开机启动和启动系统代理，在系统代理模式中选择PAC模式，服务器->编辑服务器，用shadowsocks.json中配置的相应的ip、密码、加密方法填好，保存即可。

* linux 配置

1. 安装客户端软件包 `apt install shadowsocks`

`sslocal -s server_ip -p server_port  -l 1080 -k password -t 600 -m aes-256-cfb`

2. 启动SS客户端

```
-s 表示服务IP, 
-p 指的是服务端的端口，
-l 是本地端口默认是1080（可以替换成任何端口号，只需保证端口不冲突）, 
-k 是密码（要加""）, 
-t 超时默认300,
-m 是加密方法默认aes-256-cfb，
```

3. 配置浏览器

* firefox 60, 首选项-> 网络代理-> 设置手动代理：(socks v5) 127.0.0.1：1080

其他客户端程序，https://sourceforge.net/projects/shadowsocksgui/files/dist/

* android 客户端

https://github.com/shadowsocks/shadowsocks-android/releases

# 其他 topic

shadowsocks&开启BBR加速



