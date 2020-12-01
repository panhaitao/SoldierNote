# 如何高效管理Ucloud云主机资源

## 快速准备资源

  面对云计算一定会听到IaaS、PaaS、等概念，IaaS层云服务或者应用，解决了计算,网络,存储资源的服务化，让用户从最底层的IDC（数据中心）、网络、服务器和系统等基础运维工作中释放出来，PaaS则进一步封装了操作系统，中间件，数据库，等应用依赖的公共服务，但面向业务应用开发人员并不关心这些细节，他们只关心运维侧能如何高效稳定的提供所需的资源，能顺利完成开发，测试，并发布交付最终用户使用，回到如何云服务提供的视角，能提供IaaS层和PaaS层服务的云服务提供商，就能解决一切的运维之痛，我们还是需要借助适合的运维工具，或者选择合理高效的方法来高效完成工作。

  在实际的工作中，我们经常回遇到这样一类场景，需要快速初始化一批机器，但是数量很多，包括部分身边的同事，或者部分遇见的客户可能是这样操作,浏览器打开ucloud控制台 https://console.ucloud.cn/:
  * 鼠标操作，选择云主机UHost
  * 鼠标操作，创建主机，
  * 鼠标操作，选择地域，选择基础配置，选择网络配置，管理设置等，
  * 鼠标操作，填写购买数量，选择付费方式，
  * 鼠标操作，立即购买，确认支付
  * 然后进入下一个循环

  如果每次是购买少量的机器，UI向导式的操作是方便，但如果是开启一次压测任务，一次性的要创建几十甚至近百台机器，UI向导式的操作反而成了局限性，实际上任何一家公有云提供了云品台的API接口，UCloud也一样，控制台 -> 操作管理 -> API 产品UAPI 就可以使用API来完成云平台的一切操作，可能有些人不喜欢用接口完成操作，觉得编写代码是麻烦或者是一种额外的负担，实际调试完成代码是可以复用的，并且API 产品提供了实例代码，方便留存复用，下面我可以通过一个表格来对比两种操作方式

  先对比一个单一场景，创建100台云主机，配置4核8G，用于游戏压测

  |  Web操作方式                           |              使用API操作                        |
  |  -----------------------------------  | --------------------------------------------- |
  | 点击创建主机 <br> 定义主机配置，地域，基础配置，网络配置，管理设置<br>确认付款      |   (首次)使用UAPI控制台生成创建主机示例脚本<br>将变量部分更改为通过读取变量文件实现      |
  | 循环操作十次      |  定义配置，执行创建主机脚本 | 

  假设最近又有一次申请主机，近期各业务部门合集新增加30台云主机，其中2台用于测试，5台用于扩容大数据HDFS节点，1台用于ES集群，5台用于搭建K8S集群... 
  
  |  Web操作方式                           |              使用API操作                        |
  |  -----------------------------------  | --------------------------------------------- |
  | 点击创建主机 <br> 定义主机配置，地域，基础配置，网络配置，管理设置 <br>确认付款 <br> (有多少不同的主机类型，就要执行多少次不同的操作)      | 定义配置，根据任务，将要执行创建主机脚本形成批处理脚本 <br> 检查配置，一次执行批处理脚本,完成操作 |
  
  以上只是简单举了两个运维场景的例子，上面的例子有点像Windows视窗操作理念和Linux命令操作理念之争的感觉，实际我表达的就是, 不同场景使用最佳匹配的使用方式，一次简单的创建几台主机，UI向导式简单便捷，批量处理任务，操作API，编写脚本更省时省力。  

  当完成云主机创建后, 一定会有相应的节点初始化操作，比如更改主机名，安装软件包，配置挂在磁盘，分发配置等,传统的操作方式，一台台使用ssh或其他远方式登陆操作，或者借助shell脚本批量操作，除了这种操作方式，还有其他更高效的操作方式，比如选用合适的运维工具，老牌的有Puppet、Chef、后来的SaltStack，以及前些年被RedHat公司收购的ansible等，其中ansible是最灵活高效的，可以让用户轻松配维护从单机，到数十台、数百台，设置更大规模的设施. 在这里我就不具体谈论ansible的安装部署和使用，还是回到创建100台云主机，配置4核8G, 并部署好游戏压测工具客户端的场景，来对比下使用API脚本加运维工具比起WebUI操作方式带来的时间收益：

  |            |          WebUI+普通操作                  　|                 使用接口+运维工具                                           |
  | ---------- |------------------------------------------- | ----------------------------------------------------------------------------|
  |  创建主机  | 至少滑动,点击鼠标10~15次(耗时30s)<br> 重复十次:完成100台主机创建(耗时5min) |  编写调用接口脚本(耗时10min～15min)<br> 编写创建主机的配置文件，定义类型, 数量 (耗时1min～3min) <br> 一次执行API脚本读取配置, 批量创建100台主机(耗时3～5min)   | 
  |  初始化    | 依次登陆100台主机，配置压测软件(至少1小时) |  编写调试tasks(耗时10min～15min) <br> ansible执行初始化100台主机tasks (耗时5min)      | 
  |  开始压测  | 使用shell获取其他方式控制100台主机开发开始压测(耗时等同于压测时间) |  使用ansible远程执行命令控制100台主机压测(耗时等同于压测时间) | 
  |  修改参数  | 依次登陆100台主机，完成参数修改(至少1小时) |  使用ansible执行playbook重新初始化100台主机配置(耗时5min)                             | 
  |  重复压测  | 使用shell获取其他方式控制100台主机开发开始压测(耗时等同于压测时间) |  使用ansible远程执行命令控制100台主机压测(耗时等同于压测时间) |
 
  使用WebUI的普通操作方式中,一次操作5～10台，比较便捷，当操作量级达到数十数百量级的时候，特别在节点初始化操作，以及特别变更操作工作量比较大
  使用使用API接口和运维工具的操作方式中，在前期编写调用接口脚本,和编写ansible tasks 需要花费些时间,在后续特别是配置变更，批量操作等能突显强大的管理控制能力
  甚至在某些具备运维开发能力的客户，管理资源完全使用API接口来实现业务相关的功能，比如上线或者变更一个边缘节点，扩充某个集群等。

