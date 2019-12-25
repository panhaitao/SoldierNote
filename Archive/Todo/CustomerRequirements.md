## 容器平台PaaS需求

1. 集群管理
* 不能新增加master节点,现场解决办法：ansible playbook + kubeadmin 新增master节点
* 不支持批量新增计算节点，现场解决办法：ansible playbook+shell脚本
* 不支持
2. ES日志索引 单一topic
* 现场解决办法：无
3. 无最佳实践，无边界。客户无法提前做规划，包括容量规划。
* shell 脚本统计，人工巡检
4. 查询不方便，不友好。没有日志导出功能
5. 平台组件无监控
6. 统一所有pod时区，临时解决办法：进入pod ln -sv /usr/share/zoneinfo/Asia/Shanghai /etc/locatime -f [待处理]
7. blackbox exporter 监控
8. skywalking 全链路APM监控分析工具
  * https://github.com/apache/skywalking
  * https://github.com/apache/skywalking-kubernetes
  * https://github.com/apache/skywalking-rocketbot-ui
