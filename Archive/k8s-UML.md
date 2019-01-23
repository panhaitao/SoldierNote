##### kubernetes架构

> ```kubernetes```是有```Master```和```Node```两种节点组成，两种角色分别对应控制节点和计算节点。

* 控制节点由：```kube-apiserver```，```kube-scheduler```，```kube-scheduler```，```etcd```组成

* 计算节点由：```kubelet```和```kube-proxy``` ```Container runtime(docker)```组成

---



##### kubernetes核心组件概念

- ```etcd```：保存了整个集群的状态

- ```kube-apiserver```：提供了资源操作的唯一入口，并提供认证、授权、访问控制、API注册和发现等机制

- ```kube-controller-manager```：负责维护集群的状态，比如故障检测、自动扩展、滚动更新等

- ```kube-scheduler```：负责资源的调度，按照预定的调度策略将Pod调度到相应的机器上

- ```kubelet```：负责维护容器的生命周期，同时也负责Volume（CSI）和网络（CNI）的管理

- ```Container runtime（docker）```：负责镜像管理以及Pod和容器的真正运行（CRI）

- ```kube-proxy```：负责为Service提供cluster内部的服务发现和负载均衡

  

----



##### 创建Pod的过程

* 使用```kubectl```或者直接调用```kube-apiservice```提供api的方式发起创建```pod```的请求

* ```kube-apiserver```：把要创建的的```pod```配置存储到```etcd```中
* ```kube-scheduler```：从```kube-apiserver```获取到相关```pod```的配置，它会检索所有符合该Pod要求的```node```列表，开始执行```pod```调度逻辑，调度成功后将```pod```绑定到目标节点上
* ```kube-controller-manager```：从```kube-apiserver```获取到相关```pod```的配置，定期检查```pod```的状态，保证有用户配置的足够数量的```pod```副本在运行，生成```service```到```pod```的规则关系。
* ```kubelet```：从```kube-apiserver```获取分配到本节点相关pod的配置，在本地启动容器并定期检查返回容器状态
* ```kube-proxy```：从```kube-apiserver```获取```service```到```pod```的规则，在本节点维护```iptables```或者```ipvs```相关路有规则。



----



##### 删除Pod的过程

* 使用```kubectl```或者直接调用```kube-apiservice```发起删除```pod```的请求，默认宽限期是30秒
* 在客户端命令行上显示的Pod状态为```terminating```
* 同第二步一起，```pod```所在单节点的```kubelet```发现该```pod```被标记为```terminating```状态时，开始停止```pod```进程
* 同第二步一起，```kube-controller-manager```将该```Pod```从```service```的端点列表中删除，不再被视为```replication controller```的运行```pod```集的一部分。
* 过了30秒宽限期后，将会向```pod```中依然运行的进程发送SIGKILL信号而杀掉进程。
* ```Kublete```会在```API server```中完成```pod```的的删除，通过将优雅周期设置为0（立即删除）。```pod```在API中消失，并且在客户端也不可见。
