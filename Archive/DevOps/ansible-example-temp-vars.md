# playbook 变量

## hostvars: 模板引用hosts变量

* 变量定义: hosts 

```
[lb]
lb1	ansible_ssh_host=172.26.84.97 vip=172.26.84.11

[all:vars]
cha_ip=192.168.8.100
pkg_ip=192.168.8.100

```

* 模板引用: templates/temp.conf

```
{{ cha_ip }}                                         引用cha_ip 变量                   
{{ hostvars[inventory_hostname].vip }}               引用lb1 主机名变量    
{{ hostvars[inventory_hostname].vip }}               引用lb1 主机vip 变量    
{{ hostvars[inventory_hostname].ansible_ssh_host }}  引用lb1 主机ansibe_ssh_host变量
```

## 
