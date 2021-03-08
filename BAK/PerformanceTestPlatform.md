# 压力测试数据可视化Demo篇

## 源起

在和同事做了一轮紧急的客户LB压力测试后， 两个人折腾到大半夜，准备验证环境就就花费了很多时间，并且每进行一次压测，只要涉及调整参数，几十台RS服务器，几十台压测节点的配置就需要一台台的修改，真正操作压测时间反而占比不高, 效率实在太差了，因为之前玩过ansible之类的运维工具，也断断续续写了几年playbook, 都保存在自己的github上，做完应急的工作，开始琢磨怎么减少这类枯燥的机械劳动。

* 先翻出自己写的playbook, 配置主机等部分可以复用，只需要在补充点jemter,ab等工具的配置，就可以灵活初始化和操控几十台压测节点执行压测任务
* 解决了节点初始化的问题后，开始考虑解决另外一个问题，因为是使用按时付费的云主机,为了节约成本用后即还，花了点时间看了下云平台API，有现成的python SDK， 直接拿来用了，顺便生成ansible hosts 批量申请云主机的问题也解决了

之后的压测工作在准备环境阶段，申请40台云主机，初始化好到可以开始压测，10-25分钟；申请100台云主机，初始化好到可以开始压测，不超过30分钟. 继续观察发现，发现还有些其他的问题需要解决, 除了jemter有比较好的汇总输出结果外，其他有些例如gobench，ab，wrk等工具并没有结果汇总，另外所有工具压测过程也不能实时的观测数据，只能云平台各个组件监控处查看数据，这些数据是面向监控告警的，并不能集中展示压测相关的重要数据，在各种搜索之后，构思了一个简单的压测数据可视化方案,用Prometheus汇总压测数据，GrafanaUI展示结果

## 方案概述

1. JMeter 有一个jmeter-prometheus-plugin，可以在进行压测的时候结果按照prometheus metrics的格式吐出来
2. Prometheus server 抓取压测指标，配置 Grafana 读取 Prometheus源数据，做可视化展示

对于gobench，ab，wrk等其他工具，可以编写各自对应的metrics server 将压测指标吐给prometheus server ，这样以prometheus为中心，再扩展prometheus的DB插件，就可以构建一套扩展能力很强的压测平台，无论主机，数据库，存储都可以实现压测数据持久记录和可视化。

## 搭建过程

jmeter控制节点，Prometheus，Grafana 三个组件都部署在一台主机上，以系统 rhel/centos 为例，首先完成以下初始化工作：
```
yum install java-latest-openjdk.x86_64 docker-compose -y
yum-config-manager --add-repo http://mirrors.ustc.edu.cn/docker-ce/linux/centos/docker-ce.repo 
yum install docker-ce-cli-19.03 docker-ce-19.03 -y
systemctl restart docker
```

### 配置jmeter-prometheus-plugin


* 下载jmeter解压到任意目录
* GitHub上下载最新版jmeter-prometheus-plugin-0.6.0.jar文件，并将其放在 /lib/ext中
* wget https://github.com/johrstrom/jmeter-prometheus-plugin/blob/master/docs/examples/simple_prometheus_example.jmx
* ./apache-jmeter-5.3/bin/jmeter -n -t simple_prometheus_example.jmx

验证: curl http://127.0.0.1:9270/metrics  可以返回metrics指标说明配置正确

### 配置Prometheus 

1. 拉取Prometheus镜像
2. 生成Prometheus.yaml配置
3. 生成docker-compose yaml配置,并启动Prometheus

一键执行命令:
```
docker pull prom/prometheus
cat > prometheus.yml <<EOF
global:
  scrape_interval:     1s
  evaluation_interval: 1s

scrape_configs:
  - job_name: 'test_data'
    static_configs:
    - targets: ['127.0.0.1:9270']
EOF
cat > prometheus-up.yml <<EOF
version: '3.1'

services:
 prometheus:
   image: prom/prometheus
   container_name: prometheus
   hostname: prometheus
   network_mode: host
   restart: always
   volumes:
     - /data/prometheus.yml:/etc/prometheus/prometheus.yml
   command:
     - '--config.file=/etc/prometheus/prometheus.yml'
     - '--web.external-url=http://localhost/prometheus'
   ports:
     - "9090:9090"
   environment:
     - PROMETHEUS_ADMIN_USER=admin
     - PROMETHEUS_ADMIN_PASSWORD=admin
EOF
docker-compose -f prometheus-up.yml up -d
```

验证: 浏览器访问 http://host_ip:9090/prometheus/targets 状态为up说明监控指标获取正确

### 配置Grafana 

1. 拉取Grafana镜像
2. 生成docker-compose yaml配置,并启动Grafana 

一键执行命令:
```
docker pull grafana/grafana
cat > grafana-up.yml <<EOF
version: '3.1'

services:
 grafana:
   image: grafana/grafana:latest
   container_name: grafana
   ports:
     - "3000:3000"
   environment:
     - GF_SECURITY_ADMIN_USER=admin
     - GF_SECURITY_ADMIN_PASSWORD=admin
   user: "0"

EOF
docker-compose -f grafana-up.yml up -d
```

验证: 浏览器访问 http://host_ip:3000 使用用户名admin 密码admin能够正确登陆，说明grafana服务正常 

## 展示数据

1. 浏览器访问 http://host_ip:3000 使用用户名admin 密码admin登陆，第一次登陆需要修改默认密码，按照向导操作
2. 配置数据源 http://host_ip:3000/datasources -> Add data source 选择 Prometheus , HTTP URL 配置项写入 http://host_ip:9090/prometheus 点击Save & Test
3. 新建面板   http://host_ip:3000/dashboard/new -> Add new panel 编辑面板,选择一个指标保存，就可以看到可视化的压测数据项了

至此，Jmeter -> prometheus -> grafana 压测数据可视化Demo 搭建完毕

## 其他参考

1. Jmeter 
  - https://github.com/johrstrom/jmeter-prometheus-plugin
  - https://github.com/johrstrom/jmeter-prometheus-plugin/blob/master/docs/examples/simple_prometheus_example.jmx
2. Prometheus
  - https://github.com/prometheus/prometheus/blob/master/documentation/examples/prometheus.yml
  - https://github.com/prometheus/prometheus/blob/master/documentation/examples/remote_storage/remote_storage_adapter/README.md
  - https://prometheus.io/docs/prometheus/latest/configuration/configuration
3. Grafana
  - http://docs.grafana.org/installation/configuration/#provisioning
4. https://www.cnblogs.com/zhaojiedi1992/p/zhaojiedi_liunx_60_prometheus_config.html
5. https://www.cnblogs.com/guoxiangyue/p/11772717.html
