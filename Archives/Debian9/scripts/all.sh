#!/bin/bash
> book.md

for MD in "	\
	src/system/install.md src/system/readme.md  	\
	src/system/locale_and_timezone.md		\
	src/system/date_and_time.md			\
    	src/system/users_and_group.md			\
    	src/system/networking.md			\
    	src/system/nettools.md				\
	src/system/nettools/ping.md			\
	src/system/nettools/traceroute.md		\
	src/system/nettools/netstat.md			\
	src/system/nettools/route.md			\
	src/system/nettools/ss.md			\
	src/system/nettools/ip.md			\
	src/system/nettools/host.md			\
	src/system/nettools/nslookup.md			\
	src/system/nettools/nc.md			
	"
do
	cat $MD >> book.md
done
#
#    * [软件仓库管理](system/software_managing.md)
#    * [服务与守护进程](system/service-and-daemon.md)
#* [服务器软件](software/software.md)
#    * [下载工具](software/download-tools.md)
#    * [远程连接](software/sshd.md)
#    * [邮件服务](software/mail.md)
#    * [域名服务](software/bind.md)
#    * [DHCP服务](software/dhcpd.md)
#    * [http服务](software/httpd.md)
#    * [tomcat中间件](software/tomcat.md)
#    * [jboss中间件](software/jboss.md)
#    * [PHP服务器](software/php5.md)
#    * [mysql数据库](software/mysql.md)
#    * [postgresql数据库](software/postgresql.md)
#    * [redis数据库](software/redis.md)
#    * [mongodb数据库](software/mongodb.md)
#* [服务器安全]( security/security.md)
#    * [iptable的基础使用](security/iptable.md)
#    * [selinux的基础使用](security/selinux.md)
#    * [PAM参考配置](security/pam.md)
#    * [弱口令检查工具john](security/john.md)
#    * [端口扫描工具nmap](security/nmap.md)
#    * [安全审计工具audit](security/audit.md)
#    * [文件完整性检查afick](security/afick.md)
#* [容器与虚拟化](vz/container_and_virtualzation.md)
#   * kvm
#     * libvirt
#     * [vagrant](vz/vagrant-libvirtd.md)
#   * docker
#     * network
#     * flannel
#     * weave
#     * pipework
#     * tinc
#     * socketplane
#   * [编排调度](vz/docker_orchestration.md) 
#     * fleet
#     * marathon
#     * swarm
#     * mesos
#     * kubernetes
#     * compose
#   * service_discovery
#     * etcd
#     * consul
#     * zookeeper
#   * SDN 
#     * openvswitch
#     *
#* [集群与云服务]()
#  * openstack
#  * hadoop   
#* [服务器运维](ops/ops.md)
#  * 代码审查 
#    * [Review Board](ops/review_board.md)
#  * 配置管理
#    * Ansible
#  * [监控报警](monitor.md)
#    * nagios
#    * nagios-plugins
#    * nagios-nrpe
#    * nagios-ncpa
#  * [icinga2]()
#    * [icinga2-web2]()
#    * [icinga2-dashing](ops/icing2-dashing.md)
#  * 性能监控
#    * collectd
#    * collect-web
#    * InfluxDB
#    * Grafana
#    * cacti   
#    * RRDTools
#  * 日志分析                 
#    * loganalyzer
#  * 运维方案
#    * [性能监控:Grafana+collectd+InfluxDB](ops/Grafana_collectd_InfluxDB.md)
#  * 系统维护工具集
#    * [htop](ops/htop.md)
#    * [iostat](ops/iostat.md)
#    * [iftop](ops/iftop.md)
#    * [procps](ops/procps.md)
#    * [nload](ops/nload.md)
#    * [sar](ops/sar.md)
#    * [mpstat](ops/mpstat.md)
#    * [lsof](ops/lsof.md)
#    * [e2fsprogs](ops/e2fsprogs.md)
#    * [strace](ops/strace.md)
#    * [ltrace](ops/ltrace.md)
#    * [dmidecode](ops/dmidecode.md)
#* [解决方案](src/solution.md)
#
