# TICK 运维套间

介绍 TICK是来自时间序列数据库InfluxDB的开发人员的产品的集合 。它由以下组件组成：

* Telegraf从各种来源收集时间序列数据。
* InfluxDB存储时间序列数据。
* Chronograf可视化和图形化时间序列数据。
* Kapacitor提供警报并检测时间序列数据中的异常。

您可以单独使用这些组件，但如果将它们一起使用，您将拥有一个可扩展的集成开源系统来处理时间序列数据。 在本教程中，您将设置并使用此平台作为开源监控系统。您将生成一些CPU使用率，并在使用率过高时收到电子邮件警报。

先决条件,开始之前，您需要具备以下条件：

* 一个CentOS 7服务器按照CentOS 7初始服务器设置指南设置 ，包括sudo非root用户和防火墙。
* 如果您希望按照第7步中所述保护Chronograf用户界面，您需要一个GitHub组织的GitHub帐户。 按照本教程创建一个GitHub组织。

## 第1步 添加TICK存储库

默认情况下，TICK组件不能通过程序包管理器使用。所有TICK组件都使用相同的存储库，因此我们将设置存储库配置文件以使安装无缝。 创建此新文件：

创建配置文件, /etc/yum.repos.d/influxdata.repo 写入如下内容
```
[influxdb]
name = InfluxData Repository - RHEL 7 Server
baseurl = https://repos.influxdata.com/rhel/7Server/amd64/stable/ 
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
```

保存文件并退出编辑器。现在我们可以安装和配置InfluxDB

## 第2步 - 安装InfluxDB并配置身份验证

InfluxDB是一个开源数据库，优化了快速，高可用性存储和检索时间序列数据。 InfluxDB非常适合运行监控，应用程序度量和实时分析。 运行以下命令安装InfluxDB：

sudo yum install influxdb

在安装过程中，系统将要求您导入GPG密钥。确认您要导入此密钥，以便安装可以继续。 安装完成后，启动InfluxDB服务：

sudo systemctl start influxdb 然后确保服务正常运行：
systemctl status influxdb    您将看到以下状态，验证服务正在运行：

InfluxDB正在运行，但您需要启用用户身份验证以限制对数据库的访问。让我们创建至少一个admin用户。 启动InfluxDB控制台：

influx

执行以下命令创建新的管理用户。我们将使用密码db_admin创建一个admin用户，但您可以使用任何您想要的。

CREATE USER "admin" WITH PASSWORD 'db_admin' WITH ALL PRIVILEGES

验证是否已创建用户：

show users

您将看到以下输出，验证您的用户是否已创建：

    user  admin
    ----  -----
    sammy true

现在用户存在，退出InfluxDB控制台：

exit

现在在编辑器中打开文件/etc/influxdb/influxdb.conf 。这是InfluxDB的配置文件。

sudo vi /etc/influxdb/influxdb.conf

找到[http]部分，取消注释auth-enabled选项，并将其值设置为true ：
/etc/influxdb/influxdb.conf

...
    [http]
      # Determines whether HTTP endpoint is enabled.
      # enabled = true

      # The bind address used by the HTTP service.
      # bind-address = ":8086"

      # Determines whether HTTP authentication is enabled.
      auth-enabled = true
...

然后保存文件，退出编辑器，并重新启动InfluxDB服务：

sudo systemctl restart influxdb

InfluxDB现在已配置，所以让我们安装Telegraf，收集指标的代理。

## 第3步 - 安装和配置Telegraf

Telegraf是一个开源代理，可以收集运行系统或其他服务的指标和数据。 Telegraf然后将数据写入InfluxDB或其他输出。 运行以下命令安装Telegraf：

sudo yum install telegraf

Telegraf使用插件来输入和输出数据。默认输出插件用于InfluxDB。由于我们已经为IndexDB启用了用户身份验证，我们必须修改Telegraf的配置文件以指定我们配置的用户名和密码。在编辑器中打开Telegraf配置文件：

sudo vi /etc/telegraf/telegraf.conf

找到[outputs.influxdb]部分并提供用户名和密码：
/etc/telegraf/telegraf.conf

    [[outputs.influxdb]]
      ## The full HTTP or UDP endpoint URL for your InfluxDB instance.
      ## Multiple urls can be specified as part of the same cluster,
      ## this means that only ONE of the urls will be written to each interval.
      # urls = ["udp://localhost:8089"] # UDP endpoint example
      urls = ["http://localhost:8086"] # required
      ## The target database for metrics (telegraf will create it if not exists).
      database = "telegraf" # required

      ...

      ## Write timeout (for the InfluxDB client), formatted as a string.
      ## If not provided, will default to 5s. 0s means no timeout (not recommended).
      timeout = "5s"
      username = "admin"
      password = "db_admin"
      ## Set the user agent for HTTP POSTs (can be useful for log differentiation)
      # user_agent = "telegraf"
      ## Set UDP payload size, defaults to InfluxDB UDP Client default (512 bytes)
      # udp_payload = 512

