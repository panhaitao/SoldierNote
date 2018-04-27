
nslookup(域名查询)：是一个用于查询 Internet域名信息或诊断DNS 服务器问题的工具。主要用来诊断域名系统 (DNS) 基础结构的信息。
 
nslookup可以指定查询的类型，可以查到DNS记录的生存时间，还可以指定使用哪个DNS服务器进行解释。nslookup最简单的用法就是查询域名对应的IP地址，包括A记录和CNAME记录，如果查到的是CNAME记录还会返回别名记录的设置情况。 
 
nslookup的安装
nslookup 工具没有默认集成，需要用户手动安装，先执行命令# apt-get update 更新源列表，然后执行命令# apt-get install dnsutils来安装nslookup 工具。
 
nslookup 命令的一般用法:
 nslookup  域名
 
例如 运行命令nslookup 163.com查询163.com域名信息：
$ nslookup 163.com
Server:	127.0.1.1
Address:	127.0.1.1#53
 
Non-authoritative answer:
Name:	163.com
Address: 123.58.180.8
Name:	163.com
Address: 123.58.180.7
 
指定查询记录类型：
语法为 nslookup -q=类型 目标域名
 
类型主要有:
A 地址记录(Ipv4)
AAAA 地址记录（Ipv6）
AFSDBAndrew文件系统数据库服务器记录
ATMA ATM地址记录
CNAME 别名记录
HINFO硬件配置记录，包括CPU、操作系统信息
ISDN域名对应的ISDN号码
MB 存放指定邮箱的服务器
MG 邮件组记录
MINFO 邮件组和邮箱的信息记录
MR 改名的邮箱记录
MX邮件服务器记录
NS 名字服务器记录
PTR 反向记录
RP 负责人记录
RT 路由穿透记录
SRV TCP服务器信息记录
TXT域名对应的文本信息
X25域名对应的X.25地址记录
例如运行如下命令，163.com查看邮件服务器记录:
$ nslookup -q=mx 163.com
 
nslookup的命令就介绍到这里，其实nslookup还有许多其他参数，用户可以直接运行man nslookup查看man手册。