---
title: "系统时间和日期设置"
categories: CentOS6
tags: 系统管理
---

## 设置时间和日期 

本小节包括手动和使用网络时间协议（NTP）中设置系统日期和时间。

### 手动设置日期和时间

可以超级用户是身份通过date命令来手动设置系统日期和时间，在shell提示符下输入`date +％D -s YYYY-MM-DD `格式的命令，将YYYY替换为四位数年份，MM为两位数字，DD为两位数的一天。 

例如，要将日期设置为2017年6月22日，请输入：

```
#date +％D -s 2017-06-02
```

更改当前时间。使用以下格式`date +％T -s HH：MM：SS`的命令，其中HH表示一小时，MM为一分钟，SS为秒，全部以两位数形式输入，如果您的系统时钟设置为使用UTC（UTC代表世界时间，也称为格林威治标准时间（GMT）,其他时区由UTC时间加或减来确定），请添加以下`-u`选项：

例如，要使用UTC将系统时钟设置为11:26 PM，请输入：

```
＃date +％T -s 23:26:00 -u 
```

### 使用NTP服务器同步时间和日期 


与上述手动设置相反，您还可以通过网络时间协议（NTP）将系统时钟与远程服务器同步。 
1. 首先,检查 NTP 服务器是否可用，`ntpdate -q server_address`，例如：
```
# ntpdate -q 0.centos.pool.ntp.org
```
2. 当您找到满意的服务器时，可以运行ntpdate命令完成一次时间同步，后面可以跟一个或多个服务器地址，例如：
```
# ntpdate 0.centos.pool.ntp.org
```
3. 在大多数情况下，这些步骤就足够了。 如果需要一个或多个系统保持正确的时间状态，可以将`/etc/ntp.conf`配置文件如下部分中修改为您需要的服务器
```
server 0.centos.pool.ntp.org iburst
server 1.centos.pool.ntp.org iburst
server 2.centos.pool.ntp.org iburst
server 3.centos.pool.ntp.org iburst
```
然后设置ntpdate服务默认启动，操作如下:
```
# chkconfig ntpdate on
```
有关系统服务及其设置的更多信息，请参阅第12章“服务和守护程序”。


