#  容器云/售前面试

## 离职原因/为什么选择做售前

在灵雀云做了两年的项目交付运维，在项目中重复机械劳动多，在工作中遇到个人的成长瓶颈，过去多是至下而上的解决客户的现场问题，在积累了多年的运维实施经验，做了很多客户现场的实施方案后，想尝试往架构和的面向客户的解决方案方向去尝试

## 你觉得适合售前的这岗位？

在这两年做了很多项目交付，特别是比较长的经历了服务中油瑞飞，和最近在在服务光大银行客户的这一年里，不仅仅按部就班的做的现场实施和运维，
1 实际要更多的是和客户沟通，理解客户的期望，完成客户的目标和要求，形成落地方案，并完成客户生产环境的变更
2 在这个过程要和不断的和公司后产品，研发，测试等后端同事沟通，确认是故障，还是bug，还是需求，积极反馈给后端

无论和现场和客户还是和公司技术团队，我都能很好的配合，共同服务好客户


## K8S 面试技术点

### k8s 各个组件，及其功能

Kubernetes集群主要由Master和Node两类节点组成
Master的组件包括：
  * apiserver
  * controller-manager
  * scheduler
  * etcd等几个组件，其中apiserver是整个集群的网关,整个集群的资源存储在etcd中，
Node主要由
  * kubelet
  * kube-proxy
  * docker引擎等组件组成。kubelet是K8S集群的工作与节点上的代理组件。

还包括CoreDNS、Prometheus（或HeapSter）、Dashboard、Ingress Controller ,operator  Controller


### POD 是如何工作的/以及 pause 容器的作用

Pod 是k8s的最小调度单元， Pod的本质是容器组，每个Pod里运行着一个特殊的被称之为Pause的容器，其他容器则为业务容器，这些业务容器共享Pause容器的网络栈和Volume挂载卷，利用这一特性将一组密切相关的服务进程放入同一个Pod中。同一个Pod里的容器之间仅需通过localhost就能互相通信, 通信和数据交换更为高效, 也能更好的实现自愈

kubernetes中的pause容器主要为每个业务容器提供以下功能：
  * PID命名空间：Pod中的不同应用程序可以看到其他应用程序的进程ID。
  * 网络命名空间：Pod中的多个容器能够访问同一个IP和端口范围。
  * IPC命名空间：Pod中的多个容器能够使用SystemV IPC或POSIX消息队列进行通信。
  * UTS命名空间：Pod中的多个容器共享一个主机名；Volumes（共享存储卷）：
  * Pod中的各个容器可以访问在Pod级别定义的Volumes。

Pod控制器有Deployment、StatefulSet DaemontSet JOBS

### service 类型 以及如何工作

* ClusterIP
* NodePort 
* Headless CluserIP   无头模式，无serviceip，即把spec.clusterip设置为None
* LoadBalancer
* Ingress

用于Pod的辨识，而Servcie就是通过标签选择器，关联至同一标签类型的Pod资源对象。这样就实现了从service-->pod-->container的一个过程


### proxy 转发模式

1 userspace 模式
2 iptables 模式
3 ipvs 模式

userspace 模式  该模式下kube-proxy会为每一个Service创建一个监听端口。发向Cluster IP的请求被Iptables规则重定向到Kube-proxy监听的端口上，Kube-proxy根据LB算法选择一个提供服务的Pod并和其建立链接，以将请求转发到Pod上。

为了避免增加内核和用户空间的数据拷贝操作，提高转发效率，Kube-proxy提供了iptables模式。在该模式下，Kube-proxy为service后端的每个Pod创建对应的iptables规则，直接将发向Cluster IP的请求重定向到一个Pod IP。
该模式下Kube-proxy不承担四层代理的角色，只负责创建iptables规则。该模式的优点是较userspace模式效率更高，但不能提供灵活的LB策略，当后端Pod不可用时也无法进行重试。

该模式和iptables类似，kube-proxy监控Pod的变化并创建相应的ipvs rules。ipvs也是在kernel模式下通过netfilter实现的，但采用了hash table来存储规则，因此在规则较多的情况下，Ipvs相对iptables转发效率更高。除此以外，ipvs支持更多的LB算法。如果要设置kube-proxy为ipvs模式，必须在操作系统中安装IPVS内核模块。


### 一个pod的完整生命周期

