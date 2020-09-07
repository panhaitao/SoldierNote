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

* rhel/centos  执行命令： yum install ansible -y 完成软件包的安装
* debian/ubuntu 执行命令：apt install ansible -y 完成软件包的安装

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

## 工作原理 

![Ansible原理图](https://github.com/panhaitao/SoldierNote/edit/master/Archive/DevOps/how-ansible-works.png)

Ansible 对基于被管控的设备有两个要求: 支持SSH传输和需要有Python执行引擎, 工作流可分解成如下步骤：

1. 加载配置文件，默认是/etc/ansible/ansible.cfg；
2. 查找对应的inventory文件，找到要任务中选择的主机或者主机组;
3. 加载任务中引用的模块文件，如shell,copy,script 等;
4. 生成对应的临时py文件(python脚本)，并将该文件传输至目标host $HOME/.ansible/tmp/ 目录；
5. 登陆执行目标host,执行$HOME/.ansible/tmp/XXX/XXX.py文件,执行并返回结果,删除临时py文件, 执行完毕退出；
6. 如果playbook里定义多个任务集，顺次执行, 直到全部执行完毕为止; 遇到失败的任务，会退出，后面的任务不会被执行.

## inventory 文件

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
ansible_connection=ssh
ansible_ssh_user=root
ansible_ssh_pass="xxxxxxxxx"

[db]
db1                 ansible_ssh_host=10.10.33.5
db2                 ansible_ssh_host=10.10.33.6
[db:vars]
ansible_connection=ssh
ansible_ssh_user=root
ansible_ssh_pass="xxxxxxxxx"
```

更多可参考ansible文档: http://ansible.com.cn/docs/intro_inventory.html

## Ansible 使用示例

1. 使用shell模块执行命令, 在目标主机安装软件包: `ansible -i hosts_file web -u root -m shell -a "yum install nginx -y"`
2. 使用copy模块分发文件,  将nginx.cfg文件分发到web分组: `ansible -i hosts_file web -u root -m copy -a "src=nginx.cfg dest=/etc/nginx/nginx.cfg" `
3. 使用script模块执行操作, 在db分组目标host执行脚本:  `ansible -i hosts_file db -u root -m script -a "run_db.sh"`
4. 使用service模块启动服务, 在所有目标host启动ngixn服务: `ansible -i hosts_file web -u root -m service -a "name=nginx state=restarted"`

## playbook 文件格式

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
playbook是yaml格式, 一个基本的playbook包含如下部分

* hosts        定义选择了要操作的目标hosts
* remote_user  执行任务目标主机的远程用户
* tasks        

## Ansible-playbook 使用示例

playbook, 运维剧本，一次完成

1. 分发文件
2. 执行命令 
3. 分发配置
4. 重启服务

## Role 

```
```

## 其他操作参考：

* 检查yaml文件的语法是否正确 ansible-playbook nginx.yaml --syntax-check
* 检查yaml文件中的tasks任务: ansible-playbook nginx.yaml --list-task
* 检查yaml文件中的生效主机:  ansible-playbook nginx.yaml --list-hosts
* 运行playbook里面特定的某个task,从某个task开始运行: ansible-playbook nginx.yaml --start-at-task='Copy TLS key'

## Ansible 在压测场景中的实践

* 准备好ansible节点，安装ansible git python3 
* 登陆ansible节点，clone一份playbook `git clone https://github.com/panhaitao/ansible-playbook-store.git ` 
  - 根据需要配置, 修改云主机创建脚本: scripts/create_uhost.py 
  - 根据需要数量，修改inventory文件生成脚本: scripts/create_uhost_ansible_hosts.sh
* 批量创建云主机，并自动生成inventory文件,执行命令: cd ansible-playbook-store && scripts/create_uhost_ansible_hosts.sh 


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
