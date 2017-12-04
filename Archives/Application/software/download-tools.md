深度服务器操作系统使用网络下载工具有wget、curl、axel。
 
非交互式的网络文件下载工具wget
深度服务器操作系统中的wget是一个下载文件的工具，它用在命令行下。对于深度服务器操作系统用户是必不可少的工具，我们经常要下载一些软件或从远程服务器恢复备份到本地服务器。wget支持HTTP，HTTPS和FTP协议，可以使用HTTP代理。所谓的自动下载是指，wget可以在用户退出系统的之后在后台执行。这意味这你可以登录系统，启动一个wget下载任务，然后退出系统，wget将在后台执行直到任务完成，相对于其它大部分浏览器在下载大量数据时需要用户一直的参与，这省去了极大的麻烦。
 
wget命令的一般用法：
wget [选项] ...[URL]... 
 
wget的“选项”又分为启动选项、日志和输入文件选项、下载选项、目录选项、递归下载选项等，相应参数的意义请参见表1.20-1.24。

wget [选项] ...[URL]... 
 
例如常见的使用方法是远程拷贝文件，从server1拷贝文件到server2上。需要先在server2上，用nc激活监听，
server2上运行： nc -l -p 1234 > testfile   
server1上运行： nc 10.1.11.240 1234 < test1.txt
注：server2上的监听要先打开(命令必须是nc -l -p 因nc命令链接到/bin/nc.traditional),这样server2上的test1.txt文件的内容就被传输到server2上testfile中了。
 
nc命令的其他参数及其意义，用户可以直接运行man nc即可查看。
 
 
表1.20 wget命令常用的启动参数说明
短参数
长参数
参数说明
-V
--version
显示wget的版本后退出
-h
--help
打印语法帮助
-b
--background
启动后转入后台执行
-e
--execute=COMMAND
执行`.wgetrc’格式的命令
 
 
表1.21 wget命令常用的日志和输入文件参数说明
短参数
长参数
参数说明
-o
--output-file=FILE
把记录写到FILE文件中
-a
--append-output=FILE
把记录追加到FILE文件中
-d
--debug
打印调试输出
-q
--quiet
安静模式(没有输出)
-v
--verbose
冗长模式(这是缺省设置)
-F
--force-html
把输入文件当作HTML格式文件对待
 
 
表1.22 wget命令常用的下载参数说明
短参数
长参数
参数说明
-t
--tries=NUMBER
设定最大尝试链接次数(0 表示无限制)
-c
--continue
接着下载没下载完的文件
-o
--output-document=FILE
把文档写到FILE文件中
-N
--timestamping
不要重新下载文件除非比本地文件新
-T
--timeout=SECONDS
打开或关闭代理
-Q
--quota=NUMBER
设置下载的容量限制
 
 
表1.23 wget命令常用的目录参数说明
短参数
长参数
参数说明
-nd
--no-directories
不创建目录
 
-x
--force-directories
强制创建目录
-nh
--no-host-directories
不创建主机目录
-P
--directory-prefix=PREFIX
将文件保存到目录 PREFIX/…
 
 
表1.24 wget命令常用的递归下载参数说明
短参数
长参数
参数说明
-r
--recursive
递归下载－－慎用
-l
--level=NUMBER
最大递归深度 (inf 或 0 代表无穷)
-k
--convert-links
转换非相对链接为相对链接
-K
--backup-converted
在转换文件X之前，将之备份为 X.orig
-m
--mirror
等价于 -r -N -l inf -nr
-p
--page-requisites
下载显示HTML文件的所有图片
 
–limit-rate=RATE
限定下载输率
 
例如运行下面命令限速为300k下载文件wordpress-3.1-zh_CN.zip
  wget --limit-rate=300k \
  http://www.minjieren.com/wordpress-3.1-zh_CN.zip
说明：当你执行wget的时候，它默认会占用全部可能的宽带下载。但是当你准备下载一个大文件，而你还需要下载其它文件时就有必要限速了。
 
例如运行下面命令后台下载文件wordpress-3.1-zh_CN.zip：
wget -b http://www.minjieren.com/wordpress-3.1-zh_CN.zip
说明：对于下载非常大的文件的时候，我们可以使用参数-b进行后台下载。
 
wget命令的其他参数及其意义，用户可以直接运行man wget即可查看。
 
非交互式的数据传输工具curl
 
curl是利用URL语法在命令行方式下工作的开源文件传输工具。它支持文件的上传和下载，所以是综合传输工具，但按传统习惯称curl为下载工具。
 
Curl的安装：
执行如下命令，进行安装curl工具
apt-get install curl
 
 
curl的一般用法：
curl  [options...]  <url>
 
 
curl的常用选项包括-a、-b、-o、-c、-D、-f、-e、-r、-s，它们的具体意义请参见表1.25。
 
表1.25 curl命令常用参数说明
短参数
长参数
参数说明
-a
--append
上传文件时，附加到目标文件
-b
-cookie <name=string/file>
cookie字符串或文件读取位置
-o
--output
把输出写到该文件中
-c
--cookie-jar <file>
操作结束后把cookie写入到这个文件中
-D
--dump-header <file>
把header信息写入到该文件中
-d
--data <data> 
HTTP POST方式传送数据
-f
--failed
连接失败时不显示http错误
-e
--referer
来源网址
-r
--range <range>
检索服务器字节范围
-s
--silent
静音模式。不输出任何东西
 
例如运行下面命令，www.linuxidc.com的html 就显示在屏幕上了：
#curl http://www.linuxidc.com
 
例如运行下面命令，将页面内容抓取到一个文件中：
# curl -o page.html http://www.linuxidc.com
这样，你就可以看到屏幕上出现一个下载页面进度指示。等进展到100%就OK了。
 
curl命令的其他参数及其意义，用户可以直接运行man curl即可查看
 
轻量级的linux下载加速器axel
axel 命令行下的多线程下载工具，支持断点续传, 通常我们用它取代 wget 下载各类文件。
 
Axel工具的安装：
axel 工具没有默认集成，需要用户手动安装，分别执行如下命令
# apt-get update 	//更新源列表
# apt-get install axel	//来安装axel 工具。
 
axel命令的一般用法：
axel [ options ] url1 [ url2 ]  [ url... ]
