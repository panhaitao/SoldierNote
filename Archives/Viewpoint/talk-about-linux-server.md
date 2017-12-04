---
title: 深度服务器操作系统之路
tags: 国产系统
categories: 视角
---

## 服务器版本回顾

* 2014年，
* 2015年，以debian8为基础，选用mate-deskop为默认桌面，完成第一个版本(20151028)
* 2016年，在桌面团队发布基于debian sid的版本后，开始整合DDE桌面环境，进行LSB认证，在经历了大半年的努力后，这个服务器版本并不成功，快速迭代的版本发布周期，并不是适合企业用户，桌面团队开发的DDE桌面也不适用于服务器生产环境，最后终于决定服务器版本放弃整合dde桌面， 之后张磊放弃对服务器团队的管理工作，研发和测试和原工程团队合并为技术团队，由木梁直接领导。
* 2017年，公司服务器产品产品重新规划，停滞基于 debian8 版本的开发工作，以CentOS 8为基础创建x86企业版本，以debian9为基础创建x86社区版本。

## 主流服务器操作系统厂商

### 产品线对比

|               |   RHEL                         |     SUSE      |   Ubuntu         |    Deepin                                                                                                                                            |
|---------------|--------------------------------|---------------|------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|            
|  服务器       |  RHEL 6.x/ 7.x                 |   SUSE 12     |   Ubuntu Server  |  x86企业版15.1(debian8)<br> x86企业版15.2(centos6)<br> x86社区版15.0(debian9) <br> mips64el龙芯版15.1(debian9) <br> sw64申威版 15.0(debian8~debian9) |
|  桌面版本     |    有                          |      有       |       有         |  deepin desktop (debian sid)                                                                                                                         |
|  工作站       |    有                          |      有       |       无         |                                                                                                                                                      |
|  core系统     |    Fedora(Atomic)              |    MicroOS    |   Ubuntu Core    |                                                                                                                                                      |
|  配置管控系统 |    Satellite                   |  SUSE Manager |                  |                                                                                                                                                      |

RHEL, SUSE, Ubuntu 三家操作系统厂商除了拥有从桌面或者工作站到服务器核心产品线外，每家都有自己独特的产品和解决方案在CoreOS出现后，三家分别作出了相应动作

* RHEL在自己资助的fedora社区推出了面向运行， 托管Docker容器的Atomic
* SUSE则在自己的CaaS解决方案中整合了同样是面向Docker容器的MicroOS
* Ubuntu略有不同，推出了面向物联网的Ubuntu Core系统和对应snap包格式 

另外RHEL 创建了Satellite , SUSE创建了 SUSE Manager，提供面向管理员的OPS系统版本，通过一个简单的管理端和一套方便管理方法, 来管理物理机，虚拟机，云服务器，完成软件软件，更新，配置分发，服务启停，跟踪监控分析等运维功能。

Deepin 服务器从最初的上游选型和方向策略都存在问题，走了很多弯路，过快的版本发布周期，整合DDE桌面，创建过多但是没有落地的服务器分支版本:大数据版，云端系统版本，以及各种定制版本等，在目前无法搜集足够的客户需求时，面向政府机关等项目这些离不开IOE，服务系统选型只能最大限度的匹配应用，兼通红帽系，对于服务器版本后续规划中，提出三点建议:

* 及时砍掉无力维护的服务器社区版本，除了对工商总局已有客户的支持外，彻底停滞原debian8版本的后续开发工作；
* 基于Centos7的系统后续规划， 对于系统本身建议制作最小更改，尽可能保持和上游和IOE等企业级应用的兼容程度；

### 解决方案或支持服务对比

