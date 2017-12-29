

john最好称之为John the Ripper，是一个破解（查找）用户弱口令的工具。John使用字典或某个搜索模式以及要检查口令的口令文件，它支持不同的破解模式并能理解多种密码格式，比如DES变体、MD5和blowfish。
 
john the ripper是一款大受欢迎的、基于字典的密码破解工具。它使用内容全是密码的单词表，然后使用单词表中的每一个密码，试图破解某个特定的密码散列。换句话说，它又叫蛮力密码破解，这是一种最基本的密码破解方式。不过它也是最耗费时间、最耗费处理器资源的一种方法。尝试的密码越多，所需的时间就越长。
 
john安装
在深度服务器操作系统john工具的安装方式有两种：
Tasksel安装方式
1. 配置好软件源，配置软件源请参考本手册的2.3节。
2. 在命令行执行tasksel命令，在打开的tasksel软件选择界面，选中“john”，	光标移动到“ok/确定”按钮，敲击回车键，系统就开始安装。
 
命令行安装方式
1. 配置好软件源，配置软件源请参考本手册的2.3节。
2. 在命令行执行命令apt-get install john或aptitude 	install john，系统就开始安装。
 
 
john语法
john的一般格式为
john [options] password-files
 其中，password-files为口令文件
 
john的常用option参数及其含义见表4.2
 
表4.2 john的常用option参数及含义
选项
描述
--single 
single crack模式，使用配置文件中的规则进行破解
--wordlist
--stdin
字典模式，从FILE或标准输入中读取词汇
--rules
打开字典模式规则，
--incremental
使用增量模式
-external
打开外部模式或单词过滤，使用[List.External:MODE]节中定义的外部函数
--stdout
不进行破解，仅仅把生成的、要测试是否为口令的词汇输出到标准输出上
--restore
恢复被中断的破解过程，从指定文件或默认为~/.john/john.rec的文件中读取破解过程的状态信息
--session=NAME
将新的破解会话命名为NAME，该选项用于会话中断恢复和同时运行多个破解实例的情况
 
--status
显示会话状态
--makechars
生成一个字符集文件，覆盖FILE文件，用于增量模式
 
--show
显示已破解的口令
--test
进行基准测试
--shells
对使用指定shell的账户进行操作
 
john更多更详细的选项参数及其含义，用户可以直接执行man john查看。
 
 
除了口令破解程序之外，在这个软件包中，还包含了其他几个实用工具，它们对于实现口令破解都有一定的帮助,如unshadow命令将passwd文件和shadow文件组合在一起，其结果用于John破解程序。通常应该使用重定向方法将这个程序的结果保存在文件中，之后将文件传递给John破解程序。
 
 
john简单应用
1. 分别执行如下命令，创建用户testuser1,testuser2并设置其口令
 
useradd -m testuser1;
useradd -m testuser2;
passwd testuser1;       /设置其口令为pass
passwd testuser2;       /设置其口令为abc123
注：为了方便演示，最好使用一个简单的密码，那样你没必要等待太长的时间
2. 执行如下unshadow命令基本上会结合/etc/passwd的数据和/etc/shadow的数据，创建1个含有用户名和密码详细信息的文件file_to_crack的新文件。
 
unshadow /etc/passwd /etc/shadow >file_to_crack
 
3.  执行如下命令，使用Linux上的John随带的密码列表，破解用户testuser1、testuser2的口令
john --wordlist=/usr/share/john/password.lst ~/file_to_crack 
 
口令破解成功。
4. 使用show选项，列出所有被破解的密码，结果显示如下
john  --sow ~/file_to_crack 
 
test:pass:1000:1000:test,,,:/home/test:/bin/bash
testuser1:pass:1001:1001::/home/testuser1:/bin/sh
testuser2:abc123:1002:1002::/home/testuser2:/bin/sh
 
3 password hashes cracked, 2 left
 
