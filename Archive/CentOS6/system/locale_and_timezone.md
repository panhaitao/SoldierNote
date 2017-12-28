---
title: "设置本地化与时区"
categories: CentOS6
tags: 系统管理
---

## 设置本地化与时区

### 本地化设置(locale)

本地化设置（locale），也称作“本地化策略集”、“本地环境”，是表达程序用户地区方面的软件设定。不同系统、平台、与软件有不同的区域设置处理方式和不同的设置范围，但是一般区域设置最少也会包括语言和地区。操作系统的区域设置通常比较复杂。区域设置的内容包括：数据格式、货币金额格式、小数点符号、千分位符号、度量衡单位、通货符号、日期写法、日历类型、文字排序、姓名格式、地址等等。

在深度服务器操作系统V15版本中，可以通过执行`locale`命令来查看相关环境变量：

```bash
[root@deepin-server ~]# locale
LANG=zh_CN.UTF-8
LC_CTYPE="zh_CN.UTF-8"
LC_NUMERIC="zh_CN.UTF-8"
LC_TIME="zh_CN.UTF-8"
LC_COLLATE="zh_CN.UTF-8"
LC_MONETARY="zh_CN.UTF-8"
LC_MESSAGES="zh_CN.UTF-8"
LC_PAPER="zh_CN.UTF-8"
LC_NAME="zh_CN.UTF-8"
LC_ADDRESS="zh_CN.UTF-8"
LC_TELEPHONE="zh_CN.UTF-8"
LC_MEASUREMENT="zh_CN.UTF-8"
LC_IDENTIFICATION="zh_CN.UTF-8"
LC_ALL=

```

以上各项配置项含义如下：

| 配置项            |                  描述                                                                                              |
|-------------------|--------------------------------------------------------------------------------------------------------------------|
| LANG              | 提供系统区域设置的默认值,`LC_*`的默认值，是最低级别的设置，如果`LC_*`没有设置，则使用该值                          |
| LC_CTYPE          | 用于字符分类和字符串处理，控制所有字符的处理方式，包括字符编码，字符是单字节还是多字节，如何打印等                 |
| LC_NUMERIC        | 指定使用某区域的非货币的数字格式                                                                                   |
| LC_TIME           | 指定使用某区域的日期和时间格式                                                                                     | 
| LC_COLLATE        | 定义更改比较本地字母表中的字符串的函数的行为该环境的排序和比较则                                                   |
| LC_MONETARY       | 指定使用某区域的货币格式                                                                                           |
| LC_MESSAGES       | 确定用于写入标准错误输出的诊断消息的区域设置                                                                       |
| LC_PAPER          | 指定使用某区域的纸张大小                                                                                           | 
| LC_NAME           | 指定使用某区域的姓名书写方式                                                                                       | 
| LC_ADDRESS        | 指定使用某区域的地址格式和位置信息                                                                                 |
| LC_TELEPHONE      | 指定使用某区域的电话号码格式                                                                                       |
| LC_MEASUREMENT    | 指定使用某区域的度量衡规则                                                                                         |
| LC_IDENTIFICATION | 对 locale 自身信息的概述                                                                                           |
| LC_ALL            | 这不是一个环境变量，是一个可被C语言库函数setlocale设置的宏，其值可覆盖所有其他的locale设定。因此缺省时此值为空     |


### 列出可用的语言环境

要列出系统可用的所有区域设置，执行命令`locale -a`，将会输出如下示例内容

```
...
yi_US
yi_US.cp1255
yi_US.utf8
yo_NG
yo_NG.utf8
zh_CN
zh_CN.gb18030
zh_CN.gb2312
zh_CN.gbk
zh_CN.utf8
zh_HK
zh_HK.big5hkscs
zh_HK.utf8
...
```
**(由于输出篇幅过长，只截取部分)**

### 修改语言环境配置

* 系统默认语言环境用户可以根据需要自行

在`/etc/sysconfig/i18n`文件中，该文件是在init守护程序启动时读取，并调用locale命令来完成初始化设置。可以配置系统默认语言环境,此配置由每个服务或用户继承，除非个别程序或个别用户的自定义覆盖系统的默认配置, 如果安装过程选择的中文语言环境，`/etc/sysconfig/i18n`文件的内容将如下所示：
```
LANG="zh_CN.UTF-8"
```

