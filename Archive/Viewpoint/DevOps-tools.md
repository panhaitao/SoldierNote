## DevOps 主要工具汇总对比
对比项：

* 开发语言
* 软件架构
* 主要特性(features)
* 适用场景
* 典型用户


# 配置管理工具对比

## chef          

* 使用ruby语言开发        

* C/S 官方文档描述，提供三个角色
  * Chef DK workstation 
  * Chef server
  * Chef client nodes 

* 特性
  * 支持 physical, virtual, cloud, network device，容器等设备的管理
  * 管理数据包、属性、run-lists、角色、环境和cookbooks, 还可以为用户和组配置基于角色的访问
  * 提供开发套(Chef Development Kit)，用于完成配置库的编写，调试和上传到Chef Server
  * 提供配置库(Cookbooks）用于存储客户端主机的食谱，属性，自定义资源，库，文件，模板，测试和元数据
  * 支持 Chef-repo 的版本控制
  * 可以使用插件扩展功能
  * 支持跨许多云提供商和虚拟化技术的配置库
  * 支持Ruby社区使用的所有常见测试框架
  * 提供社区管理和维护的配置库商店(Cookbooks)
  * 提供模拟节点上资源收敛的工具ChefSpec
  * 提供能够完成包括系统基本系统，处理器，内存，网络等信息收集的工具Ohai
  
* 适用场景

适用大规模主机集群的管理，更适合以Ruby语言开发的业务应用场景

* 典型用户

* 参考：
  * https://docs.chef.io/chef_overview.html 

## puppt         

ruby        

C/S


## saltstack     

python      

C/S                                       

## ansible       

python      

ssh协议 



# 容器编排

 
