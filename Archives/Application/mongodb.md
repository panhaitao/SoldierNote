
mongodb概述
MongoDB是一种文件导向数据库管理系统，由C++撰写而成，以此来解决应用程序开发社区中的大量现实问题。2007年10月，MongoDB由10gen团队所发展。2009年2月首度推出。
 
MongoDB使用内存映射文件, 32位系统上限制大小为2GB的数据 (64-比特支持更大的数据).MongoDB服务器只能用在小端序系统，虽然大部分公司会同时准备小端序和大端序系统。
 
语言支持
MongoDB有官方的驱动如下：
    C
    C++
    C# / .NET
    Erlang
    Haskell
    Java
    JavaScript
    Lisp
    node.JS
    Perl
    PHP
    Python
    Ruby
    Scala
 
mongodb的安装
在深度服务器操作系统mongodb服务器的安装方式有两种：
Tasksel安装方式
1. 配置好软件源，配置软件源请参考本手册的2.3节。exit
2. 在命令行执行tasksel命令，在打开的tasksel软件选择界面，选中“mongodb 	database”，光标移动到“ok/确定”按钮，敲击回车键，系统就开始安装。
 
命令行安装方式
1. 配置好软件源，配置软件源请参考本手册的2.3节。
2. 在命令行执行命令apt-get install mongodb-server或
aptitude  install mongodb-server，系统就开始安装。
 
mongodb的简单应用
1. root用户登录系统，执行如下命令重启mongodb服务。
/etc/init.d/mongodb restart
2. 执行命令mongo进入mongodb命令行模式。
3. 执行如下命令，新建集合user。
> db.createCollection("user");
4. 分别执行如下命令，向user集合中插入两条记录。
> db.user.insert({uid:001,username:"zhang",age:25});
> db.user.insert({uid:002,username:"wang",age:30});
5. 查看uid为001的记录,显示如下。
> db.user.find({uid:001}); 
6. 删除uid为1的记录，应有预期结果5。
> db.user.remove({uid:1});
{ "_id" : ObjectId("55e4167a1bfb92aa590086b7"), "uid" : 1, 	"username" : "zhang", "age" : 25 }
7. 执行exit命令，退出数据库操作。