* 用户自定义配置

用户可以根据需要自定义环境变量覆盖系统的默认配置, 例如执行命令将语言环境修改为英文，`export LANG=en_US.UTF-8` ，临时修改的配置，只针对当前会话生效，如果需要持久存储配置，可以修改`~/.bashrc`用户家目录的相关配置文件
 

### 其他参考部分 

* 相关系统命令：
   * locale 列出当前采用的各项本地策略，这些由`LC_*`环境变量定义
   * locale charmap 列出系统当前使用的字符集
   * locale -a 列出系统中已经安装的所有locale
   * locale -m 列出系统中已经安装的所有charmap
   * localedef locale的生成工具 exzample: `localedef -f UTF-8 -i zh_CN zh_CN.UTF-8`
* 相关系统文件：
   * 在目录/usr/share/i18n/charmaps下，缺省的charmap存放路径
   * 在目录/usr/share/i18n/locales下， 缺省的locale source file存放路径
   * 在文件/usr/lib/locale/locale-archive中，包含了很多本地已经生成的locale的具体内容，使用命令localedef管理这一文件


<br>
<br>
<br>
<br>
<br>
<br>

### 时区设置

时区（Time Zone)是地球上的区域使用同一个时间定义. 

### 确认当前时区

可以通过执行命令`date +%z`输出来确认当前系统时区配置，如下例子显示当前系统时区配置为东8区：

```
[root@deepin-server ~]# date  +%z
+0800
```
 
#### 修改默认时区

可以通过执行命令`tzselect` 修改默认时区配置，如下是一个修为时区设置为`Asia/China/Beijing Time`的例子：

```
[root@deepin-server ~]# tzselect
Please identify a location so that time zone rules can be set correctly.
Please select a continent or ocean.
 1) Africa
 2) Americas
 3) Antarctica
 4) Arctic Ocean
 5) Asia
 6) Atlantic Ocean
 7) Australia
 8) Europe
 9) Indian Ocean
10) Pacific Ocean
11) none - I want to specify the time zone using the Posix TZ format.
#? 5
Please select a country.
 1) Afghanistan           18) Israel                35) Palestine
 2) Armenia               19) Japan                 36) Philippines
 3) Azerbaijan            20) Jordan                37) Qatar
 4) Bahrain               21) Kazakhstan            38) Russia
 5) Bangladesh            22) Korea (North)         39) Saudi Arabia
 6) Bhutan                23) Korea (South)         40) Singapore
 7) Brunei                24) Kuwait                41) Sri Lanka
 8) Cambodia              25) Kyrgyzstan            42) Syria
 9) China                 26) Laos                  43) Taiwan
10) Cyprus                27) Lebanon               44) Tajikistan
11) East Timor            28) Macau                 45) Thailand
12) Georgia               29) Malaysia              46) Turkmenistan
13) Hong Kong             30) Mongolia              47) United Arab Emirates
14) India                 31) Myanmar (Burma)       48) Uzbekistan
15) Indonesia             32) Nepal                 49) Vietnam
16) Iran                  33) Oman                  50) Yemen
17) Iraq                  34) Pakistan
#? 9
Please select one of the following time zone regions.
1) Beijing Time
2) Xinjiang Time
#? 1

The following information has been given:

        China
        Beijing Time

Therefore TZ='Asia/Shanghai' will be used.
Local time is now:      Thu Jun 22 21:40:16 CST 2017.
Universal Time is now:  Thu Jun 22 13:40:16 UTC 2017.
Is the above information OK?
1) Yes
2) No
#? 1

You can make this change permanent for yourself by appending the line
        TZ='Asia/Shanghai'; export TZ
to the file '.profile' in your home directory; then log out and log in again.

Here is that TZ value again, this time on standard output so that you
can use the /usr/bin/tzselect command in shell scripts:
Asia/Shanghai

```

#### 其他参考部分 

* 相关系统文件/etc/sysconfig/clock
* 时区的信息存在/usr/share/zoneinfo/下面，
* 本机的时区信息存在/etc/localtime