## 管理资源列表

  Ansible 是通过 inventory 文件来管理资源的，支持静态 Inventory 和动态 Inventory 两种方式：
  * 静态 Inventory 是读取Inventory文件里定义的主机和组
  * 动态 Inventory 则通过自定义的Inventory脚本获取资源
  运维上一般一般会结合 CMDB 资管系统、云计算平台等获取主机信息。平台资源会根据实际情况动态增减, 如果维护的是一份静态 Inventory(也就是需要同步更新一份ansible 服务端的 hosts 文件)，如果平台资源体量很大，并且变动频繁，那么维护同步更新的静态 Inventory也是一个不轻松的工作，使用到动态获取 inventory 的方法，可以省去这样的麻烦，相当于一处定义，处处引用，对于Ucloud云平台，我们也维护了一份面向ucloud云平台资产管理的动态Inventory（ucloud-ansible-inventory)，借助动态Inventory ansible可以轻松获取云平台主机资源，

* 使用静态 Inventory
  静态 Inventory 是ansible.conf定义的文件，默认是/etc/ansible/hosts 一个简单的例子如下:
```
[web]
web1                ansible_ssh_host=10.10.33.1
[db]
db1                 ansible_ssh_host=10.10.33.5

[k8s]
k8s-1                ansible_ssh_host=10.10.33.7

[all:vars]
ansible_connection=ssh
ansible_ssh_user=root
ansible_ssh_pass="xxxxxxxxx"
```

* 使用动态 Inventory
  动态 Inventory  需要 ansible.conf 定义的配置 inventory = inventory/ucloud.py, 当ansible 工作的时候，会自动引用`inventory/ucloud.py --list`的输出作为输入，不用额外维护一份 /etc/ansible/hosts 文件，随时可以动态获取，管理控制台能看到云主机资源

<div style="float:left;border:solid 1px 000;margin:2px;">
  <img src="https://github.com/panhaitao/SoldierNote/blob/master/static/ucloud_uhost_webconsole.png"  width="40%" height="260" >
</div>
<div style="float:left;border:solid 1px 000;margin:2px;">
  <img src="https://github.com/panhaitao/SoldierNote/blob/master/static/ansibe_list_hosts.png"  width="40%" height="260" >
</div>


## 像编写剧本一样管理资源

   远程执行命令, 

   剧本(Playbook): 一组使用YAML格式语言编写的，可重复执行的任务集合, Playbooks 是使用Ansible的配置,部署的核心所在，只要使用yaml编排好任务，为不同的资源分配不同的角色，云主机或者其他资源就会按照预定的任务，完成对应的变更，这里的能执行的任务，包括不局限于，远程执行命令完成部署操作，分发配置文件，重启服务，通过运行自定义脚本，想编写代码一样定义Playbook，可以完成各种复杂的操作 

  |       执行命令              |    执行 Playbook      |
  |  -------------------------  | ---------------------- |
  |  编写 hosts 文件            | 编写动态Inventory脚本  |

## 常见场景参考

## 参考资源

阅读本篇需要对ansible有一定的了解，不熟悉ansible的同学请先阅读 [ansible 基础指南]<https://github.com/panhaitao/SoldierNote/blob/master/Archive/DevOps/ansible-base-howto.md>以下是结合ansible的应用场景

