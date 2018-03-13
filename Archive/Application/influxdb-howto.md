# influxdb 基础指南 

InfluxDB是一个开源数据库，优化了快速，高可用性存储和检索时间序列数据。 InfluxDB非常适合运行监控，应用程序度量和实时分析。 运行以下命令安装InfluxDB：

## 启用influxdata仓库

创建配置文件, /etc/yum.repos.d/influxdata.repo 写入如下内容

```
[influxdb]
name = InfluxData Repository - RHEL 7 Server
baseurl = https://repos.influxdata.com/rhel/7Server/amd64/stable/ 
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
```

## 安装InfluxDB

```
yum update
yum install influxdb
```

在安装过程中，系统将要求您导入GPG密钥。确认您要导入此密钥，以便安装可以继续。 安装完成后，启动InfluxDB服务：

## 启动服务

终端执行命令 `systemctl start influxdb`  启动服务
检查服务状态 `systemctl status influxdb` 确认服务正在运行，然后继续


## 创建数据库


InfluxDB正在运行，但您需要启用用户身份验证以限制对数据库的访问。让我们创建至少一个admin用户。 执行命令 `influx` 进入InfluxDB控制台

执行以下命令创建新的管理用户(在这里以 用户名`admin` 密码`db_admin` 为例)

```
CREATE USER "admin" WITH PASSWORD 'db_admin' WITH ALL PRIVILEGES
```

验证是否已创建用户：

show users

您将看到以下输出，验证您的用户是否已创建：

user  admin
----  -----
sammy true

现在用户存在，输入`exit` 退出 InfluxDB 控制台：


## 配置身份验证

编辑文件/etc/influxdb/influxdb.conf


找到[http]部分，取消注释auth-enabled选项，并将其值设置为true

```
[http] 
  auth-enabled = true
```

然后保存文件，并重新启动InfluxDB服务：`systemctl restart influxdb ` InfluxDB现在已配置完成

