# 使用ansible 日常巡检

## 准备工作

以管理主机 debian linux 为例, 需要安装　ansible 和　sshpass　两个软件包 执行命令: apt install ansible sshpass -y

## 基础配置

在工作目录下创建配置　ansible.cfg　参考配置项如下：

```
[defaults]

host_key_checking = False　
inventory = hosts

timeout = 30
```
 
在工作目录下创建配置　hosts　　参考配置项如下：　　

```
[ruifei]
11.11.157.157
11.11.157.158

[ruifei:vars]
ansible_connection=ssh
ansible_ssh_user=用户名
ansible_ssh_pass=密码
```


基础操作示例

```
ansible ruifei -m shell -a "uptime; free; mpstat" 　　　　通过ansible  shell 模块执行命令，查看基主机运行状态
ansible ruifei -m script  -a "scripts/check_disk_use.sh"　通过ansible  shell 模块执行脚本，检查磁盘使用率
```

check_disk_use.sh　参考如下：

#!/bin/bash
df -hP|awk 'NR>1 && $5 > 80'

使用playbook 
 

进入工作目录，以管理/etc/sysctl.conf　配置为例,


１．更新sysctl需要root权限，需要在　ansible.cfg　中补充如下配置, 登录远程主机以后将切换root身份执行操作

```
[privilege_escalation]
become=True
become_method=su
become_user=root
become_ask_pass=True
```

２．创建yaml格式的配置文件 sysctl.yaml

```
- name: OS init
  user: root
  hosts: "{{ group }}"
  tasks:
  - name: Update /etc/sysctl.conf
    template: src=sysctl.temp  dest=/etc/sysctl.conf  owner=root group=root mode=0644
  - name: load config
    shell: "sysctl -p"
```

３.   创建配置文件 sysctl.temp 模板文件

```
net.ipv4.tcp_max_orphans = 131072
net.ipv4.tcp_retries2 = 7
net.ipv4.ip_forward = 1
net.netfilter.nf_conntrack_max = 524288
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
kernel.sem = 250    32000   32  1024
fs.inotify.max_user_watches = 1048576
fs.may_detach_mounts = 1
vm.dirty_background_ratio = 5
vm.dirty_ratio = 10
vm.swappiness = 0
```

４．执行playbook 

```
ansible-playbook  sysctl.yaml -e group=ruifei 输入root密码,等待完成操作，返回结果类似如下(本机测试)：
```
