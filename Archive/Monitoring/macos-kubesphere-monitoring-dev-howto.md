# 基于kubeSphere的单机调试环境 

## 前提
我在客户现场日常工作就是维护管理容器PaaS平台，也就离不开如何配置监控与可视化，kubeSphere的可定制化部署满足建立一个轻巧的单机调试环境，我的上一篇文档提到MacOS下如何[安装kubeSphere](https://kubesphere.com.cn/forum/d/495-macos-ks-installer-kubesphere),接下来我要在此基础上完成简单的配置工作，完成如下自定义需求：

1. 使用nodeport方式暴漏grafana服务
2. 使用nodeport方式暴漏prometheus-k8s服务

## 编辑configmap开启相关功能

从终端方式操作:`kubectl edit cm ks-installer -n kubesphere-system`
从平台管理操作：工作台 -> 项目 -> kubesphere-system -> 配置中心 -> 配置-> ks-installer -> 更多操作 -> 编辑配置文件,修改如下配置，保存退出！

```
metrics-server:
      enabled: True
......
  grafana:
        enabled: True     
```

有些操作，使用平台管理页面操作并没有终端操作高效率，不过令人欣慰的是kubesphere提供了kubectl的入口，在主界面的右下角提供工具箱。

## 重新配置 grafana service

执行命令：
```
kubectl get svc grafana -n kubesphere-monitoring-system  -o yaml > grafana-svc.yaml
kubectl delete svc grafana -n kubesphere-monitoring-system
```

修改grafana-svc.yaml为如下参考配置

```
apiVersion: v1
kind: Service
metadata:
  labels:
    app: grafana
  name: grafana
  namespace: kubesphere-monitoring-system
spec:
  ports:
  - name: http
    port: 3000
    nodePort: 30000
    protocol: TCP
    targetPort: http
  selector:
    app: grafana
  sessionAffinity: None
  type: NodePort
```
应用配置
```
kubectl apply -f grafana-svc.yaml
```
打开浏览器访问 http://127.0.0.1:30000 出现如下页面，使用nodeport方式暴漏grafana服务配置完成
[upl-image-preview url=https://kubesphere.com.cn/forum/assets/files/2019-12-22/1576987311-193309-2019-12-22115756.png]

## 重新配置 prometheus-k8s service

执行命令：
```
kubectl get svc -n kubesphere-monitoring-system prometheus-k8s -o yaml  > prometheus-k8s-svc.yaml
kubectl delete svc -n kubesphere-monitoring-system prometheus-k8s
```

修改prometheus-k8s-svc.yaml为如下参考配置

```
apiVersion: v1
kind: Service
metadata:
  labels:
    prometheus: k8s
  name: prometheus-k8s
  namespace: kubesphere-monitoring-system
spec:
  ports:
  - name: web
    port: 9090
    nodePort: 30090
    protocol: TCP
    targetPort: web
  selector:
    app: prometheus
    prometheus: k8s
  type: NodePort
```
应用配置
```
kubectl apply -f prometheus-k8s-svc.yaml
```

打开浏览器访问 http://127.0.0.1:30090 出现如下页面，使用nodeport方式暴漏prometheus-k8s服务配置完成
[upl-image-preview url=https://kubesphere.com.cn/forum/assets/files/2019-12-22/1576988975-70963-2019-12-22122911.png]

**至此一个可以用于创建自定义exporter和 调试grafana面板的单机调试环境建立完毕！**

## 使用PromQL统计资源

统计方式：

* cpu使用： sum ( rate (container_cpu_seconds_total){image!="",container_name="name_xx" }[5m] ) *  cpu核心数
* 内存使用：sum ( container_memory_usage_bytes{image!="",container_name="name_xx" } ) /1024^3