保存文件，退出编辑器，然后启动Telegraf：

sudo systemctl start telegraf

然后检查服务是否正常运行：

systemctl status telegraf

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

## 第4步 - 安装Kapacitor

Kapacitor是一个数据处理引擎。它允许您插入自己的自定义逻辑，以使用动态阈值处理警报，匹配模式的度量或识别统计异常。我们将使用Kapacitor从InfluxDB读取数据，生成警报，并将这些警报发送到指定的电子邮件地址。 运行以下命令安装Kapacitor：

sudo yum install kapacitor

在编辑器中打开Kapacitor配置文件：

sudo vi /etc/kapacitor/kapacitor.conf


找到[[influxdb]]部分，并提供用于连接到InfluxDB数据库的用户名和密码：
/etc/kapacitor/kapacitor.conf

# Multiple InfluxDB configurations can be defined.
# Exactly one must be marked as the default.
# Each one will be given a name and can be referenced in batch queries and InfluxDBOut nodes.
[[influxdb]]
  # Connect to an InfluxDB cluster
  # Kapacitor can subscribe, query and write to this cluster.
  # Using InfluxDB is not required and can be disabled.
  enabled = true
  default = true
  name = "localhost"
  urls = ["http://localhost:8086"]
  username = "admin"
  password = "db_admin"
...

保存文件，退出编辑器，启动Kapacitor：

sudo systemctl daemon-reload
sudo systemctl start kapacitor

现在让我们验证Kapacitor是否正在运行。使用以下命令检查Kapacitor的任务列表：

kapacitor list tasks

如果Kapacitor启动并运行，您将看到一个空的任务列表，如下所示：

    ID                            Type      Status    Executing Databases and Retention Policies

安装和配置Kapacitor后，我们安装TICK的用户界面组件，以便我们可以看到一些结果并配置一些警报。
第5步 - 安装和配置Chronograf
Chronograf是一个图形和可视化应用程序，它提供了可视化监控数据和创建警报和自动化规则的工具。它包括对模板的支持，并且具有用于公共数据集的智能预配置仪表板库。我们将配置它连接到我们已经安装的其他组件。 下载并安装最新的软件包：

wget https://dl.influxdata.com/chronograf/releases/chronograf-1.2.0~beta3.x86_64.rpm
sudo yum localinstall chronograf-1.2.0~beta3.x86_64.rpm

然后启动Chronograf服务：

sudo systemctl start chronograf

注意 ：如果使用FirewallD，请将其配置为允许连接到端口8888 ：

sudo firewall-cmd --zone=public --permanent --add-port=8888/tcp
sudo firewall-cmd --reload

按照如何在CentOS 7上使用FirewallD设置防火墙的教程了解有关防火墙规则的更多信息。 现在，您可以通过在Web浏览器中访问http:// your_server_ip :8888访问Chronograf界面。 您将看到一个欢迎页面，如下图所示： Chronograf欢迎屏幕，其中包含连接到数据源的字段 输入InfluxDB数据库的用户名和密码，然后单击“ 连接新源”以继续。 连接后，您将看到主机列表。单击服务器的主机名以打开一个仪表板，其中包含有关主机的一系列系统级图表，如下图所示： 您的服务器的仪表板 现在让我们将Chronograf连接到Kapacitor以设置警报。将鼠标悬停在左侧导航菜单中的最后一个项目上，然后单击Kapacitor打开配置页。 配置Kapacitor 使用默认连接详细信息;我们没有为Kapacitor配置用户名和密码。单击连接Kapacitor 。 一旦Kapacitor成功连接，您将在表单下方看到“ 配置警报端点”部分。 Kapacitor支持多个警报终点：

    HipChat
    OpsGenie
    PagerDuty
    Sensu
    松弛
    SMTP
    谈论
    电报
    维多利亚

最简单的通信方法是SMTP ，默认情况下选择。 在发件人电子邮件字段中填写要发送提醒的地址，然后点击保存 。您可以将其余详细信息保留为默认值。 配置就绪后，让我们创建一些警报。

## 第6步 - 配置警报

