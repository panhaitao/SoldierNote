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
  
  以上只是简单举了两个运维场景的例子，上面的例子有点像Windows视窗操作理念和Linux命令操作理念之争的感觉，实际我表达的就是, 不同场景使用最佳匹配的使用方式，一次简单的创建几台主机，UI向导式简单便捷，批量处理任务，操作API，编写脚本省力。  

  当完成云主机创建后, 一定会有相应的节点初始化操作，比如更改主机名，安装软件包，配置挂在磁盘，分发配置等,传统的操作方式，一台台使用ssh或其他远方式登陆操作，或者借助shell脚本批量操作，除了这种操作方式，还有其他更高效的操作方式，比如选用合适的运维工具，老牌的有Puppet、Chef、后来的SaltStack，以及前些年被RedHat公司收购的ansible等，其中ansible是最灵活高效的，可以让用户轻松配维护从单机，到数十台、数百台，设置更大规模的设施. 准备一台云主机安装好ansible软件包或者一个容器实例启动ansible即可，以下是使用一种更便捷，更低成本的方式启动一个ansible工作环境：

<img src="https://github.com/panhaitao/SoldierNote/blob/master/static/cube_run_ansible.png" align="right"  width="30%"  border="2" hspace="20" >

<br>

* 登陆ucloud控制台 https://console.ucloud.cn/ 全部产品 → 容器实例cube，创建容器组
* cpu 内存 根据需要配置，比如 2核4G
* 镜像选择→ uhub镜像 仓库名称 ucloud_pts 镜像名称 alpine-ansible 镜像版本 v1.0
* 高阶设置-> 环境变量, name: ROOT_PW value: 自定义密码 ( 设置cube实例的root密码)
* 镜像密钥→ 填入你登陆ucloud平台的用户名和密码
* 自定义网络→ 选择绑定外网IP，选择需要的付费方式，完成cube实例的创建
* 等cube实例启动完毕后，可以使用步骤1.c中定义的root密码ssh登陆容器

<br>
<br>

## 管理资源列表

  ansible 工作环境就绪后，进一步要解决的就是如何使用ansible来管理资源的，ansible目前支持支持静态 Inventory 和动态 Inventory 两种方式来管理资源：

  * 静态 Inventory 是读取Inventory文件里定义的主机和组
  * 动态 Inventory 则通过自定义的Inventory脚本获取资源

  运维上一般会建立 一个 CMDB 系统来管理全部资源，公有云平台本身相当于基础设施的CMDB 系统。平台资源会根据实际情况动态增减, 如果维护的是一份静态 Inventory(也就是需要同步更新一份ansible 服务端的 hosts 文件)，如果平台资源体量很大，并且变动频繁，那么维护同步更新的静态 Inventory也是一个不轻松的工作，使用到动态获取 inventory 的方法，可以省去这样的麻烦，相当于一处定义，处处引用，对于Ucloud云平台，我们也维护了一份面向ucloud云平台资产管理的动态Inventory（ucloud-ansible-inventory)，借助动态Inventory ansible可以轻松获取云平台主机资源，

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
  动态 Inventory  需要 ansible.conf 定义的配置 inventory = inventory/ucloud.py, 当ansible 工作的时候，会自动引用`inventory/ucloud.py --list`的输出作为输入，随时可以获取到和https://console.ucloud.cn/控制台上一致的主机资源信息，达到和使用静态 Inventory一样的效果，但不用额外维护一份 /etc/ansible/hosts 文件，减少了重复劳动，可以想象一下，假如维护的是云平台几百台主机，每次资源变化，都要同步一次/etc/ansible/hosts文件的工作量，下面是一个使用动态 Inventory查看云主机信息的示例：
<center class="half">

<img src="https://github.com/panhaitao/SoldierNote/blob/master/static/ucloud_uhost_webconsole.png"  width="46%" border="2" hspace="20" ><img src="https://github.com/panhaitao/SoldierNote/blob/master/static/ansibe_list_hosts.png" width="46%" border="2" hspace="20" >

