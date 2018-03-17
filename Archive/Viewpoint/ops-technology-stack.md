# 运维技术栈


## 

## ELK 技术栈

Elastic公司的ELK技术栈, 主要是面向日志处理系统, 实时的日志流分析而言, Logstash提供日志收集, ElasticSearch提供日志存储和检索,Kibana提供数据的可视化展现

## TICK 技术栈

主页: <https://www.influxdata.com/time-series-platform/>

InfluxData公司提供一个基于 InfluxDB(面向时间序列的数据)的高性能解决方案. 简称 TICK 技术栈, 具体的产品包括:

* T - Telegraf   是一个收集指标和数据的client,然后写入 InfluxDB. 相当于ELK栈中的 logstash 功能.
* I - InfluxDB   是一个开源的GO语言为基础的数据库, 用来处理时间序列数据,提供了较高的可用性.
* C - Chronograf 是一个web程序, 用来展现InfluxDB的数据层. 相当于 ELK中的 Kibana.
* K - Kapacitor  是一个处理时间序列数据的处理引擎. 可以设置不同的规则进行监控和报警. 

## 其他

Prometheus 是源于 Google Borgmon 的一个开源监控系统，用 Golang 开发。被很多人称为下一代监控系统。
    Prometheus 基本原理是通过 HTTP 协议周期性抓取被监控组件的状态，这样做的好处是任意组件只要提供 HTTP 接口就可以接入监控系统，不需要任何 SDK 或者其他的集成过程。这样做非常适合虚拟化环境比如 VM 或者 Docker 。Prometheus 是为数不多的适合 Docker、Mesos 、Kubernetes 环境的监控系统之一。输出被监控组件信息的 HTTP 接口被叫做 exporter 。目前互联网公司常用的组件大部分都有 exporter 可以直接使用，比如 Varnish、Haproxy、Nginx、MySQL、Linux 系统信息 (包括磁盘、内存、CPU、网络等等)。

Grafana 是一个开源的图表可视化系统，简单说图表配置比较方便、生成的图表比较漂亮。
