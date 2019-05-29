# Ansible 基础使用指南
　　　
ansible是新出现的自动化运维工具，基于Python开发，集合了众多运维工具（puppet、cfengine、chef、func、fabric）的优点，实现了批量系统配置、批量程序部署、批量运行命令等功能。目前版本实现的功能如下：

* 连接插件connection plugins：负责和被监控端实现通信；
* host inventory：指定操作的主机，是一个配置文件里面定义监控的主机；
* 各种模块核心模块、command模块、自定义模块；
* 借助于插件完成记录日志邮件等功能；
* playbook：剧本执行多个任务时，非必需可以让节点一次性运行多个任务。

相比其他运维管理工具 Ansible有较强的适应性，和独特的优点： 
　　　
* 不需要在被管控主机上安装任何客户端；
* 无服务器端，使用时直接运行命令即可；
* 基于模块工作，可使用任意语言开发模块；
* 使用yaml语言定制剧本playbook；
* 基于SSH工作；
* 可实现多级指挥。    

## Ansible 的安装
    
登陆管控端系统，创建yum配置文件，执行如下命令： 

```
cat > /etc/yum.repo.d/extras.repo << “EOF”
[extras]
Name=deepin extras
baseurl=http://packages.deepin.com/server/amd64/16/extras/x86_64
gpgcheck=0
enable=1
EOF
```
执行命令： yum update && yum install ansible -y 完成软件包的安装

   
## Ansible 的基础配置
　　　
Ansible的一些的设置可以通过配置文件完成.在大多数场景下默认的配置就能满足大多数用户的需求,在一些特殊场景下,用户还是需要自行修改这些配置文件，Ansible 将会按以上顺序逐个查询这些文件,直到找到一个为止,并且使用第一个寻找到个配置文件的配置,这些配置将不会被叠加.他们的被读取的顺序如下:

```
NSIBLE_CONFIG (一个环境变量)
ansible.cfg (位于当前目录中)
ansible.cfg (位于家目录中)
/etc/ansible/ansible.cfg
```

## ansible 的工作方式

Ansible 提供了远程批量执行命令和运行playbook的两种方式用来维护目标服务器。

## Ansible 远程批量执行

ansible命令是用来完成远程批量执行操作，通过Ad-Hoc来完成，能够快速执行，而且不需要保存的一次性操作，例如批量分发文件，批量升级软件包...
　　　
1. 首先需要完成目标是的ssh key登陆的互信操作，参考命令如下：
    ssh-keygen && ssh-copy-id root@server_ip
2. 增加服务器资源修改 /etc/ansible/hosts 添加
```	
[web] 
192.168.1.2 
```
3. 执行ansible命令完成ping 测试： 
    ansible web -m ping -u root
4. 如果全部主机可以访问，将会返回如下结果： 
```
root@deepin-server:~ # ansible web -m ping
192.168.1.2 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
```
5. 上述命令各个参数解析，web是选择的ip分组， -m ping 是调用ansible内置的ping模块，-u root 是指明以root身份执行

6. 其他几个常用的操作参考：
* web分组主机执行w命令(-m command可以省略就表示默认使用命名模块): 
    ansible web -m command -a 'w' 
* 将hosts文件分发到目标主机/etc/hosts
    ansible web -u root -m copy -a "src=hosts dest=/etc/hosts"
* 在目标主机安装当前仓库最新版本的httpd软件包
    ansible web -u root -m yum -a "name=httpd state=latest"
* 在目标主机删除httpd软件包
    ansible web -u root -m yum -a "name=httpd state=absent"
* 在目标主机管理httpd服务器，分别完成启动，停止，重启操作
``` 
ansible web -u root -m service -a "name=httpd state=started"
ansible web -u root -m service -a "name=httpd state=stopped"
ansible web -u root -m service -a "name=httpd state=restarted"
```
* 在目标主机完创建一个名为web新用户
    ansible -u root web -m user -a "name=web password=" 
* 在目标主机删除名为web的用户
    ansible web -u root -m user -a "name=web state=absent"
    
## Ansible 的 playbook 

playbook是一系统ansible命令的集合，使用yaml格式编写，由ansible-playbook命令读取playbook文件，自上而下的顺序依次执行。同时，playbook开创了很多特性,它可以允许你传输某个命令的状态到后面的指令,如你可以从一台机器的文件中抓取内容并附为变量,然后在另一台机器中使用,使得可以实现一些复杂的部署机制。

## 使用Ansible 部署nginx

1.编写一个nginx 软件源配置nginx.repo，用于分发到服务器:
```
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/7/x86_64/
gpgcheck=0
enabled=1
```
2.生成TLS证书，执行命令：

```
openssl req -x509 -nodes -days 3650 -newkey rsa:2048	 -subj /CN=locahost                              -keyout nginx.key -out nginx.cert 
```
3.创建nginx配置模板，保存为nginx.conf.j2，内容如下：

```
 server {
    listen       80;
    listen       443 ssl;

    server_name {{ server_name }};
    ssl_certificate {{ cert_file }};
    ssl_certificate_key {{ key_file }};

    root   /usr/share/nginx/html;
    index  index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }
}
```
4.创建一个用于部署nginx的Playbook，保存为nginx.yaml

```
- name: Configure https webserver with nginx
  hosts: web
  vars:
    key_file: /etc/nginx/nginx.key
    cert_file: /etc/nginx/nginx.cert
    conf_file: /etc/nginx/conf.d/default.conf
    server_name: localhost
  tasks:
    - name: Enabled nginx repo
      copy: src=nginx.repo dest=/etc/yum.repos.d/
    - name: Install Nginx Package
      yum: name=nginx state=latest update_cache=yes

    - name: Copy TLS key
      copy: src=nginx.key dest={{ key_file }}
      notify: restart nginx
    - name: Copy TLS cert
      copy: src=nginx.cert dest={{ cert_file }}
      notify: restart nginx
    - name: Copy nginx config file
      template: src=nginx.conf.j2 dest={{ conf_file }}
      notify: restart nginx

  handlers:
    - name: restart nginx
      service: name=nginx state=restarted
```
5. 执行命令：**ansible-playbook nginx.yml**  最后会返回如下信息：

```
root@deepin-server:~/playbook# ansible-playbook nginx.yaml

PLAY [Configure https webserver with nginx] ************************************

TASK [setup] *******************************************************************
ok: [192.168.1.2]

TASK [Enabled nginx repo] ******************************************************
ok: [192.168.1.2]

TASK [Install Nginx Package] ***************************************************
changed: [192.168.1.2]

TASK [Copy TLS key] ************************************************************
changed: [192.168.1.2]

TASK [Copy TLS cert] ***********************************************************
changed: [192.168.1.2]

TASK [Copy nginx config file] **************************************************
changed: [192.168.1.2]

RUNNING HANDLER [restart nginx] ************************************************
changed: [192.168.1.2]

PLAY RECAP *********************************************************************
192.168.1.2                : ok=7    changed=5    unreachable=0    failed=0
```

6.操作完成后，可以在本机使用firefox访问https://localhost 验证服务是否配置正确。


其他操作参考：

* 检查yaml文件的语法是否正确

    ansible-playbook nginx.yaml --syntax-check
* 检查yaml文件中的tasks任务

    ansible-playbook nginx.yaml --list-task
* 检查yaml文件中的生效主机
    
    ansible-playbook nginx.yaml --list-hosts
* 运行playbook里面特定的某个task,从某个task开始运行

    ansible-playbook nginx.yaml --start-at-task='Copy TLS key'

