# import_tasks 和include_tasks 的区别

区别一

* import_tasks(Static)方法会在playbooks解析阶段将父task变量和子task变量全部读取并加载
* include_tasks(Dynamic)方法则是在执行play之前才会加载自己变量

区别二 

* include_tasks方法调用的文件名称可以加变量
* import_tasks方法调用的文件名称不可以有变量 

参考链接

* https://docs.ansible.com/ansible/2.5/user_guide/playbooks_reuse.html#differences-between-static-and-dynamic
* https://docs.ansible.com/ansible/2.5/user_guide/playbooks_conditionals.html#applying-when-to-roles-imports-and-includes

## 使用sudo

１．更新sysctl需要root权限，需要在　ansible.cfg　中补充如下配置, 登录远程主机以后将切换root身份执行操作

```
[privilege_escalation]
become=True
become_method=su
become_user=root
become_ask_pass=True
```
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
