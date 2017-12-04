# 概述

* 源码: https://github.com/Icinga/dashing-icinga2

# 前提

* 系统中已经安装好`icinga2`
* icinga2 开启 api 特性 `icinga2 feature enable api`

# 安装
```
apt-get update
apt-get -y install ruby bundler nodejs
gem install bundler
cd /usr/share
git clone https://github.com/Icinga/dashing-icinga2.git
cd dashing-icinga2
bundle
```

# 配置

* 参考`/etc/icinga2/conf.d/api-users.conf` 配置，


vim /etc/icinga2/conf.d/api-users.conf

object ApiUser "dashing" {
  password = "icinga2ondashingr0xx"
  permissions = [ "status/query", "objects/query/*" ]
}

* 修改 `/usr/share/dashing-icinga2/config/icinga2.json`

{
  "icinga2": {
    "api": {
      "host": "localhost",
      "port": 5665,
      "user": "dashing",
      "password": "icinga2ondashingr0xx"
    }
  }
}



# 

```
cd /usr/share/dashing-icinga2
./restart-dashing
```

 http://localhost:8005


Systemd服务

您可以从tools / systemd安装提供的Systemd服务文件。 它假定工作目录是 /usr/share/dashing-icinga2 ，并且Dashing gem安装到/usr/local/bin/dashing。根据自己的需要采用这些路径。

```
cp /usr/share/dashing-icinga2/tools/systemd/dashing-icinga2.service /usr/lib/systemd/system/
systemctl daemon-reload
systemctl start dashing-icinga2.service
systemctl status dashing-icinga2.service
```



