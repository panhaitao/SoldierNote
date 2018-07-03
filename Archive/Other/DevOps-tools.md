## DevOps 主要工具汇总对比
对比项：

* 开发语言
* 软件架构
* 优缺点 

# 配置管理工具对比

## chef          

* 使用ruby语言开发
* C/S架构
* 官方文档描述，可以划分为三个角色
  * Chef DK workstation 
  * Chef server
  * Chef client nodes 

* 优点：
 * 代码驱动方法可以提供丰富的模块和配置配方。
 * 提供了更多的配置控制和灵活性。
 * 以Git为中心赋予它强大的版本控制功能。
 * 提供方便部署的工具（使用SSH从工作站部署代理）可以减轻安装负担。

* 缺点：
 * 如果您不熟悉Ruby和过程编码，则学习曲线会非常陡峭。
 * 这不是一个简单的工具，可能会导致大量的代码库和复杂的环境。
 * 不支持推送功能。

## puppet         

* 使用ruby语言开发
* C/S架构
* 官方文档描述，可以划分为两个角色
  * puppet master 
  * puppet agent 

* 优点：
  * 建立了良好的支持社区。
  * 具有最成熟的界面，几乎可以在每个操作系统上运行。
  * 提供简单的安装和初始设置。
  * 这个空间中最完整的Web UI。
  * 强大的报告功能。
* 缺点：
  * 对于更高级的任务，您将需要使用基于Ruby的CLI（意味着您必须了解Ruby）。
  * 支持纯粹的Ruby版本（而不是那些使用Puppet定制的DSL）正在被缩减。
  * 由于DSL和一个不以简单为重点的设计，代码库可能会变得庞大，笨拙，难以在更高的规模上为组织中的新人提供帮助。
  * 与代码驱动方法相比，模型驱动方法意味着更少的控制。

## saltstack     

* 使用python语言开发
* C/S架构
* 官方文档描述,可以划分为三个角色
  * salt master
  * salt syndic 
  * salt minion 

* 优点：
 * 简单的组织和使用。
 * DSL功能丰富，不需要逻辑和状态。
 * 输入，输出和配置非常一致 - 所有YAML。
 * 执行输出反馈是非常好的。 在Salt中很容易看到发生了什么事情。
 * 强大的社区。
 * 高级可扩展性和弹性主从，扩展和分层。

* 缺点：
 * 很难建立和接受新的用户。
 * 文档在介绍级别上很难理解。
 * 比的其他工具的Web UI更不完整。
 * 对非Linux操作系统没有很好的支持。

## ansible       

* 使用python语言开发
* ssh协议 
* 优点：
 * 基于SSH的，所以它不需要在远程节点上安装任何代理。
 * 可轻松管理不同主机数量的集群
 * 由于使用YAML，学习曲线容易
 * Playbook结构简单，结构清晰
 * 具有变量注册功能，可以使任务为以后的任务注册变量
 * 比其他工具更精简的代码库

* 缺点：

  * 没有基于其他编程语言的工具更强大。
  * 它的逻辑通过它的DSL，这意味着需要经常检查文档，直到掌握它
  * 基本功能都需要变量注册，导致简单的任务也变得很复杂
  * 执行反馈不是很好。在playbook中很难看到变量的值
  * 输入，输出和配置文件格式之间没有一致性
  * 比起同类工具性能速度处于劣势

# 容器编排

* Docker Swarm只是从单个容器引擎提供一个集群系统的视角
* Google Kubernetes是一个全径且全面的容器管理平台，有动态调度、升级、自动伸缩和持续健康监测的功能。
* Apache Mesos是一个集群管理工具，它着重于资源隔离，以及分布式网络或者在框架上分享应用程序
* Mesos和Kubernetes比较相似，因为他们都是被开发来解决在集群化环境中运行应用程序的问题。但Mesos在运行集群方面不如Kubernetes，它重点放在于强大的调度功能和解决性能上。
* Mesos并不是为容器而生的，在容器流行之前就已经被开发出来，它的一些地方被修改来支持容器。

# 参考：

* https://docs.chef.io/chef_overview.html
* https://blog.takipi.com/deployment-management-tools-chef-vs-puppet-vs-ansible-vs-saltstack-vs-fabric/
* https://segmentfault.com/a/1190000005185138