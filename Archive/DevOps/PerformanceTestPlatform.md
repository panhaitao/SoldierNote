# 压力测试可视化

## 概述

## 组件

1. Jmeter 
  - https://github.com/johrstrom/jmeter-prometheus-plugin
2. Prometheus
  - https://github.com/prometheus/prometheus/blob/master/documentation/examples/prometheus.yml
  - https://github.com/prometheus/prometheus/blob/master/documentation/examples/remote_storage/remote_storage_adapter/README.md
  - https://prometheus.io/docs/prometheus/latest/configuration/configuration
3. Grafana
  - http://docs.grafana.org/installation/configuration/#provisioning

## 工作流

JMeter > Prometheus > Grafana

## Jmeter插件配置

GitHub上下载最新版jmeter-prometheus-plugin-0.6.0.jar文件，并将其放在 \lib\ext中，重启Jmeter即可。

## 启动  

docker-compose -f docker-compose.yml up -d

## 其他参考

* https://www.cnblogs.com/zhaojiedi1992/p/zhaojiedi_liunx_60_prometheus_config.html
* https://www.cnblogs.com/guoxiangyue/p/11772717.html
