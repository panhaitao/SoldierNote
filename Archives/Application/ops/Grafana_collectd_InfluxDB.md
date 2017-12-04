# 实时监控系统(Grafana＋collectd＋InfluxDB)

需要 InfluxDB/collectd/Grafana 这三个工具，三个工具的关系：

    采集数据（collectd）-> 存储数据（InfluxDB) -> 显示数据（Grafana）。

* collectd C 语言写的一个系统性能采集工具；
* InfluxDB 是 Go 语言开发的一个开源分布式时序数据库，非常适合存储指标、事件、分析等数据；
* Grafana  是 Javascript 开发的前端工具，用于访问 InfluxDB，自定义报表、显示图表等。

## 

* debian sid
  * influxdb  1.1.1+dfsg1-4
  * collectd  5.7.1-1.1 
  * Grafana   4.4.2

## InfluxDB 安装 
	
`apt install influxdb -y`

* /etc/influxdb/influxdb.conf

```
[admin]
  enabled = true
  bind-address = ":8083"
  https-enabled = false
[http]
  enabled = true
  bind-address = ":8086"
[[collectd]]
  enabled = true 
  bind-address = ":25826"
  database = "collectd"
```

* netstat -tupln
* base option: http://blog.csdn.net/u010185262/article/details/53158786

启动后打开 web 管理界面 
* Web 管理界面端口是 8083
* HTTP API 监听端口是 8086

## collectd 安装

`apt install collectd -y`

* 
```
LoadPlugin network
<Plugin network>
	Server "10.1.11.195" "25826"
</Plugin>
```

## grafana 安装


https://github.com/grafana/grafana

```
wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_4.4.2_amd64.deb 
sudo dpkg -i grafana_4.4.2_amd64.deb 
```

`http://ip:3000` 默认用户密码 admin admin
 
* 添加数据 http://ip:3000/datasources/new

![add data source](images/granafa_add_data_source.png)
 
* 新建dashboard `http://10.1.11.195:3000/dashboard/new`



