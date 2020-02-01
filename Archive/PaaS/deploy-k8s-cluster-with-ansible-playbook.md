# 使用ansible-playbook部署k8s集群 

我的上一篇笔记记录了如何使用kubeadm部署一个k8s集群，接下来进一步探索让部署这类的运维工作变得更加自动化，在日常的企业客户运维环境中，我更倾向于使用ansible来完成一次半自动化的部署。


## 准备工作

本文的例子以阿里云测试环境为示例:

1. 准备一个可以运行ansible的环境
2. 准备1台1C1G的虚拟机做负载均衡
3. 准备2台配置不低于机器2C4G的主机，用于运行k8s master
4. 准备3台配置不低于2C4G的主机，用于运行k8s node

关于阿里云如何申请主机以及网络安全组的配置这里不做详细说明，确保申请的主机可以使用ssh登陆即可满足条件,建议申请主机的时候配置好ansible的主机的sshkey认证

## 获取playbook

* 在运行ansible的主机上, `git clone https://github.com/panhaitao/ansible-playbook-store.git`
* 进入 ansible-playbook-store目录按照实际配置修改hosts/k8s-hosts,示例如下：
```
[lb]
lb                      ansible_ssh_host=<lb_host_pub_ip>

[master]
node-01			ansible_ssh_host=<node_pub_ip>
node-02			ansible_ssh_host=<node_pub_ip>
node-03			ansible_ssh_host=<node_pub_ip>

[node]
node-04			ansible_ssh_host=<node_pub_ip>
node-05			ansible_ssh_host=<node_pub_ip>


[all:vars]
ansible_connection=ssh
ansible_ssh_user=root
#ansible_ssh_pass=""
```
替换<lb_host_pub_ip>，<node_pub_ip> 为实际的主机公网ip，如果是内网环境，替换为对应的内网ip即可


* 进入 ansible-playbook-store目录按照实际配置修改 todo/deploy-k8s-cluster.yml，示例如下：
```
- name: set k8s lb
  hosts: all
  user: root
  gather_facts: yes
  tasks:
    - include_role:
        name: haproxy
      vars:
        version: 1.2
        master_group: master
        lb_group: lb
- name: set all k8s nodes
  hosts: all
  user: root
  gather_facts: yes
  tasks:
    - include_role:
        name: common
      vars:
        firewalld: 'disable' 
        swapfs: 'disable'
        ipvs: 'enable'
        ip_forward: 'enable'
        selinux: 'disable'
        update_etc_hosts: 'yes'
        update_etc_hostname: 'yes'
    - include_role:
        name: docker
      vars:
        registry: 127.0.0.1:5000
        version: 19.03.5
        repo: "http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo"
        master_group: master
        node_group: node
    - include_role:
        name: k8s
      vars:
        cluster: init
        master_group: master
        node_group: node
        version: 1.15.6
        pkg_repo: http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
        api_vip: 172.17.142.52
        image_repo: registry.cn-hangzhou.aliyuncs.com/google_containers
        image_flannel: registry.cn-beijing.aliyuncs.com/xz/flannel:v0.11.0-amd64
        domain: cluster.local
        service_subnet: "10.96.0.0/16"
        pod_subnet: "10.10.0.0/16"
        subnet_type: "vxlan"

```
内容有点多, 关键参考配置如下：
1. registry 如果有自己的docker镜像仓库，替换为实际即可
2. 这里docker version:19.03.5 , k8s version:1.15.6 如果你想要测试其他版本，自行选择组合即可 
3. master_group，node_group 要和hosts/k8s-hosts 中定义的一致
4. api_vip 这个是k8s_apiserver_LB, 如果使用了集群提供的LB，填入对应vip即可
5. service_subnet， pod_subnet 分别是k8s 集群的service网段和pod网段，根据实际情况修改保证和主机网络不冲突即可
6. 这里k8s网络插件默认是flannel，以后我可以考虑补充calico，nsx-t等可选的CNI插件

* 进入 ansible-playbook-store目录,执行命令：`ansible-playbook  -i hosts/k8s-hosts todo/deploy-k8s-cluster.yml -D`

如果一切顺利，6～8分钟后，即可部署完一个k8s集群.
