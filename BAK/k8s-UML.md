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


1. 客户端提交创建请求，可以通过API Server的Restful API，也可以使用kubectl命令行工具。支持的数据类型包括JSON和YAML。
2. API Server处理用户请求，存储Pod数据到etcd。
3. 调度器通过API Server查看未绑定的Pod。尝试为Pod分配主机。
4. 过滤主机 (调度预选)：调度器用一组规则过滤掉不符合要求的主机。比如Pod指定了所需要的资源量，那么可用资源比Pod需要的资源量少的主机会被过滤掉。
5. 主机打分(调度优选)：对第一步筛选出的符合要求的主机进行打分，在主机打分阶段，调度器会考虑一些整体优化策略，比如把容一个Replication Controller的副本分布到不同的主机上，使用最低负载的主机等。
6. 选择主机：选择打分最高的主机，进行binding操作，
7. 将结果返回API Server处理,并存储到etcd中。
8. kubelet根据调度结果执行Pod创建操作：绑定成功后，scheduler会调用APIServer的API在etcd中创建一个boundpod对象，描述在一个工作节点上绑定运行的所有pod信息。运行在每个工作节点上的kubelet也会定期与etcd同步boundpod信息，一旦发现应该在该工作节点上运行的boundpod对象没有更新，则调用Docker API创建并启动pod内的容器。
9. kube-controller-manager从kube-apiserver获取到相关pod的配置，定期检查pod的状态，保证有用户配置的足够数量的pod副本在运行，生成service到pod的规则关系。
10. 将结果返回API Server处理,并存储到etcd中。
11. kube-proxy从kube-apiserver获取service到pod的规则，在本节点维护iptables或者ipvs相关路有规则。

##### 删除Pod的过程

* 使用```kubectl```或者直接调用```kube-apiservice```发起删除```pod```的请求，默认宽限期是30秒
* 在客户端命令行上显示的Pod状态为```terminating```
* 同第二步一起，```pod```所在单节点的```kubelet```发现该```pod```被标记为```terminating```状态时，开始停止```pod```进程
* 同第二步一起，```kube-controller-manager```将该```Pod```从```service```的端点列表中删除，不再被视为```replication controller```的运行```pod```集的一部分。
* 过了30秒宽限期后，将会向```pod```中依然运行的进程发送SIGKILL信号而杀掉进程。
* ```Kublete```会在```API server```中完成```pod```的的删除，通过将优雅周期设置为0（立即删除）。```pod```在API中消失，并且在客户端也不可见。




#####

k8s DNS设置: https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/
