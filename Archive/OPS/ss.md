


作为一个合格的程序员，怎么可以不会科学上网？自己搭建一个shadowsocks，ss可以不限人数，不限系统（Linux、Windows、iPhone、Android、Mac都可以）。岂不美滋滋？
在GFW之外的VPS

自己搭建ss，首先肯定要有一个在墙外的服务器作为跳板。Vultr很稳定，售后服务回应很及时，并且我选的最低配置的网速也很不错。我搭的ss大概同时有20个人在使用，日常使用觉得完全满足需求。

    注册

注册地址：Vultr，很简单，按照步骤注册即可

    充值

选择左侧栏的Billing，选择个充值方式即可（支持支付宝Alipay，支持支付宝Alipay，支持支付宝Alipay）。目前2.5刀的服务器在Miami和New York地区有售（延迟相对其他地区稍高），其他都售罄了，赶紧抢购吧~充10送10活动不知道有没有了，当时我是有的~。不过2.5刀算是我看到的最便宜的VPS供应商了。

    配置VPS

选择左侧栏的Servers：Server Location是Los Angels和Tokyo的比较好；Server Type选择Ubuntu（当然也可以不选择Ubuntu，本教程是基于Ubuntu的）,Server Size根据需求选择。其他都可以默认，然后选择Deploy Now就可以了。

    查看相关信息

配置完服务器后，在Servers就可以看到自己服务的信息了，包括我们需要用到的IP和Password。得到IP和密码就可以用XShell进行连接了。
在VPS上配置shadowsocks
shadowsocks：A fast tunnel proxy that helps you bypass firewalls.
开源项目：项目地址
在Ubuntu上的安装步骤（全程root权限）：

    更新软件源

apt-get update

    1

    安装pip环境

apt-get install python-pip

    1

    安装shadowsocks

pip install shadowsocks

    1

此时，如果出现了提示版本太低，则按照提示更新

pip install --upgrade pip

    1

如果提示没有setuptools模块，则安装setuptools

pip install setuptools

    1

    如果刚才shadowsocks安装成功则跳过这一步，某则继续安装shadowsocks

pip install shadowsocks

    1

    编辑配置文件

 vim /etc/shadowsocks.json

    1

添加：

{
    "server":"my_server_ip",
    "server_port":8388,//默认是8388，如果不行可以换成1024试试（这句注释删除）
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"mypassword",
    "timeout":300,
    "method":"aes-256-cfb"
}

    1
    2
    3
    4
    5
    6
    7
    8
    9

name 	info
server 	服务器 IP (IPv4/IPv6)，注意这也将是服务端监听的 IP 地址
server_port 	服务器端口
local_port 	本地端端口
password 	用来加密的密码
timeout 	超时时间（秒）
method 	加密方法，可选择 “bf-cfb”, “aes-256-cfb”, “des-cfb”, “rc4″, 等等。默认是一种不安全的加密，推荐用 “aes-256-cfb”

    赋予文件权限

chmod 755 /etc/shadowsocks.json

    1

    安装以支持这些加密方式

apt-get install python-m2crypto

    1

    后台运行

ssserver -c /etc/shadowsocks.json -d start

    1

    停止命令

ssserver -c /etc/shadowsocks.json -d stop

    1

    设置开机自启动

vim /etc/rc.local

    1

加上如下命令：

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

    1
    2
    3
    4
    5
    6
    7
    8
    9
    10
    11
    12
    13
    14
    15

如果没有自动启动，参考http://forum.ubuntu.org.cn/viewtopic.php?f=186&t=481439
本机上配置shadowsocks

    下载（各种版本的Clients）

首先去下一个shadowsocks for windows，here(shadowsocks4.0.2)

    配置

在windows上运行ss对framework的版本要求比较高，目前的版本要求是4.6.2，先去下载一个安装起来，here(Framework4.6.2)

在状态栏右击shadowsocks，勾选开机启动和启动系统代理，在系统代理模式中选择PAC模式，服务器->编辑服务器，用shadowsocks.json中配置的相应的ip、密码、加密方法填好，保存即可。

Done！翻墙吧，兄弟！Google

一键安装ss脚本，可以参考：一键安装shadowsocks&开启BBR加速


https://shadowsocks.org/en/download/clients.html
