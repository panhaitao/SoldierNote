# grafana 基础入门

## 安装


* grafana-4.1.2版本 for rhel/centos/fedora
```  
rpm -ivh https://grafanarel.s3.amazonaws.com/builds/grafana-4.1.2-1486989747.x86_64.rpm
```

## 启动服务

```
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server.service
sudo /bin/systemctl start grafana-server.service
```

## 配置参考

服务器启动后，可以访问 http://server_ip:3000 来查看,默认用户名和密码是 admin admin


1 设置数据源: 菜单-> datasources   

2 导入dashboards 模板文件: 菜单-> dashboard -> import 

例如从这里下载一个:  https://grafana.com/dashboards/1443