2. 初始化压测主机
  * 初始化nginx/uwsgi 集群
  * 初始化jmeter压测节点
  * 初始化wrk压测节点
  * 初始化ab压测节点
3. 批量配置docker主机
4. 批量初始化USMC agent
5. 批量操作Windows云主机做游戏压测
6. 启动一个promethus server和grafana
7. 

## 应用场景

### 场景一: 快速准备需要的主机
5. 补全参考配置文件 (example/uhost_type_o.yml 是快杰云主机， example/uhost_type_n.yml 是普通云主机)
  * 修改 auth.public_key auth.private_key 可以登陆 console.ucloud.cn -> 全部产品-> API 产品 查看自己的 API密钥
  * 修改 os.password 定义新创建的主机登陆密码
  * 修改 os.maxhosts 定义创建主机数量
  * 其他根据需要修改
6. 以创建快杰云主机为例，进入 /data/playbook工作目录，执行命令` sh scripts/create_inventory_file.sh  /data/playbook/example/uhost_type_o.yml `后，会在 hosts目录下生成ansible需要的inventory文件
7. 测试新创建的主机是否就绪: 进入 /data/playbook工作目录,执行命令` ansible -i hosts/<file_name>  all -m shell -a 'pwd' -o ` 如果都能正确返回，说明主机已经就绪

### 场景二: 初始化压测主机

在配合客户做压测的时候我们经常需要创建批量的主机，并且用后即换，我们可以使用<场景一: 快速准备需要的主机>的示例创建好需要数量的主机，然后写好的ansible playbook 完成初始化

1. 初始化 uwsgi 节点,执行命令 ansible-playbook -i hosts/<file_name> todo/init_uwsgi_hosts -D  用做LB web服务测试后端节点
  * 验证端口 ansible -i hosts/<file_name>  <group_name> -m shell -a "netstat -nat |grep 80"
  * 验证进程 ansible -i hosts/<file_name>  <group_name> -m shell -a "ps -ef | grep uwsgi"
  * 确认服务就绪，就可以挂到 ULB 上进行压测
2. 初始化 jmeter 压测节点, ansible-playbook -i hosts/<file_name> todo/init_jemter_hosts -D 然后根据压测需要，上传压测需要的jmx文件
  * 开始压测: /home/apache-jmeter-5.2.1/bin/jmeter -n -t other/post_example.jmx -l result/result.jtl -e -o result -R node-1,node-2,node-3...
  * 终止压测: ansible -i hosts/<file_name> <group_name> -m shell -a "pkill jmeter-server; pkill jmeter"
3. 初始化 ab 压测节点, 执行命令 ansible-playbook -i hosts/<file_name> todo/init_ab_hosts -D, 根据压测需要，修改要运行的脚本 scripts/run_ab_bench.sh
  * 开始压测: ansible -i hosts/<file_name> <group_name> -m script -a scripts/run_ab_benc.sh  
  * 终止压测: ansible -i hosts/<file_name> <group_name> -m shell -a "pkill ab"
4. 初始化 wrk 压测节点,执行命令 ansible-playbook -i hosts/<file_name> todo/init_wrk_hosts -D, 根据压测需要，修改要运行的脚本 scripts/run_wrk.sh 
  * 开始压测: ansible -i hosts/<file_name> <group_name> -m script -a scripts/run_wrk.sh  
  * 终止压测: ansible -i hosts/<file_name> <group_name> -m shell -a "pkill wrk"

### 场景三: 批量配置docker主机

在当下的容器时代，部署容器应用是一个常态的事情，对于快速初始化一批安装的docker主机，或者变更docker配置，使用ansible 可以轻松完成

  * ansible-playbook -i hosts/<file_name> todo/init_docker_hosts -D

### 场景四: 批量初始化USMC agent
使用USMC做主机迁移，比如机械的操作是安装USMC agent，如果一次迁移的主机数量比较多，可以借助ansible 来完成批量操作

* 手动创建好 ansible inventory 文件，将要迁移的主机IP，登陆密码填入
* 服务器迁移中心 USMC → 创建迁移计划，将生成的计划ID usmc-xxxxx 设置为 todo/init_usmc_agent 的usmc_id 值
* 执行命令 ansible-playbook -i hosts/k8s todo/init_uwsgi_hosts -D 完成USMC agent的部署，
* 继续进行迁移计划的其他操作

### 场景五: 使用windows云主机做游戏压测

客户方需要做游戏业务压测，压测工具是运行windows上的GUI程序，需要100+数量级别的windows云主机做并发压测，已经

## Playbook配置库参考说明

1. ansible镜像的Dockerfile:  https://github.com/panhaitao/alpine-ansible.git
2. Playbook配置库: https://github.com/panhaitao/Playbook-Performance-Test.git
  * example/uhost_type_o.yml 配置文件详细说明
  * example/uhost_type_n.yml 配置文件详细说明
