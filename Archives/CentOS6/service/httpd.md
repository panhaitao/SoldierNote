# Apache服务器

Apache HTTP Server（简称Apache）是Apache软件基金会的一个开放源代码的网页服务器软件，可以在大多数电脑操作系统中运行，由于其跨平台和安全性。被广泛使用，是最流行的Web服务器软件之一。它快速、可靠并且可通过简单的API扩充，将Perl／Python等解释器编译到服务器中。
 
## 实例Apache服务器的简单配置
 
本实例中没有提到添加防火墙配置，关闭防火墙作为前提条件,执行命令`service iptables stop`。

* 安装软件: `yum install httpd -y`
* 编辑配置文件`/etc/httpd/conf/httpd.conf`,根据需要修改参考配置：
```
DocumentRoot /var/www/html/
```
* 重启服务: `service httpd restart`
* 测试验证: 执行命令``curl 127.0.0.1`能正确返回页面，说明http服务器基本配置已经安装成功。
