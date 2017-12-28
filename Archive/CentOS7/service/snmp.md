1.使用yum从仓库安装snmp服务

可以通过yum从系统所连接的仓库安装snmp相关软件包：
```
yum install -y net-snmp
yum install -y net-snmp-devel
yum install -y net-snmp-libs
yum install -y net-snmp-perl
yum install -y net-snmp-utils
yum install -y mrtg
```

2.使用rpm安装离线软件包

如果你已经在本地存储有对应的rpm包，则可以直接通过命令安装本地安装包：

    rpm -ivh net-snmp-utils-* net-snmp-perl-* net-snmp-* net-snmp-devel-* net-snmp-libs-* mrtg-libs-* mrtg-*
 
3.启动snmpd服务

可以使用service命令启动服务：

    service snmpd start

可以查看服务状态：

    service snmpd status

注：如果启动失败，建议手动执行snmpd命令进行调试。
4.配置

装好之后修改/etc/snmp/snmpd.conf对其进行配置

 
4.1.修改默认的community string

修改com2sec，community值public修改为指定用户，如：deepin（可以保持public来进行调试）

#com2sec notConfigUser  default       public

com2sec notConfigUser  default       deepin

 
4.2.修改mib相关配置

#view mib2 included .iso.org.dod.internet.mgmt.mib-2 fc

view mib2 included .iso.org.dod.internet.mgmt.mib-2 fc

 
4.3.把下面的语句

access notConfigGroup " " any noauth exact systemview none none

改成：

access notConfigGroup " " any noauth exact mib2 none none

 
4.4.重启snmpd服务

使用如下命令重启snmp服务，使配置生效：

service snmpd restart
5.安全配置的影响

确保系统的iptables防火墙对监控服务器开放了udp 161端口的访问权限。可使用iptables -L -n 查看当前iptables规则：

iptables -L -n |grep 161

ACCEPT  udp  --  0.0.0.0/0  0.0.0.0/0  udp dpt:161

最终请修改/etc/sysconfig/iptables文件来修改iptables规则
6.配置开机启动snmp服务

chkconfig --level 2345 snmpd on

chkconfig --list |grep snmpd

    snmpd           0:off   1:off   2:on    3:on    4:on    5:on    6:off
7.使用snmpwalk查看信息

查看CPU空闲率：snmpwalk -v 2c -c public localhost 1.3.6.1.4.1.2021.11.11.0
所有信息：snmpwalk -v 2c -c public localhost
系统内存：snmpwalk -v 2c -c public localhost .1.3.6.1.2.1.25.2.2
系统用户数：snmpwalk -v 2c -c public localhost hrSystemNumUsers
获取ip信息：snmpwalk -v 2c -c public localhost .1.3.6.1.2.1.4.20
查看系统信息：snmpwalk -v 2c -c public localhost system

注：测试的时候讲义关闭iptables防火墙和Selinux强制访问控制，先确认服务是否正常，确保不是安全配置阻止的服务。