---
title: "设置本地化与时区"
categories: CentOS7
tags: 系统管理
---
## 设置本地化与时区

### 本地化与时区设置
 
本地化设置(locale)，也称作“本地化策略集”、“本地环境”，是表达程序用戶地区方面的软件设定。不同系统、平台、与软件有不同的区域设置处理方式和不同的设置范围，但是一般区域设置最少也会包括语言和地区。操作系统的区域设置通常比较复杂。区域设置的内容包括：数据格式、货币金额格式、小数点符号、千分位符号、度量衡单位、通货符号、日期写法、日历类型、文字排序、姓名格式、地址等等。

### 查看本地化环境变量

在深度操作系统服务器版软件V16版本中，可以通过执行locale命令来查看相关环境变量：

```
[root@deepin-server ~]# locale
LANG=zh_CN.UTF-8
LC_CTYPE=“zh_CN.UTF-8”
LC_NUMERIC=“zh_CN.UTF-8”
LC_TIME=“zh_CN.UTF-8”
LC_COLLATE=“zh_CN.UTF-8”
LC_MONETARY=“zh_CN.UTF-8”
LC_MESSAGES=“zh_CN.UTF-8”
LC_PAPER=“zh_CN.UTF-8”
LC_NAME=“zh_CN.UTF-8”
LC_ADDRESS=“zh_CN.UTF-8”
LC_TELEPHONE=“zh_CN.UTF-8”
LC_MEASUREMENT=“zh_CN.UTF-8”
LC_IDENTIFICATION=“zh_CN.UTF-8”
LC_ALL=
```
以上各项配置项含义如下：


| 配置项 | 意义 |
|--------------------------|--------------------------------|
| LANG                          | 提供系统区域设置的默认值 |
| LC_CTYPE                  | 用于字符分类和字符串处理，控制所有字符的处理方式，包括字符编码，字符是单字节还是多字节，如何打印等 | 
| LC_NUMERIC             | 指定使用某区域的非货币的数字格式                                                          |
| LC_TIME                     | 指定使用某区域的日期和时间格式                                                              |
| LC_COLLATE              | 定义更改比较本地字母表中的字符串的函数的行为该环境的排序和比较则 |
| LC_MONETARY          | 指定使用某区域的货币格式                                                                         |
| LC_MESSAGES          | 确定用于写入标准错误输出的诊断消息的区域设置                                     |
| LC_PAPER                  | 指定使用某区域的纸张大小                                                                         |
| LC_NAME                   | 指定使用某区域的姓名书写方式                                                                  |
| LC_ADDRESS             | 指定使用某区域的地址格式和位置信息                                                      |
| LC_TELEPHONE         | 指定使用某区域的电话号码格式                                                                 |
| LC_MEASUREMENT   |  指定使用某区域的度量衡规则                                                                   |
| LC_IDENTIFICATION   | 对 locale 自身信息的概述                                                                           |
| LC_ALL                        | 这不是一个环境变量，是一个可被C语言库函数setlocale设置的宏，其值可覆盖所有其他的locale设定。因此缺省时此值为空  |

### 列出可用的语言环境
　　
要列出系统可用的所有区域设置，执行命令locale -a 将会输出如下示例内容：

```　
　…
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
　　…
　　(由于输出篇幅过⻓，只截取部分)
```
### 修改语言环境配置

系统默认语言环境在 ** /etc/locale.conf ** 文件中定义，该文件是在systemd守护程序启动时读取，并调用locale命令来完成初始化设置。可以配置系统默认语言环境，此配置由每个服务或用戶继承，除非个别程序或个别用戶的自定义覆盖系统的默认配置， 如果安装过程选择的中文语言环境，** /etc/locale.conf ** 文件的内容将如下所示：
    
    LANG=“zh_CN.UTF-8”
用戶可以根据需要自定义环境变量覆盖系统的默认配置， 例如执行命令将语言环境修改为英文，临时修改的配置，只针对当前会话生效，如果需要持久存储配置，可以修改用戶家目录的相关配置文件~/.bashrc

    export LANG=en_US.UTF-8
### 其他参考部分

相关系统命令：
* locale 列出当前采用的各项本地策略，这些由`LC_*`环境变量定义
* locale charmap 列出系统当前使用的字符集
* locale -a 列出系统中已经安装的所有locale
* locale -m 列出系统中已经安装的所有charmap
* localedef locale的生成工具 exzample：localedef -f UTF-8 -i zh_CN zh_CN.UTF-8
相关系统文件：
* 在目录/usr/share/i18n/charmaps下，缺省的charmap存放路径
* 在目录/usr/share/i18n/locales下， 缺省的locale source file存放路径
* 在文件/usr/lib/locale/locale-archive中，包含了很多本地已经生成的locale的具体内容，使用命令localedef管理