让我们设置一个简单的警报，寻找高CPU使用率。 将鼠标悬停在左侧导航菜单上，找到ALERTING部分，然后点击Kapacitor Rules 。 然后单击创建新规则 。 在第一部分中，单击telegraf.autogen选择时间序列。 然后从显示的列表中选择系统 。 然后选择load1 。您将在下面的部分中立即看到相应的图表。 在图表上方，找到Load1大于的值为“ 发送警报”的字段，并为该值输入1.0 。 然后将以下文本粘贴到“ 警报消息”字段中以配置警报消息的文本：

{{ .ID }} is {{ .Level }} value: {{ index .Fields "value" }}

您可以将鼠标悬停在“ 模板”部分中的条目上，以获取每个字段的说明。 然后从发送此警报到下拉列表中选择Smtp选项，并在相关字段中输入您的电子邮件地址。 默认情况下，您将以JSON格式接收邮件，如下所示：
示例消息

{
    "Name":"system",
    "TaskName":"chronograf-v1-50c67090-d74d-42ba-a47e-45ba7268619f",
    "Group":"nil",
    "Tags":{
        "host":"centos-tick"
    },
    "ID":"TEST:nil",
    "Fields":{
        "value":1.25
    },
    "Level":"CRITICAL",
    "Time":"2017-03-08T12:09:30Z",
    "Message":"TEST:nil is CRITICAL value: 1.25"
}

您可以为邮件警报设置更多可供人读取的邮件。为此，请在将电子邮件正文文本放在此处占位符的文本框中输入消息。 您可以通过单击页面左上角的名称并输入新名称来重命名此规则。 最后，单击右上角的Save Rule以完成配置此规则。 要测试此新创建的警报，请使用dd命令从/dev/zero读取数据并将其发送到/dev/null ，以创建CPU尖峰：

dd if=/dev/zero of=/dev/null

让命令运行几分钟，这应该足以创建一个尖峰。您可以随时通过按CTRL+C停止命令。 过一会儿，您将收到一封电子邮件。此外，您还可以通过单击Chronograf用户界面左侧导航菜单中的警报历史记录来查看所有警报。 注意 ：确认您可以接收快讯后，请务必停止使用CTRL+C启动的dd命令。 我们有警报运行，但任何人都可以登录Chronograf。让我们限制访问。
第7步 - 使用OAuth保护Chronograf
默认情况下，任何知道运行Chronograf应用程序的服务器地址的人都可以查看任何数据。它可以接受测试环境，但不是生产。 Chronograf支持Google，Heroku和GitHub的OAuth身份验证。我们将通过GitHub帐户配置登录，因此您需要一个登录才能继续。 首先，用GitHub注册一个新的应用程序。登录您的GitHub帐户，然后导航到https://github.com/settings/applications/new 。 然后填写以下详细信息的表单：

    使用Chronograf填充应用程序名称或合适的描述性名称。
    对于首页网址 ，请使用http:// your_server_ip :8888 。
    使用http:// your_server_ip :8888/oauth/github/callback填写授权回调网址 。
    单击注册应用程序以保存设置。
    复制下一个屏幕上提供的客户端ID和客户端密钥值。

接下来，编辑Chronograf的systemd脚本以启用身份验证。打开文件/usr/lib/systemd/system/chronograf.service ：

sudo vi /usr/lib/systemd/system/chronograf.service

然后找到[Service]部分，并编辑以ExecStart=开头的行：
/usr/lib/systemd/system/chronograf.service

[Service]
User=chronograf
Group=chronograf
ExecStart=/usr/bin/chronograf --host 0.0.0.0 --port 8888 -b /var/lib/chronograf/chronograf-v1.db -c /usr/share/chronograf/canned -t 'secret_token' -i 'your_github_client_id' -s 'your_github_client_secret' -o 'your_github_organization'
KillMode=control-group
Restart=on-failure

所有OAuth提供商都需要secret_token。将其设置为随机字符串。使用您的Github客户端ID，Github客户端密钥和Github组织的其他值。 警告 ：如果从命令中省略Github组织选项，任何Github用户都将能够登录到您的Chronograf实例。 创建Github组织并将适当的用户添加到组织以限制访问。 保存文件，退出编辑器，然后重新启动Chronograf服务：

sudo systemctl daemon-reload
sudo systemctl restart chronograf

打开http:// your_server_ip :8888以访问Chronograf界面。 这次你将看到一个用Github登录按钮。单击按钮登录，系统会要求您允许应用程序访问您的Github帐户。一旦您允许访问，您就会登录。 
