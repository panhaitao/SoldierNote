# Ansible 基础指南

ansible是基于Python开发的运维工具，功能类同其他运维工具: puppet、chef、func、fabric、saltstack. 相比其他运维管理工具,Ansible有较强的适应性，最独特的优点,默认使用ssh协议连接目标host，不需要在目标host安装任何客户端，就可以完成运维管理工作。

## 概述

![Ansible架构图](https://github.com/panhaitao/SoldierNote/edit/master/Archive/DevOps/Ansible-Architecture.png)

* 连接插件默认使用ssh协议,支持zeromq协议
* 基于Python开发,可扩展自定义插件和模块
* 配置库使用yaml格式,支持使用jinjia模版
* 核心模块功能丰富，和大量社区编写的模块可以扩展

## 安装与基础配置

### 安装

* rhel/centos  执行命令： yum install ansible sshpass -y 完成软件包的安装
* debian/ubuntu 执行命令：apt install ansible sshpass -y 完成软件包的安装

### 默认配置 

* 默认的配置          /etc/ansible/ansible.cfg 以下是优先级由高到低生效
  - NSIBLE_CONFIG (环境变量)
  - ansible.cfg (位于当前目录中) 
  - ansible.cfg (位于家目录中)
  - /etc/ansible/ansible.cfg
* 默认的主机清单      /etc/ansible/hosts 执行命令的时候, 可以使用 -i 参数自定义文件路径 
* 默认存放角色的目录  /etc/ansible/roles 

### 组成部分

1. INVENTORY                      ansible管理主机的清单，默认是/etc/ansible/hosts 可以自定义选择主机列表文件
2. modules                        ansible执行命令的模块，多数为内置核心模块，支持自定义编写模块
3. plugins                        模块功能，如连接类型插件，循环插件，变量插件等
4. API                            供第三方程序调用的应用程序编程接口
5. ansible                        执行任务的主程序,下面是常用的主程序及功能
```
* /usr/bin/ansible           执行命令的程序
* /usr/bin/ansible-playbook  执行编排任务集的程序，推送模式
* /usr/bin/ansible-pull      执行编排任务集的程序，拉取模式
* /usr/bin/ansible-vault     文件加密工具
* /usr/bin/ansible-doc       查看配置文档，模块功能查看工具
* /usr/bin/ansible-galaxy    下载/上传优秀代码或roles模块的官网平台
* /usr/bin/ansible-console   基于console界面与用户交互的执行工具
```

## 工作原理与基本使用 

![Ansible原理图](https://github.com/panhaitao/SoldierNote/edit/master/Archive/DevOps/how-ansible-works.png)

Ansible 对基于被管控的设备有两个要求: 支持SSH传输和需要有Python执行引擎, 工作流可分解成如下步骤：

1. 加载配置文件，默认是/etc/ansible/ansible.cfg；
2. 查找对应的inventory文件，找到要任务中选择的主机或者主机组;
3. 加载任务中引用的模块文件，如shell,copy,script 等;
4. 生成对应的临时py文件(python脚本)，并将该文件传输至目标host $HOME/.ansible/tmp/ 目录；
5. 登陆目标host,执行$HOME/.ansible/tmp/XXX/XXX.py文件,执行并返回结果,删除临时py文件, 执行完毕退出；
6. 如果playbook里定义多个任务集，顺次执行, 直到全部执行完毕为止; 遇到失败的任务，会退出，后面的任务不会被执行.

## inventory 文件

Ansible 可同时操作属于一个组的多台主机,组和主机之间的关系通过 inventory 文件配置. 默认的文件路径为 /etc/ansible/hosts 一个典型的inventory 文件如下:

```
[web]
web1  ansible_ssh_host=10.10.33.1  ansible_connection=ssh        ansible_ssh_user=ubuntu ansible_ssh_pass="xxxxxxxxx"
web2  ansible_ssh_host=10.10.33.2  ansible_connection=ssh        ansible_ssh_user=ubuntu ansible_ssh_pass="xxxxxxxxx"
web3  ansible_ssh_host=10.10.33.3  ansible_connection=ssh        ansible_ssh_user=ubuntu ansible_ssh_pass="xxxxxxxxx"
web4  ansible_ssh_host=10.10.33.4  ansible_connection=ssh        ansible_ssh_user=ubuntu ansible_ssh_pass="xxxxxxxxx"

[db]
db1   ansible_ssh_host=10.10.33.5  ansible_connection=ssh        ansible_ssh_user=root ansible_ssh_pass="xxxxxxxxx"
db2   ansible_ssh_host=10.10.33.6  ansible_connection=ssh        ansible_ssh_user=root ansible_ssh_pass="xxxxxxxxx"
```

* 方括号[]中是group名, 以上 INVENTORY 文件定义了两个group，web 和 db 分贝包含了2个host和4个host，
* web1,db2 ... 是host名字，每个host有自己的变量: ansible_ssh_host, ansible_connection, ansible_ssh_user,
* inventory 文件支持组变量，使用 [groupname:vars] 方式定义, 改写后的inventory 文件如下 

```
[web]
web1                ansible_ssh_host=10.10.33.1
web2                ansible_ssh_host=10.10.33.2
web3                ansible_ssh_host=10.10.33.3
web4                ansible_ssh_host=10.10.33.4
[web:vars]
ansible_ssh_pass="xxxxxxxxx"

[db]
db1                 ansible_ssh_host=10.10.33.5
db2                 ansible_ssh_host=10.10.33.6
[db:vars]
ansible_ssh_pass="xxxxxxxxx"

[all:vars]
ansible_connection=ssh
ansible_ssh_user=root
```

更多可参考ansible文档: http://ansible.com.cn/docs/intro_inventory.html

### Ansible 使用示例

1. 使用shell模块执行命令, 在目标主机安装软件包: `ansible -i hosts_file web -u root -m shell -a "yum install nginx -y"`
2. 使用copy模块分发文件,  将nginx.cfg文件分发到web分组: `ansible -i hosts_file web -u root -m copy -a "src=nginx.cfg dest=/etc/nginx/nginx.cfg" `
3. 使用script模块执行操作, 在db分组目标host执行脚本:  `ansible -i hosts_file db -u root -m script -a "run_db.sh"`
4. 使用service模块启动服务, 在所有目标host启动ngixn服务: `ansible -i hosts_file web -u root -m service -a "name=nginx state=restarted"`

### playbook 文件格式

Playbooks 是 Ansible的配置,部署,编排语言.他们可以被描述为一个需要希望远程主机执行命令的方案,或者一组IT程序运行的命令集合.

```
- hosts: web
  remote_user: root
  tasks:
  - name: install packages
    shell: 'yum install nginx -y'
  - name: start service
    shell: 'systemctl restart nginx'
- hosts: db
  remote_user: root
  tasks:
  - name: install packages
    shell: 'yum install mysql -y'
```

playbook是yaml格式, 一个基本的playbook包含主要部分如下:

* hosts        定义选择了要操作的目标hosts
* remote_user  执行任务目标主机的远程用户
* tasks        对于一个操作目标, 可以定义多个任务     

### Ansible-playbook 使用示例

1. 分发文件(使用copy模块)
cp_file.yml
```
- hosts: web
  remote_user: root
  tasks:
  - name: cp file to all remote hosts
    copy: src=files/test.json dest=/home/test.json owner=root mode=0755
```
执行命令对web分组host应用cp_file.yml: `ansible-playbook -i hosts_file cp_file.yml`

2. 执行命令(使用shell模块) 

get_cpu_core_num.yml
```
- hosts: web
  remote_user: root
  tasks:
  - name: get cpu core numbers
    shell: 'nproc'
```
执行命令对web分组host应用get_cpu_core_num.yml : `ansible-playbook -i hosts_file get_cpu_core_num.yml`

3. 分发配置(使用templates模块)

在templates目录创建jinjia模版文件hosts-temp
```
127.0.0.1   localhost localhost4
::1         localhost localhost6

{% for item in groups['all'] %}
{{ hostvars[item].ansible_default_ipv4.address }} {{ item }}
{% endfor %}
```
update_etc_hosts.yml
```
- hosts: all
  remote_user: root
  tasks:
  - name: update /etc/hosts
    template: src=templates/hosts-temp dest=/etc/hosts owner=root group=root mode=0644
```
执行命令对web分组host应用update_etc_hosts.yml : `ansible-playbook -i hosts_file update_etc_hosts.yml`

4. 执行脚本

init_jmeter_worker.yml
```
- hosts: jmeter
  remote_user: root
  tasks:
  - name: run jmeter worker agent
    script: files/run_jemter_work.sh
```
执行命令对jmeter分组host应用init_jmeter_worker.yml : `ansible-playbook -i hosts_file init_jmeter_worker.yml`


## Role 

Roles 是将一些列关联的tasks template hosts 动作的重新组织，提取成一个简洁、可重用的抽象
* 比如部署应用，都要安装，更新配置，启动服务，可以抽取成一个节点操作的role
* 或者初始化一个集群，LB集群, K8S集群，存储集群，可以抽取成一个集群初始化的role 
* 或者某一个可能反复操作的动作，比如集群组件的升级，可以抽取成一个升级操作的role

将Ansible-playbook 示例4个yaml 重新组织成role, 目录结构如下:

* roles/bench_cluster    
* files     目录一半用于存放脚本或者文件
* templates 一般用于存放jinjia模版文件 
* tasks     目录用于存放tasks部分内容, 下面的例子是使用main.yml 引用其他yml文件

```
roles/bench_cluster/
       ├── files
       │   ├── test.json
       │   ├── run_jemter_work.sh
       ├── tasks
       │   ├── main.yml
       │   ├── update_etc_hosts.yml
       │   ├── get_cpu_core_num.yml
       │   ├── cp_file.yml
       │   ├── init_jmeter_worker.yml
       └── templates
           ├── hosts-temp
```

role的使用，编写 init_web_bench_cluster.yml 内容如下:
```
- name: init web bench node
  hosts: all
  user: root
  tasks:
    - include_role:
        name: bench_cluster
```

执行命令`ansible-playbook -i hosts_file init_web_bench_cluster.yml` 就可以引用 bench_cluster role定义的任务集对hosts_file内所有host完成变更。


## 其他操作参考：

* 检查语法是否正确 ansible-playbook task.yml --syntax-check
* 测试执行，确认是否预期的任务: ansible-playbook task.yml -C
* 执行过程将结果以diff方式输出: ansible-playbook task.yml -D
* 检查yaml文件中的tasks任务: ansible-playbook task.yml --list-task
* 检查yaml文件中的生效主机: ansible-playbook task.yml --list-hosts
* 运行playbook里面特定的某个task,从某个task开始运行: ansible-playbook task.yaml --start-at-task='Copy TLS key'

## Ansible 在压测场景中的实践

* 准备好ansible节点，安装ansible git python3 
* 登陆ansible节点，clone一份playbook `git clone https://github.com/panhaitao/ansible-playbook-store.git ` 
  - 上传的GitHub的代码去掉去掉敏感信息，需要补全云主机创建脚本: scripts/create_uhost.py 
  * 填写 public_key private_key 可以登陆 console.ucloud.cn -> 全部产品-> API 产品 查看自己的 API密钥 
  * 修改 Password 改为自己需要设置的密码
  * 修改 创建的主机的配置
  - 根据需要数量，修改inventory文件生成脚本: scripts/create_uhost_ansible_hosts.sh
  * for N in `seq 1 40`  一行定义的一共创建40台主机，编号1-40 根据需要修改
  * 将 ansible_ssh_pass 的值 设置为和 scripts/create_uhost.py 中 Password 定义的一致 
* 批量创建云主机，并自动生成inventory文件,执行命令: cd ansible-playbook-store && scripts/create_uhost_ansible_hosts.sh 

以创建5台云主机为例，执行完毕会生成如下文件 hosts/http_load (这个文件就可以作为ansible后续操作需要的inventory文件)

```
[all]
ab-1                    ansible_ssh_host=10.10.177.95
ab-2                    ansible_ssh_host=10.10.71.215
ab-3                    ansible_ssh_host=10.10.132.202
ab-4                    ansible_ssh_host=10.10.114.52
ab-5                    ansible_ssh_host=10.10.165.159
ops                     ansible_ssh_host=127.0.0.1

[all:vars]
ansible_connection=ssh
ansible_ssh_user=root
ansible_ssh_pass="xxxxxxx"
```

### 批量初始化主机配置

1. 更新主机名
2. 更新/etc/hosts
3. 安装需要的软件包
4. 拷贝测试数据文件到每个节点 
5. 更新jmeter三个配置文件
6. 初始化jmeter agent服务
7. 以及其他你需要的操作

假如要批量创建40台节点，如果不借助工具，你需要一台台登陆操作，使用ansible，写好playbook role 初始化所有压测节点配置只需要执行一条命令:

```
ansible-playbook -i hosts/http_load todo/init_ab_hosts
```

最后检查是否有jemter服务启动失败的节点: ansible -i hosts/http_load all -m shell -a "netstat -nat | grep 1099 " | grep rc=1 | awk '{print $1}' | tr '\n' ',' 如果所有节点服务运行正常，就可以开始做压测了

### jemter 压测

1. 在所有jemter_work 节点准备就绪后
2. 修改当前目下的jmx配置文件
3. 执行脚本run_jmeter.sh 开始压测

### 操作所有节点进行ab压测

编写ab_bench.sh脚本，例如
```
rm -f /tmp/log1
rm -f /tmp/log2
ulimit -n 1000000
nohup ab -p /home/test.json  -T application/json -n 1000000 -c 3000 "https://lb_domain:999/v3/0a1b4118dd954ec3bc/web/pv?stm=xxx" &>> /tmp/log1 &
nohup ab -p /home/test.json  -T application/json -n 1000000 -c 3000 "https://lb_domain:999/v3/0a1b4118dd954ec3bc/web/pv?stm=xxx" &>> /tmp/log2 &

```

* 操作所有节点进行压测: ansible -i hosts/http_load all -m script -a ab_bench.sh
* 操作部分节点进行压测: ansible -i hosts/http_load group_a,group_b -m script -a ab_bench.sh
* 停止所有节点ab进程: ansible -i hosts/http_load all -m shell -a "pkill ab"
