
以日志服务器IP为192.168.2.200为例，客户端配置如下:

编辑 /etc/rsyslog.conf 新增一行：

*.*                @192.16.8.200

完成配置后重启服务:

service rsyslog restart