客户端提交创建请求，可以通过API Server的Restful API，也可以使用kubectl命令行工具。支持的数据类型包括JSON和YAML。
（2）API Server处理用户请求，存储Pod数据到etcd。
（3）调度器通过API Server查看未绑定的Pod。尝试为Pod分配主机。
（4）过滤主机 (调度预选)：调度器用一组规则过滤掉不符合要求的主机。比如Pod指定了所需要的资源量，那么可用资源比Pod需要的资源量少的主机会被过滤掉。
（5）主机打分(调度优选)：对第一步筛选出的符合要求的主机进行打分，在主机打分阶段，调度器会考虑一些整体优化策略，比如把容一个Replication Controller的副本分布到不同的主机上，使用最低负载的主机等。
（6）选择主机：选择打分最高的主机，进行binding操作，结果存储到etcd中。
（7）kubelet根据调度结果执行Pod创建操作： 绑定成功后，scheduler会调用APIServer的API在etcd中创建一个boundpod对象，描述在一个工作节点上绑定运行的所有pod信息。运行在每个工作节点上的kubelet也会定期与etcd同步boundpod信息，一旦发现应该在该工作节点上运行的boundpod对象没有更新，则调用Docker API创建并启动pod内的容器。

### K8S CNI 网络

* Overlay        典型的Flannel-VxLAN                   IP可达              默认256节点 
* Underlay       MacVLAN  ipVLAN                       二层可达            
* L3             Calico-BGP，Flannel-HostGW            二层可达或BGP可达  
* 商业           nsx-t      

###  DevOPS

gitlib jenkins ansible 

###  微服务

sprintcloud    soprintboot  只能面向java
servicemesh    istro        面向多语言，

服务的消费方和提供方主机(或者容器)两边都会部署代理SideCar。
* ServiceMesh 数据面板(DataPlane)， 
* 一个独立部署的控制面板(ControlPlane)，用来集中配置和管理数据面板，也可以对接各种服务发现机制(如K8S服务发现)


控制面板功能主要包括：

* Istio-Manager：负责服务发现，路由分流，熔断限流等配置数据的管理和下发
* Mixer：负责收集代理上采集的度量数据，进行集中监控
* Istio-Auth：负责安全控制数据的管理和下发

数据面板：
  Envoy

## K8S 扩展

### 集群发生雪崩的条件，以及预防手段

* 加强监控和预警，对集群reuqest/ node reuqest 监控告警 
* 在资源规划的时候，对集群整体资源预留做考虑

###  大规模集群：10K

当 Kubernetes 集群规模达到 10k 节点时，系统的各个组件均出现相应的性能问题，比如：

* etcd 中出现了大量的读写延迟，并且产生了拒绝服务的情形，同时因其空间的限制也无法承载 Kubernetes 存储大量的对象；
* API Server 查询 pods/nodes 延迟非常的高，并发查询请求可能地址后端 etcd oom；
* Controller 不能及时从 API Server 感知到在最新的变化，处理的延时较高；当发生异常重启时，服务的恢复时间需要几分钟；
* Scheduler 延迟高、吞吐低，无法适应阿里业务日常运维的需求，更无法支持大促态的极端场景。

解决 

1 上万规模需要用ipvs做转发，网络用calico性能更好。当kubernetes规模达到上万时，会出现如下问题
2 增加master资源,将和部署的组件肚独立出来
3 优化etcd -> etcd 独立集群+SSD
4 镜像中心+缓存 部署应用
5 另一个超过1,000后节点故障是超过了etcd的硬盘存储限制（默认2GB）   

如何解决?
1）通过将索引和数据分离、数据 shard 等方式提高 etcd 存储容量，并最终通过改进 etcd 底层 bbolt db 存储引擎的块分配算法，大幅提高了 etcd 在存储大数据量场景下的性能，通过单 etcd 集群支持大规模 Kubernetes 集群，大幅简化了整个系统架构的复杂性；
2）通过落地 Kubernetes 轻量级心跳、改进 HA 集群下多个 API Server 节点的负载均衡、ListWatch 机制中增加 bookmark、通过索引与 Cache 的方式改进了 Kubernetes 大规模集群中最头疼的 List 性能瓶颈，使得稳定的运行万节点集群成为可能；
3）通过热备的方式大幅缩短了 controller/scheduler 在主备切换时的服务中断时间，提高了整个集群的可用性；


###  灰度发布 k8s + Ingress-Nginx/ LB
              k8s + 微服务

### 


 
 
