# Prometheus 部署指南

## 简介

kube Prometheus和Prometheus Operator 都是CoreOS 开发的为Kubernetes监控方案设计的开源项目，两者结合是目前比较完整的Prometheus监控解决方案，两者的区别和关系如下：

* prometheus-operator只包含一个operator，该operator管理和操作Prometheus集群
* kube Prometheus以Prometheus Operator和提供一系列manifests文件为基础，完成对Prometheus集群的部署模式，监控规则，告警规则等设置

相关项目地址：
* https://github.com/coreos/kube-prometheus
* https://github.com/coreos/prometheus-operator

# 部署 Prometheus Operator

前期准备

* 导入相关镜像 # docker load -i prometheus-operator.tar


1. 为方便管理，创建一个单独的 Namespace monitoring，Prometheus Operator 相关的组件都会部署到这个 Namespace。

# kubectl create namespace monitoring

安装 Prometheus Operator
1. 使用 Helm 安装 Prometheus Operator

Prometheus Operator 所有的组件都打包成 Helm Chart，安装部署非常方便。

# helm install --name prometheus-operator --namespace=monitoring stable/prometheus-operator



helm install coreos/kube-prometheus --name kube-prometheus --namespace monitoring      \
--set global.rbacEnable=true                                                           \
--set alertmanager.ingress.enabled=true                                                \
--set alertmanager.ingress.hosts[0]=alertmanager.bnh.com                               \
--set alertmanager.storageSpec.volumeClaimTemplate.spec.storageClassName=rook-block    \
--set alertmanager.storageSpec.volumeClaimTemplate.spec.accessModes[0]=ReadWriteOnce   \
--set alertmanager.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=2Gi \
--set grafana.adminPassword=password                                                   \
--set grafana.ingress.enabled=true                                                     \
--set grafana.ingress.hosts[0]=grafana.bnh.com                                         \
--set prometheus.ingress.enabled=true                                                  \
--set prometheus.ingress.hosts[0]=prometheus.bnh.com                                   \
--set prometheus.storageSpec.volumeClaimTemplate.spec.storageClassName=rook-block      \
--set prometheus.storageSpec.volumeClaimTemplate.spec.accessModes[0]=ReadWriteOnce     \  
--set prometheus.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=2Gi   

2. 查看创建的资源

# kubectl get all -n monitoring 

3.查看安装后的 release

# helm list 

prometheus-operator 的 charts 会自动安装 Prometheus、Alertmanager 和 Grafana。
修改访问模式
1. 查看访问类型

# kubectl get svc -n monitoring 

默认的访问类型为 ClusterIP 无法外部访问，只能集群内访问。
2. 修改 alertmanager、prometheus、grafana的访问类型

grafana：

# kubectl edit svc prometheus-operator-grafana -n monitoring

……
spec:
  clusterIP: 10.103.30.59
  ports:
  - name: service
    port: 80
    protocol: TCP
    targetPort: 3000
  selector:
    app: grafana
    release: prometheus-operator
  sessionAffinity: None
  type: NodePort        #修改此行

alertmanager：

# kubectl edit svc prometheus-operator-alertmanager -n monitoring

……
spec:
  clusterIP: 10.105.62.219
  ports:
  - name: web
    port: 9093
    protocol: TCP
    targetPort: 9093
  selector:
    alertmanager: prometheus-operator-alertmanager
    app: alertmanager
  sessionAffinity: None
  type: NodePort       #修改此行
status:
  loadBalancer: {}

prometheus：

# kubectl edit svc prometheus-operator-prometheus -n monitoring

……
spec:
  clusterIP: 10.104.229.158
  ports:
  - name: web
    port: 9090
    protocol: TCP
    targetPort: web
  selector:
    app: prometheus
    prometheus: prometheus-operator-prometheus
  sessionAffinity: None
  type: NodePort      #修改此行
status:
  loadBalancer: {}

3. 查看修改后的访问类型

# kubectl get svc -n monitoring 
NAME                                           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
alertmanager-operated                          ClusterIP   None             <none>        9093/TCP,6783/TCP   23m
prometheus-operated                            ClusterIP   None             <none>        9090/TCP            23m
prometheus-operator-alertmanager               NodePort    10.105.62.219    <none>        9093:32645/TCP      23m
prometheus-operator-grafana                    NodePort    10.103.30.59     <none>        80:30043/TCP        23m
prometheus-operator-kube-state-metrics         ClusterIP   10.105.189.63    <none>        8080/TCP            23m
prometheus-operator-operator                   ClusterIP   10.105.212.90    <none>        8080/TCP            23m
prometheus-operator-prometheus                 NodePort    10.104.229.158   <none>        9090:32275/TCP      23m
prometheus-operator-prometheus-node-exporter   ClusterIP   10.103.226.249   <none>        9100/TCP            23m