|                 |  RHEL                                                 |       SUSE                                                           |   Ubuntu             |    Deepin    | 
|-----------------|-------------------------------------------------------|----------------------------------------------------------------------|----------------------|--------------|
|    IaaS         |  CloudForms <br> OpenStack                            |    openstack                                                         |   openstack          |              |      
|    PaaS         |  OpenShift                                            |                                                                      |                      |              |
|    CaaS         |  Kubernetes                                           |    Kubernetes<br> MicroOS <br> Salt                                  |                      |              |
|    公共云       |  Openstack                                            |    openstack                                                         |                      |              |
|    集群与高可用 |                                                       |    Pacemaker HA                                                      |   Livepatch          |              | 
|    SAP 解决方案 |                                                       |    SAP HANA                                                          |                      |              | 
|    存储         |  Gluster <br> Ceph                                    |    Ceph                                                              |                      |              |
|    中间件       |  JBoss                                                |                                                                      |                      |              |
|    认证管理     |  LDAP                                                 |                                                                      |                      |              |
|    移动应用     |  移动应用平台                                         |                                                                      |                      |              |
|    DevOps       |  Satellite <br> CloudForms <br> ansible <br> Insights |    SUSE Manager <br> SUSE Studio                                     |   Ubuntu Advantage   |              |

基础服务与解决方案

* server  : ssh, ntp, ftp(tftp,vsftp), dhcp, bind, unbound, 
* server  : nginx, apache, lighthttp, exim4, posix, sendmail, LDAP
* HA      : LVS, nginx, keepalive, coorsync, pacemaker, drdb, haproxy
* db      : MariaDB, MySQL, PostgreSQL, Redis, MongoDB, InfluxDB
* store   ：Ceph, GlusterFS, NFS, Samba, LVM, RAID
* 中间件  : Tomcat, JBoss, WebSphere、WebLogic, Kafka、RabbitMQ、RocketMQ
* SDN     : Openvswitch, NFV, VPN,  
* 虚拟化  : qemu/kvm, xen, vagrant, libvirt, virtualbox, vmware  
* 容器技术：lxc, docker 
* IaaS    : Openstack, CloudFormS
* PaaS    : Deis、Flynn、Tsuru、Dawn, Octohost,loud Foundry,OpenShift
* CaaS    : Kubernetes, compose , swarm,
* 配置    : puppt,saltstack,ansible,


这些软件面向的互联网，或者大型企业，设计的初衷是充分利用大规模常规服务器组建高性能，高可靠性，易扩展易维护的解决方案，\
和互联网或大型企业相比，我们的政府客户相对而言是服务器数量少，单机性能好，配置高，可以考虑针对比这些对应场景, 以及解决用户痛点为基础，提供服务和解决方案,
在深度服务器产品的发展历程中我们经历了，企业版选择以debian为上游，后由于实际项目需求不得已转回以红帽系为上游，将原来维护的debian版本转换为社区版本，
并期望未来有一天debian社区版本成熟再转化为企业级产品，政府客户和企业客户不可能去IOE化，没有IOE企业级应用厂商的支持，debian系发行版成长为企业级产品
也就无从谈起，芯片和操作系统是IT产业的基石，被世界上几大公司作掌控，服务器系统本身又是一个非常成熟的产品，在公司目前对服务器投入的全部研发资源及其有限前提下，
我们不可能也做不到以拓展新技术为亮点在市场有所突破，回到现实我提出以下几点建议：

* 不针对红帽系上游做无意义的开发工作，把工作重心转移到项目支持和解决方案定制中;
* 花时间去熟悉主流 IaaS, PaaS, CaaS 等解决方案，以达到都能独立搭建及其排查问题;  
* 打造一套实用的CaaS解决方案：harbor + docker + openvswitch + compose + swarm + ansible + semaphore;
* 开辟新的技术预览工作：提供Docker封装服务的镜像，提供可以跨发行版的snap包格式支持;

在传统的应用，数据库，服务等基础架构中”应用与数据分离“已经成熟，在容器技术的推进下，”系统与应用分离“这个目标已经越来越逼近，
未来如果坚持以将服务固化到容器中，应用封装的到跨发行版的包格式中，如果能在技术和观念及其落后的政府和传统企业客户中推行，
那么切换基础系统也将变得越来越容易，

