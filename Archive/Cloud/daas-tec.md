# DaaS 桌面云的现状

企业对企业桌面云的需求：

1. 云桌面的集中管控，

2. 对网络关系的开通与集中控制

3. 身份认证，支持LDAP，AD域等  

4. 浏览器作为基于云的虚拟应用及桌面的客户端，目前市场上已有

* AWS WorkSpace Web Access
* VMware Horizon Air
* Citrix Cloud 国内的青云用就是这个方案
* Chrome Remote Desktop 浏览器插件

5. 虚拟桌面服务端

传统的虚拟桌面协议:协议有VNC/SPICE/RDP三种

## 对linux webos 的构想

1. 基于linux 轻量级桌面极度精简，去掉大部分组件，默认只保留用于支持浏览器，输入法，文本编辑器，终端的运行环境
2. 系统分区和数据分区分离, 打通chrome的账户和与桌面的账户
3. 服务端 docker封装桌面运行环境，客户端基于浏览器访问
*  开源项目:https://github.com/fcwu/docker-ubuntu-vnc-desktop 
4. k8s调度桌面pod，存储可以直接使用k8s的存储类
5  桌面虚拟网络，可以考虑Nebula 分布式VPN，可以打通nat模式网络