修改 kubelet 打开只读端口

prometheus 需要访问 kubelet 的 10255 端口获取 metrics。但是默认情况下 10255 端口是不开放的，会导致 prometheus 上有 unhealthy，如下图：
unhealthy
打开只读端口需要编辑所有节点的 /var/lib/kubelet/config.yaml 文件，加入以下内容

# /var/lib/kubelet/config.yaml

……
oomScoreAdj: -999
podPidsLimit: -1
port: 10250
readOnlyPort: 10255          #增加此行
registryBurst: 10
registryPullQPS: 5
resolvConf: /etc/resolv.conf

重启 kubelet 服务


查看 prometheus target
healthy
访问 dashboard

    Pormetheus 的 Web UI
    访问地址为：http://nodeip:32275/target，如下图：
    prometheus

    Alertmanager 的 Web UI
    访问地址为：http://nodeip:32645/，如下图：
    alertmanager

    Grafana Dashboard
    访问地址为：http://nodeip:30043/，默认的用户名/密码为：admin/prom-operator，登陆后如下图：
    grafana
    grafana-1
    grafana-2

问题记录
1. prometheus-operator-coredns 无数据

问题详情见：Don’t scrape metrics from coreDNS
解决方法如下：修改 prometheus-operator-coredns 服务的 selector 为 kube-dns

# kubectl edit svc prometheus-operator-coredns  -n kube-system

……
spec:
  clusterIP: None
  ports:
  - name: http-metrics
    port: 9153
    protocol: TCP
    targetPort: 9153
  selector:
    k8s-app: kube-dns         #修改此行
  sessionAffinity: None
  type: ClusterIP

2. prometheus-operator-kube-etcd 无数据

prometheus 通过 4001 端口访问 etcd metrics，但是 etcd 默认监听 2379。
解决方法如下：

# vim /etc/kubernetes/manifests/etcd.yaml

apiVersion: v1
kind: Pod
metadata:
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ""
  creationTimestamp: null
  labels:
    k8s-app: etcd-server                                                       #增加此行
    component: etcd
    tier: control-plane
  name: etcd
  namespace: kube-system
spec:
  containers:
  - command:
    - etcd
    - --advertise-client-urls=https://172.20.6.116:2379
    - --cert-file=/etc/kubernetes/pki/etcd/server.crt
    - --client-cert-auth=true
    - --data-dir=/var/lib/etcd
    - --initial-advertise-peer-urls=https://172.20.6.116:2380
    - --initial-cluster=k8s-master=https://172.20.6.116:2380
    - --key-file=/etc/kubernetes/pki/etcd/server.key
    - --listen-client-urls=https://127.0.0.1:2379,https://172.20.6.116:2379,http://172.20.6.116:4001         #增加 4001 端口的 http 监听
    - --listen-peer-urls=https://172.20.6.116:2380
    - --name=k8s-master
    - --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
    - --peer-client-cert-auth=true
    - --peer-key-file=/etc/kubernetes/pki/etcd/peer.key
    - --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
    - --snapshot-count=10000
    - --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt

重启 kubelet 服务即可


3. prometheus-operator-kube-controller-manager 和 prometheus-operator-kube-scheduler 无数据

由于 kube-controller-manager 和 kube-scheduler 默认监听 127.0.0.1 ，prometheus 无法通过本机地址获取数据，需要修改kube-controller-manager 和 kube-scheduler 监听地址。
解决办法如下：
kube-controller-manager:

# vim /etc/kubernetes/manifests/kube-controller-manager.yaml

apiVersion: v1
kind: Pod
metadata:
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ""
  creationTimestamp: null
  labels:
    k8s-app: kube-controller-manager               #增加此行
    component: kube-controller-manager
    tier: control-plane
  name: kube-controller-manager
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-controller-manager
    - --address=0.0.0.0                                   #修改监听地址
    - --allocate-node-cidrs=true

kube-scheduler:

# vim /etc/kubernetes/manifests/kube-scheduler.yaml

apiVersion: v1
kind: Pod
metadata:
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ""
  creationTimestamp: null
  labels:
    k8s-app: kube-scheduler                         #增加此行
    component: kube-scheduler
    tier: control-plane
  name: kube-scheduler
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-scheduler
    - --address=0

重启 kubelet 服务即可



# 参考
* https://www.devtech101.com/2018/10/23/deploying-helm-tiller-prometheus-alertmanager-grafana-elasticsearch-on-your-kubernetes-cluster-part-2/
* https://github.com/helm/charts/blob/master/stable/prometheus-operator/values.yaml
* https://www.jianshu.com/p/2fbbe767870d
