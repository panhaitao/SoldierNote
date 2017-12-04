# ltrace概述
ltrace命令是用来跟踪进程调用库函数的情况。它会显现出哪个库函数被调用。
 
ltrace安装
在深度服务器操作系统ltrace工具的安装方式有两种：
Tasksel安装方式
1. 配置好软件源，配置软件源请参考本手册的2.3节。
2. 在命令行执行tasksel命令，在打开的tasksel软件选择界面，选中“ltrace”，	光标移动到“ok/确定”按钮，敲击回车键，系统就开始安装。
 
命令行安装方式
1. 配置好软件源，配置软件源请参考本手册的2.3节。
2. 在命令行执行命令apt-get install ltrace或aptitude 	install ltrace，系统就开始安装。
 
ltrace用法
ltrace的一般用法
ltrace [option ...] [command [arg ...]]
即Trace library calls of a given program
 
ltrace命令常用的选项参数及其含义如表5.17所示。
 
表5.17 ltrace常用选项参数及其含义
短参数
长参数
含义
-a
--align
对其具体某个列的返回值
-c
 
计算时间和调用，并在退出时打印摘要
-C
--demangle
解码低级别符号名（内核级）成用户级名
-D
--debug
打印调试信息
-e
 
改变跟踪的库调用事件
-f
 
跟踪子进程
-h
--help
显示ltrace选项的概要信息
-i
 
当库调用时，打印指令指针
-l
--library
只打印某个库中的调用
-L
 
不打印库调用
-n
--indent=nr
对每个调用级别嵌套以NR个空格进行缩进输出
-o
--output=file
把输出定向到文件
-p
 
附着在值为PID的进程号上进行ltrace
-r
 
在每个跟踪行打印相对时间戳
-S
 
显示系统调用和库调用
-t/-tt/-ttt
 
打印绝对时间
-T
 
输出每个调用过程的时间开销
-u
 
使用用户id或组id或补充组的名字来运行命令
-V
--version
显示ltrace的版本号
 
 
ltrace命令的其他更多参数及其含义，用户可以直接运行man ltrace即可查看。
 
ltrace应用举例
1. 确认gcc编译工具已经被安装。
2. 在测试机的tty1以tester用户身份登录系统，编辑测试程序test01.c内容如下
#include<stdio.h>
        void main()
        {
        printf("This is a testing program about 	ltrace!\n");
        }
3. 执行gcc -o test01 test01.c命令，生成可执行文件test01
4. 执行ltrace -o test01.txt ./test01命令，即可显示“This is a testing 	program about	ltrace!”。
5. 执行cat test01.txt，系统显示如下
__libc_start_main(0x400506, 1, 0x7ffd1f3c70f8, 0x400520 	<unfinished ...>
puts("This is a testing program about\t"...)      = 40
+++ exited (status 40) +++
 
可以看到调用了puts()库函数打印出字符串。