</center>


具备了以上条件，这里再使用一个具体的场景: 所有Ucloud云主机安装辅助agent程序，以便可以获取更丰富监控指标（如内存、磁盘空间、进程等）

<img src="https://github.com/panhaitao/SoldierNote/blob/master/static/uhost_with_mem_monitor.png" align="right"  width="30%"  border="2" hspace="20" >


如果不借助运维工具，可能操作步骤如下：

* 最简单，也是最耗时的办法，就是一台台登陆主机，下载agent程序，安装，启动服务
* 或者导出要操作的主机内网IP列表，编写shell脚本，借助Tcl 的expect工具完成自动交互，依次登主机，下载agent程序，安装，启动服务陆

如果使用运维工具ansible, 完成对 web,db,k8s 三个组所有主机安装agent程序，执行如下三条命令即可:

* ansible web,db,k8s -m shell -a 'wget http://umon.api.service.ucloud.cn/static/umatest/uma-1.1.5-1.x86_64.rpm'
* ansible web,db,k8s -m shell -a 'yum localinstall uma-1.1.5-1.x86_64.rpm -y'
* ansible web,db,k8s -m shell -a 'service uma start'

如果后续新增主机也需要安装agent程序，几十台，甚至几百台，都只需要以上三条命令就可以完整agent程序的安装，借助运维管理工具 ansible 和 动态 Inventory，再多的主机管理工作也都可以轻松的完成, 关于如何主机登陆交互，运维工具ansible本身已经内在支持，我们只需要关注如何完成任务即可，在agent程序完毕之后，打开主机监控信息，检查其他监控指标（如内存、磁盘空间、进程等) 确认完成，如右图所示.

## 像编写剧本一样管理资源

   上面提到使用ansible远程执行命令完成agent程序的安装部署, 远程执行命令只是ansible的基本功能，如何让同一类任务可以复用，就像调用程序模块一样拿来即用，ansible也提供了另外一项重要功能: 剧本(Playbook), 一组使用YAML格式语言编写的，可重复执行的任务集合, Playbooks 是使用Ansible的完成配置管理的核心所在，编排好所需任务，就可以控制云主机或者其他资源像演绎剧本中角色一样，完成需要完成的任务，这里的任务包括不局限于，远程执行命令完成部署操作，分发配置文件，重启服务，通过运行自定义脚本，扩展ansible模块，想编写代码一样定义Playbook，可以完成各种复杂的操作。
   将刚才使用远程执行命令完成agent程序的安装部署改为使用playbook方式操作
* 编写install_uma_agent.yaml
```
- name: init uma agent
  hosts: "{{ group }}"
  user: root
  gather_facts: no
  tasks:
  - name: Download uma package
    shell: "wget http://umon.api.service.ucloud.cn/static/umatest/uma-1.1.5-1.x86_64.rpm"
  - name: Install uma package
    shell: "yum localinstall uma-1.1.5-1.x86_64.rpm -y"
  - name: Start uma service
    shell: "service uma start"
```
* 执行install_uma_agent.yaml
```
ansible-playbook install_uma_agent.yaml -e group='web,db,k8s' 
```
  这只是一个简单的例子，playbook可以把一项项命令操作汇聚成一个task，如果执行是更复杂的操作，可能需要执行多个task，那么role特性就适合，role定义了playbook的层次性、结构化地组织，对某一机器操作，只需要定义如何引用role，就可以更轻松的完成更复杂的管理任务,下面我用一系列完整的操作示例，来展示如何借助API和ansible对Ucloud云平台资源进行管理和维护。

## 准备工作


* 创建好需要的云主机

