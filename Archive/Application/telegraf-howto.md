# Telegraf 基础指南

Telegraf是一个开源代理，可以收集运行系统或其他服务的指标和数据。 Telegraf然后将数据写入InfluxDB或其他输出。 


## 安装 

运行以下命令安装Telegraf：

sudo yum install telegraf

Telegraf使用插件来输入和输出数据。默认输出插件用于InfluxDB。由于我们已经为IndexDB启用了用户身份验证，我们必须修改Telegraf的配置文件以指定我们配置的用户名和密码。在编辑器中打开Telegraf配置文件：



## 配置

编辑配置文件  /etc/telegraf/telegraf.conf 找到[outputs.influxdb]部分设置 urls， 数据库名， 用户名， 密码几个基础配置项 

```
[[outputs.influxdb]]
  urls = ["http://localhost:8086"] # required
  database = "telegraf" # required
  username = "admin"
  password = "db_admin"
```

保存文件, 后启动服务 `systemctl start telegraf`

然后检查服务是否正常运行：`systemctl status telegraf`



Telegraf现在正在收集数据并将其写入InfluxDB。让我们打开InfluxDB控制台，看看Telegraf在数据库中存储了哪些测量。连接您先前配置的用户名和密码：

influx -username 'admin' -password 'db_admin'

登录后，执行以下命令查看可用的数据库：

show databases

您将在输出中看到telegraf数据库：

name: databases
name
----
_internal
telegraf

注意 ：如果没有看到telegraf数据库，请检查您配置的Telegraf设置，以确保您指定了正确的用户名和密码。 让我们看看Telegraf在那个数据库中存储什么。执行以下命令切换到Telegraf数据库：

use telegraf

显示Telegraf通过执行此命令收集的各种测量：

show measurements

您将看到以下输出：

name: measurements
name
----
cpu
disk
diskio
kernel
mem
processes
swap
system

正如你可以看到的，Telegraf已经收集并存储了大量的信息在这个数据库。 Telegraf有超过60个输入插件。它可以收集来自许多流行服务和数据库的指标，包括：

Apache
Cassandra
Docker
Elasticsearch
Graylog
IPtables
MySQL
PostgreSQL
Redis
SNMP
和许多其他

通过在终端窗口中运行telegraf -usage plugin-name ，可以查看每个输入插件的使用说明。 退出InfluxDB控制台：

exit

现在我们知道Telegraf存储测量，让我们设置Kapacitor来处理数据。
