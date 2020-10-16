# ansible应用场景汇总

## 概述

阅读本篇需要对ansible有一定的了解，不熟悉ansible的同学请先阅读 [ansible 基础指南]<https://github.com/panhaitao/SoldierNote/blob/master/Archive/DevOps/ansible-base-howto.md>以下是结合ansible的应用场景

1. 快速准备一个需要的主机
2. 初始化压测主机
  * 初始化nginx/uwsgi 集群
  * 初始化jmeter压测节点
  * 初始化wrk压测节点
  * 初始化ab压测节点
3. 批量配置docker主机
4. 批量初始化USMC agent

## 应用场景

### 场景一: 快速准备需要的主机
1. 创建cube实例，启动一个ansible的运行环境
2. 登陆ucloud控制台 https://console.ucloud.cn/  全部产品 → 容器实例cube，创建容器组
  * cpu 内存 建议配置 4核8G
  * 镜像选择→ uhub镜像 仓库名称 ucloud_pts 镜像名称 alpine-ansible 镜像版本 v1.0 
  * 高阶设置-> 环境变量, name: ROOT_PW  value: 自定义密码 ( 设置cube实例的root密码)       
  * 镜像密钥→ 填入你登陆ucloud平台的用户名和密码
  * 自定义网络→ 选择绑定外网IP，选择需要的付费方式，完成cube实例的创建 
3. 等cube实例启动完毕后，可以使用步骤1.c中定义的root密码ssh登陆容器
4. 第一次使用同步下最新repo,进入 /data/playbook工作目录, 执行命令: git pull
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

## Playbook配置库参考说明

1. ansible镜像的Dockerfile:  https://github.com/panhaitao/alpine-ansible.git
2. Playbook配置库: https://github.com/panhaitao/Playbook-Performance-Test.git
  * example/uhost_type_o.yml 配置文件详细说明
  * example/uhost_type_n.yml 配置文件详细说明