1. 安装软件包 yum install git  -y
2. 获取git clone https://github.com/panhaitao/Playbook-Performance-Test.git 获取
3. cd Playbook-Performance-Test 创建主机配置文件，例如k8s-host-cfg.yaml
```
auth:
  public_key: 'ucloud_pubick_key'
  private_key: 'ucloud_private_key'  #(https://console.ucloud.cn/uapi/apikey 处获得)
rz:
  region: cn-bj2                     
  zone: cn-bj2-02                    #选择地域, 可用区，参考https://docs.ucloud.cn/api/summary/regionlist
  project_id: org-5wakzh             #项目(https://console.ucloud.cn/dashboard 处获得 )
  securitygroupid: firewall-4fntbzvk #选择预设的防火墙ID
os:
  hostname_pre: k8s                  #主机名前缀，批量创建主机会以 k8s-1，k8s-2，k8s-3 ....k8s-N 方式命令
  password: xxxx                     #主机密码
  imageid: uimage-idxxx              #镜像ID   
  type: O                            #主机类型，O 是快杰型，N是普通型号
  cpu: 2                             #CPU核心数
  mem: 2048                          #MEM大小 要设置为1024的倍数
  disk_type: CLOUD_RSSD              #磁盘类型
  disk_size: 20                      #磁盘
  net_capability: Ultra              #网络增强模式
tag: k8s                             #主机分组 
inventory: 
  maxhosts: 6                        #创建主机的数量 
```
更详细可以参考：https://console.ucloud.cn/uapi/detail?id=CreateUHostInstance
4. 执行python3 scripts/create_uhost.py --config k8s-host-cfg.yaml，完成主机的创建，如果需要创建更多的不同类型的主机，可以准备好多份配置文件，批量执行即可，例如:
```
python3 scripts/create_uhost.py --config redis-host-cfg.yaml
python3 scripts/create_uhost.py --config nodejs-host-cfg.yaml
python3 scripts/create_uhost.py --config nginx-host-cfg.yaml
``` 
<img src="https://github.com/panhaitao/SoldierNote/blob/master/static/uhost_with_group_k8s.png"  width="46%"  border="2" hspace="20" ><img src="https://github.com/panhaitao/SoldierNote/blob/master/static/uhost_with_group_web.png" width="46%"  border="2" hspace="20" >
 
* 配置好ansible运行环境

* 安装软件包 yum install ansible -y
* cd Playbook-Performance-Test

创建 inventory/ucloud.ini 文件，写入如下字段：
```
[ucloud]
public_key = ucloud_PublicKey
private_key = ucloud_PrivateKey
base_url = http://api.ucloud.cn/
region = cn-bj2 # 云平台资源所在地域 

[cache]
path = tmp/cache/ansible-ucloud.cache
max_age = 86400

[uhost]
group = all
tag = %(Tag)s
name = %(PrivateIP)s
host = %(PrivateIP)s
ssh_port = 22
ssh_password = Linux主机密码
winrm_port = 5985
winrm_password = Windows主机密码
```

## 测试ansible和其他主机ssh登陆是否正常

* cd Playbook-Performance-Test &&  ansible all -m shell -a 'pwd'

## 场景一: 初始化压测主机

在做压测的时候我们经常需要创建批量的主机，并且用后即还，

1. 进入工作目录 Playbook-Performance-Test 创建jemter 和 nginx server 需要的playbook配置 init_uwsgi_and_jmeter

<img src="https://github.com/panhaitao/SoldierNote/blob/master/static/http_bench_init.png" align="right"  width="40%"  border="2" hspace="20" >

```
- name: set all jmeter bench nodes
  hosts: jmeter-group
  user: root
  gather_facts: yes
  tasks:
    - include_role:
        name: jmeter
      vars:
        group: jmeter-group
        jvm_Xms: "1G"
        jvm_Xmx: "1G"
        jvm_MaxMetaspaceSize: "256m"
        timeout: "6000"
- name: set all uwsgi nodes
  hosts: nginx
  user: root
  gather_facts: yes
  tasks:
    - include_role:
        name: uwsgi
      vars:
        group: nginx
```
<img src="https://github.com/panhaitao/SoldierNote/blob/master/static/http_bench_result.png" align="right"  width="40%"  border="2" hspace="20" >

