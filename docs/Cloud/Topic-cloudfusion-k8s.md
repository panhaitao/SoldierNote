# 基于k8s的全栈云

1. 底座: kubernetes
  * VM  : kube virt
  * 容器：docker
2. SDN: kube-ovn
3. 网络代理: https://github.com/mosn/mosn
4. 监控： 
  * 基础监控: prometheus -> grafana -> alertmanager
  * 应用监控: skywarking
5. 日志： fluentd (sidecar) -> kafka -> es

## 中台应用

1. ES集群
2. Redis集群
3. kafka集群
4. DB集群
5. HDFS集群
6. SPARK集群。。。
7. Ceph集群
