# 容器云方案部署文档

### 部分Kubernetes操作实例概念参考

* namespaces

* Pods

Pod是Kubernetes的基本操作单元，把相关的一个或多个容器构成一个Pod，通常Pod里的容器运行相同的应用。Pod包含的容器运行在同一个Minion(Host)上，看作一个统一管理单元，共享相同的volumes和network namespace/IP和Port空间。

* Services

Services也是Kubernetes的基本操作单元，是真实应用服务的抽象，每一个服务后面都有很多对应的容器来支持，通过Proxy的port和服务selector决定服务请求传递给后端提供服务的容器，对外表现为一个单一访问接口，外部不需要了解后端如何运行，这给扩展或维护后端带来很大的好处。

* Replication Controllers

Replication Controller确保任何时候Kubernetes集群中有指定数量的pod副本(replicas)在运行， 如果少于指定数量的pod副本(replicas)，Replication Controller会启动新的Container，反之会杀死多余的以保证数量不变。Replication Controller使用预先定义的pod模板创建pods，一旦创建成功，pod 模板和创建的pods没有任何关联，可以修改pod 模板而不会对已创建pods有任何影响，也可以直接更新通过Replication Controller创建的pods。对于利用pod 模板创建的pods，Replication Controller根据label selector来关联，通过修改pods的label可以删除对应的pods。Replication Controller主要有如下用法：

1. Rescheduling     :如上所述，Replication Controller会确保Kubernetes集群中指定的pod副本(replicas)在运行， 即使在节点出错时。
2. Scaling          :通过修改Replication Controller的副本(replicas)数量来水平扩展或者缩小运行的pods。
3. Rolling updates  :Replication Controller的设计原则使得可以一个一个地替换pods来rolling updates服务。
4. Multiple release :tracks: 如果需要在系统中运行multiple release的服务，Replication Controller使用labels来区分multiple release tracks。

* Labels

Labels是用于区分Pod、Service、Replication Controller的key/value键值对，Pod、Service、 Replication Controller可以有多个label，但是每个label的key只能对应一个value。Labels是Service和Replication Controller运行的基础，为了将访问Service的请求转发给后端提供服务的多个容器，正是通过标识容器的labels来选择正确的容器。同样，Replication Controller也使用labels来管理通过pod 模板创建的一组容器，这样Replication Controller可以更加容易，方便地管理多个容器，无论有多少容器。


## 基本操作

1. 节点操作
 
* `kubectl get nodes`       查看节点状态 
* `kubectl describe nodes`  更详细的列出 node 的状态 

2. 命名空间 
 
* `kubectl get namespaces` 列出所有命名空间  
* `kubectl get pods -n kube-system -o wide`  以wide格式输出，列出运行在 kube-system 命名空间的 pods 

3. api server 检查

* 在master上执行 curl 127.0.0.1:8080/healthz 看返回是否ok
* 在任意机器上执行 curl -k https://<master-public-ip>:6443 会返回Unauthorized

4. 检查网络  

`kubectl get pods --all-namespaces |grep flannel`  

* check net dev 
  * ifconfig flannel.1
  * ifconfig cni0 
* cat /run/flannel/subnet.env

5. 检测slave 

* 查看kubelet日志 `journalctl -f -u kubelet`
* 服务发现的访问原理
```
request -> service_name -> <dns server> -> service-ip -> <iptables> -> pod-ip
```
 

kudectl get secrets
kudectl delelte secrets <name>
kudectl delelte namespace <name>




## 文档参考