3. 执行命令完成配置初始化 ansible-playbook init_uwsgi_and_jmeter -D
4. 配置LB，将nginx server 加入vserver
5. 配置好post.jmx 使用ansible控制一台jemter机器开始压测: `cd Playbook-Performance-Test && ansible jmeter-1 -m copy -a "src=post.jmx dest=/tmp/post.jmx"  && ansible jmeter-1 -m script -a 'start_jmeter_task.sh' `

6. post.jmx 可以参考 Playbook-Performance-Test/other/post_example.jmx
7. start_jmeter_task.sh 参考
```
#!/bin/sh
export JAVA_HOME=/home/jdk1.8.0_231
/home/apache-jmeter-5.2.1/bin/jmeter -n -t /tmp/post.jmx -l /data/result/result.jtl -e -o /data/result -R jmeter-1,jmeter-2,jmeter-3,jmeter-4,jmeter-5
```

### 场景二: 批量初始化USMC agent

使用USMC做主机迁移，比如机械的操作是安装USMC agent，如果一次迁移的主机数量比较多，可以借助ansible 来完成批量操作

<img src="https://github.com/panhaitao/SoldierNote/blob/master/static/ansible_install_usmc.png" align="right"  width="40%"  border="2" hspace="20" >

* 服务器迁移中心 USMC → 创建迁移计划，将生成的计划ID usmc-xxxxx 设置为 todo/init_usmc_agent 的usmc_id 值, 将hosts， group 设置要迁移主机所在的业务组名
```
- name: set usmc agent
  hosts: nginx
  user: root
  gather_facts: yes
  tasks:
    - include_role:
        name: usmc
      vars:
        group: nginx
        usmc_id: usmc-jypbmkty
```
* 执行命令 ansible-playbook init_uwsgi_hosts -D 
  完成USMC agent的部署，继续进行迁移计划的其他操作

### 场景三: 启动Promethus/Grafana系统


node_exporter_promethus_grafana.yaml

```
- name: Set all nodes with node_exporter
  hosts: all
  user: root
  gather_facts: yes
  tasks:
    - include_role:
        name: node_exporter
      vars:
        group: all
- name: init grafana server
  hosts: monitor
  user: root
  gather_facts: yes
  tasks:
    - include_role:
        name: grafana
      vars:
        group: monitor
        ucloud_user: 'xxxx'
        ucloud_password: 'xxxxx'
        enable_metrics: true
        docker_version: '19.03.9'
        registry:
          - myhub.com
        grafana_image: uhub.service.ucloud.cn/k8srepo/grafana:7.3.0
        prometheus_image: uhub.service.ucloud.cn/k8srepo/prometheus:v2.22.0
```
3. 执行命令完成配置初始化 ansible-playbook init_uwsgi_and_jmeter -D
4. 登陆grafana 导入面板https://grafana.com/grafana/dashboards/8919

<img src="https://github.com/panhaitao/SoldierNote/blob/master/static/prometheus-example-count-hostgroup.png" width="28%"  border="2" hspace="20" ><img src="https://github.com/panhaitao/SoldierNote/blob/master/static/grafana-example-count-hostgroup.png" width="28%"  border="2" hspace="20" ><img src="https://github.com/panhaitao/SoldierNote/blob/master/static/grafana-example-monitor.png" width="28%"  border="2" hspace="20" >

## 参考资源

1. ansible镜像的Dockerfile:  https://github.com/panhaitao/alpine-ansible.git
2. Playbook配置库: https://github.com/panhaitao/Playbook-Performance-Test.git
3. 使用动态 Inventory: https://github.com/panhaitao/ucloud-ansible-inventory.git
