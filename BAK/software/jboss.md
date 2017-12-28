Jboss服务器概述
Jboss服务器是一个基于J2EE的开放源代码的应用服务器。 JBoss代码遵循LGPL许可，可以在任何商业应用中免费使用，而不用支付费用。JBoss是一个管理EJB的容器和服务器，支持EJB 1.1、EJB 2.0和EJB3的规范。但JBoss核心服务不包括支持servlet/JSP的WEB容器，一般与Tomcat或Jetty绑定使用。
 
在J2EE应用服务器领域，JBoss是发展最为迅速的应用服务器。由于JBoss遵循商业友好的LGPL授权分发，并且由开源社区开发，这使得JBoss广为流行。
 
Jboss具有如下特点：
1、JBoss是免费的，开放源代码J2EE的实现，通过LGPL许可证进行发布。但同时	也有闭源的，开源和闭源流入流出的不是同一途径。
2、JBoss需要的内存和硬盘空间比较小。
3、安装便捷：解压后，只需配置一些环境变量即可。
4、JBoss支持"热部署"，部署BEAN时，只拷贝BEAN的JAR文件到部署路径下即	可自动加载；如果有改动，也会自动更新。
5、JBoss与Web服务器在同一个Java虚拟机中运行，Servlet调用EJB不经过网络，	从而大大提高运行效率，提升安全性能。
6、用户可以直接实施J2EE-EAR，而不是以前分别实施EJB-JAR和Web-WAR，非常	方便。
7、Jboss支持集群。
 
JBoss应用服务器还具有许多优秀的特质。
其一，具有革命性的JMX微内核服务作为其总线结构；
其二，本身就是面向服务架构（Service-Oriented Architecture，SOA）；
其三，具有统一的类装载器，从而能够实现应用的热部署和热卸载能力。
因此，高度模块化的和松耦合。JBoss应用服务器是健壮的、高质量的，而且还具有良	好的性能。
 
 
Jboss服务器安装
在深度服务器操作系统jboss服务器的安装方式有两种：
Tasksel安装方式
1. 配置好软件源，配置软件源请参考本手册的2.3节。
2. 在命令行执行tasksel命令，在打开的tasksel软件选择界面，选中“jboss	java server”，光标移动到“ok/确定”按钮，敲击回车键，系统就开始安装。
 
命令行安装方式
1. 配置好软件源，配置软件源请参考本手册的2.3节。
2. 在命令行执行命令apt-get install jbossas5或aptitude 	install jbossas5，系统就开始安装。
 
Jboss服务器简单配置
前提条件
1. Jboss相关软件包（如jbossas5）已经被安装在测试机1
2. Jdk相关软件包（如openjdk-8-jdk）已经被安装
3. 测试机1（jboss服务器10.1.11.227）与测试机2能够进行通信。
简单配置
1. 在测试机1的tty1以root用户身份登录系统，执行命令
vim /etc/default/jbossas5，编辑该文件，把RUN=“yes”
前的“#”号去掉，保存退出。
2. 在测试机1命令行终端执行命令
vim  	/usr/share/jbossas5/server/default/deploy/jbossweb.	sar/server.xml
修改配置文件，修改JBOSS服务器使外网能访问，修改内容如下
 <!-- A HTTP/1.1 Connector on port 8080 -->
      <Connector protocol="HTTP/1.1" port="9990" 	address="0.0.0.0"
       onnectionTimeout="20000" redirectPort="8443" /
 
 
Jboss服务器基本功能测试
1. 执行命令/etc/init.d/jbossas5 restart，重启服务。
2. 在测试机1的tty1以管理员身份登录系统，执行命令
     /usr/share/jbossas5/bin/run.sh 
注：有了步骤1后，此步可省略。
3. 在测试机1打开浏览器，在地址栏输入http://127.0.0.1:8080
敲击回车键。就可打开jboss的实例管理界面。
4. 在测试机2打开浏览器，在地址栏输入http://10.1.11.227:9990
敲击回车键。也可打开jboss的实例管理界面。
5. 在打开jboss实例管理页面，点击Administration Console超链接。即可	打开jboss管理登录窗口。
6. 在jboss登录窗口，username处输入admin，password处输入	admin，	点击login按钮。即可打开jboss管理控制台页面。
