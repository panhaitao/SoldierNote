---
title: 基于docker的容器云解决方案
---

# 容器云解决方案概述


容器服务（service）为用户提供了高性能的容器集群管理方案。支持弹性伸缩、垂直扩容、灰度升级、服务发现、服务编排、错误恢复及性能监测等功能，让企业能够快速部署服务，轻松运维服务。


* 镜像库:    Harbor  
* 网络:      Openvswitch
* 容器引擎： docker
* 编排/调度: kubernetes
* 服务发现 : etcd
* 配置管理： ansible



## ip 命令 

使用ifconfig命令添加一个VIP后，如果需要将这个VIP删除，可以使用ifconfig VIP down命令。

但是，如果操作顺序不当，VIP会仍然留在系统缓存中，这时，使用ifconfig是看不到这个VIP的，但是，使用IP命令能够看到。

查看ip

ip -o -f inet addr show

删除ip
ip -f inet addr delete 10.0.64.102/32  dev tunl0

## Docker Registry Harbor

Harbor 是一个企业级的 Docker Registry，可以实现 images 的私有存储和日志统计权限控制等功能，并支持创建多项目(Harbor 提出的概念)，基于官方 Registry V2 实现。 通过地址：https://github.com/vmware/harbor/releases  可以下载最新的版本。  官方提供了两种版本：在线版和离线版。

安装和配置指南
Harbor 可以通过以下两种方式之一安装：

在线安装程序：安装程序从Docker集线器下载Harbour的映像。因此，安装程序的尺寸非常小。
脱机安装程序：当主机没有Internet连接时，请使用此安装程序。安装程序包含预制图像，因此其大小较大。
本指南介绍使用在线或离线安装程序安装和配置Harbor的步骤。安装过程几乎相同。

如果您运行以前版本的Harbor，则可能需要更新harbor.cfg和迁移数据以适应新的数据库模式。详情请参阅Harbor Migration Guide.。

此外，Kubernetes的部署指导是社区创建的。有关详细信息，请参阅Harbor on Kubernetes 。

目标主机的先决条件

Harbor 部署为几个Docker容器，因此可以部署在任何支持Docker的Linux发行版上。目标主机需要安装Python，Docker和Docker Compose。

Python应该是2.7或更高版本。请注意，您可能必须在Linux发行版（Gentoo，Arch）上安装Python，该版本不附带默认安装的Python解释器（2017.6.9补充：Python3 版本会报错，请用2.7版本）
Docker引擎应为1.10或更高版本。有关安装说明，请参阅：https：//docs.docker.com/engine/installation/
Docker Compose需要为1.6.0或更高版本。有关安装说明，请参阅：https：//docs.docker.com/compose/install/
安装步骤

安装步骤如下

下载安装程序;
配置ports.cfg ;
运行install.sh来安装和启动Harbor;
下载安装程序：

可以从发行页面下载安装程序的二进制文件。选择在线或离线安装程序。使用tar命令来提取包。

在线安装：

    $ tar xvf harbor-online-installer-<version>.tgz
离线安装程序：

    $ tar xvf harbor-offline-installer-<version>.tgz
配置Harbor

配置参数位于文件harbor.cfg中。

在ports.cfg中有两类参数，必需参数和可选参数。

必需参数：需要在配置文件中设置这些参数。如果用户更新它们harbor.cfg并运行install.sh脚本以重新安装Harbor，它们将生效。
可选参数：这些参数是可选的。如果他们 配置到harbor.cfg，他们只能在首次启动Harbor 生效。这些参数的后续更新harbor.cfg将被忽略。海港启动后，用户可以将其留空，并在Web UI上进行更新。注意：如果您选择通过用户界面设置这些参数，请务必在Harbour启动后立即进行。特别地，您必须在注册或创建任何新的用户之前设置所需的auth_mode。当系统中有用户（默认管理员用户除外）时， 无法更改auth_mode。
参数如下所述 – 请注意，至少需要更改hostname属性。

必需参数：

hostname：目标主机的主机名，用于访问UI和注册表服务。它应该是目标机器的IP地址或完全限定域名（FQDN），例如192.168.1.10或reg.yourdomain.com。不要使用localhost或127.0.0.1为主机名 – 注册表服务需要外部客户端访问！
ui_url_protocol：（http或https。默认为http）用于访问UI和令牌/通知服务的协议。如果启用公证，则此参数必须为https。默认情况下，这是http。要设置https协议，请参阅使用HTTPS访问harbor。
db_password：用于db_auth的MySQL数据库的根密码。更改此密码以供任何生产用途！
max_job_workers：（默认值为3）作业服务中的最大复制工作数。对于每个映像复制作业，工作程序将存储库的所有标签同步到远程目标。增加此数字允许系统中更多的并发复制作业。但是，由于每个工作人员都会消耗一定数量的网络/ CPU / IO资源，请根据主机硬件资源选择该属性的值。
customize_crt：（打开或关闭，默认为打开）当此属性打开时，准备脚本将为注册表令牌的生成/验证创建私钥和根证书。当密钥和根证书由外部源提供时，将此属性设置为off。有关详细信息，请参阅自定义密钥和harbor令牌服务证书。
ssl_cert：SSL证书的路径，仅当协议设置为https时才应用
ssl_cert_key：SSL密钥的路径，仅当协议设置为https时才应用
secretkey_path：用于在复制策略中加密或解密远程注册表的密码的密钥路径。
可选参数

电子邮件设置：Harbor需要这些参数才能向用户发送“密码重设”电子邮件，只有在需要该功能时才需要这些参数。另外，请注意，在默认情况下SSL连接时没有启用-如果你的SMTP服务器需要SSL，但不支持STARTTLS，那么你应该通过设置启用SSL email_ssl = TRUE。
email_server = smtp.mydomain.com
email_server_port = 25
email_username = sample_admin@mydomain.com
email_password = abc
email_from = admin sample_admin@mydomain.com
email_ssl = false
harbor_admin_password：管理员的初始密码。该密码仅在Harbor 第一次启动时生效。之后，此设置将被忽略，并且应在UI中设置管理员的密码。请注意，默认用户名/密码为admin / Harbor12345。
auth_mode：使用的身份验证类型。默认情况下，它是db_auth，即凭据存储在数据库中。对于LDAP身份验证，请将其设置为ldap_auth。重要提示：从现有的Harbor 实例升级时，必须确保auth_modeharbor.cfg在启动新版本的Harbor之前是一样的。否则，升级后用户可能无法登录。
ldap_url：LDAP端点URL（例如ldaps://ldap.mydomain.com）。 仅当auth_mode设置为ldap_auth时才使用。
ldap_searchdn：具有搜索LDAP / AD服务器权限的用户的DN（例如uid=admin,ou=people,dc=mydomain,dc=com）。
ldap_search_pwd：由ldap_searchdn指定的用户的密码。
LDAP_BASEDN：基本DN查找用户，如ou=people,dc=mydomain,dc=com。 仅当auth_mode设置为ldap_auth时才使用。
LDAP_FILTER：用于查找用户，例如，搜索过滤器(objectClass=person)。
ldap_uid：用于在LDAP搜索期间匹配用户的属性，它可以是uid，cn，电子邮件或其他属性。
ldap_scope：搜索用户的范围，1-LDAP_SCOPE_BASE，2-LDAP_SCOPE_ONELEVEL，3-LDAP_SCOPE_SUBTREE。默认值为3。
self_registration：（开或关，默认为开）启用/禁用用户注册自己的能力。禁用时，只能由管理员用户创建新用户，只有管理员用户才能在海港创建新用户。 注意：当auth_mode设置为ldap_auth时，自注册功能始终被禁用，并且该标志被忽略。
token_expiration：令牌服务创建的令牌的到期时间（以分钟为单位），默认值为30分钟。
project_creation_restriction：用于控制用户有权创建项目的标志。默认情况下，每个人都可以创建一个项目，设置为“adminonly”，以便只有admin才能创建项目。
verify_remote_cert：（上或关闭，默认为上）该标志，判断是否验证SSL / TLS证书时码头与远程注册表实例通信。将此属性设置为off可绕过SSL / TLS验证，SSL / TLS验证通常在远程实例具有自签名或不受信任的证书时使用。
配置存储后端（可选）

默认情况下，Harbor将映像存储在本地文件系统上。在生产环境中，您可以考虑使用其他存储后端而不是本地文件系统，如S3，Openstack Swift，Ceph等。您需要更新的是storage文件中的部分common/templates/registry/config.yml。例如，如果您使用Openstack Swift作为存储后端，则该部分可能如下所示：

storage:
  swift:
    username: admin
    password: ADMIN_PASS
    authurl: http://keystone_addr:35357/v3/auth
    tenant: admin
    domain: default
    region: regionOne
    container: docker_images
注意：有关注册表的存储后端的详细信息，请参阅registry配置参考。

完成安装和启动港

一旦配置了ports.cfg和存储后端（可选），请使用install.sh脚本安装并启动Harbor 。请注意，在线安装程序可能需要一些时间才能从Docker集线器下载Harbour图像。

默认安装（无公证）

在1.1.0版本之后，Harbor已经与Notary进行了集成，但默认情况下安装不包括公证服务。

    $ sudo ./install.sh
如果一切正常，您应该可以打开一个浏览器，访问http://reg.yourdomain.com的管理员门户（将reg.yourdomain.com更改为您配置的主机名harbor.cfg）。请注意，默认管理员用户名/密码为admin / Harbor12345。

登录管理员门户并创建一个新的项目，例如myproject。然后，您可以使用docker命令登录和推送图像（默认情况下，注册表服务器侦听端口80）：

$ docker login reg.yourdomain.com
$ docker push reg.yourdomain.com/myproject/myrepo:mytag
重要信息： Harbor的默认安装使用HTTP – 因此，您需要将该选项添加--insecure-registry到客户端的Docker守护程序中，然后重新启动Docker服务。

公证人安装

要使用公证服务安装Harbor，请在运行时添加参数install.sh：

    $ sudo ./install.sh --with-notary
注意：对于使用公证人员进行安装，必须将参数ui_url_protocol设置为“https”。配置HTTPS请参考以下章节。

有关Notary和Docker Content Trust的更多信息，请参阅Docker的文档：https://docs.docker.com/engine/security/trust/content_trust/

有关如何使用Harbor 的信息，请参阅Harbor 用户指南。

使用HTTPS访问配置港口

Harbor 不附带任何证书，默认情况下，使用HTTP提供请求。虽然这使得设置和运行相对简单 – 特别是对于开发或测试环境 – 不建议在生产环境中使用。要启用HTTPS，请参阅使用HTTPS访问配置Harbor 。

管理港口的生命周期

您可以使用docker-compose来管理Harbor的生命周期。一些有用的命令如下所列（必须与docker -compose.yml在同一目录中运行）。

停止Harbor ：

$ sudo docker-compose stop
Stopping nginx ... done
Stopping harbor-jobservice ... done
Stopping harbor-ui ... done
Stopping harbor-db ... done
Stopping registry ... done
Stopping harbor-log ... done
停车后重新启动Harbor ：

$ sudo docker-compose start
Starting log ... done
Starting ui ... done
Starting mysql ... done
Starting jobservice ... done
Starting registry ... done
Starting proxy ... done
要更改Harbor的配置，请首先停止现有的Harbor实例并进行更新harbor.cfg。然后运行prepare脚本来填充配置。最后重新创建并启动Harbor的实例：

$ sudo docker-compose down -v
$ vim harbor.cfg
$ sudo prepare
$ sudo docker-compose up -d
删除Harbor 的容器，同时保留图像数据和Harbor的数据库文件在文件系统上：

$ sudo docker-compose down -v
删除Harbor 的数据库和图像数据（为了干净的重新安装）：

$ rm -r / data / database
$ rm -r / data / registry
管理港湾的安全生产周期

当Harbor 与Notary安装时，docker docker-compose.notary.yml-compose命令需要一个额外的模板文件。用于管理Harbor 生命周期的码头组合命令是：

$ sudo docker-compose -f ./docker-compose.yml -f ./docker-compose.notary.yml [ up|down|ps|stop|start ]
例如，如果要在配有Notary的情况下更改配置harbor.cfg并重新部署Harbor，则应使用以下命令：

$ sudo docker-compose -f ./docker-compose.yml -f ./docker-compose.notary.yml down -v
$ vim harbor.cfg
$ sudo准备 - 公证
$ sudo docker-compose -f ./docker-compose.yml -f ./docker-compose.notary.yml up -d
有关docker-compose的更多信息，请查看Docker Compose命令行参考。

持久性数据和日志文件

默认情况下，注册表数据将保留在主机的/data/目录中。即使拆除和/或重建Harbor 的集装箱，这些数据也保持不变。

另外，Harbor使用rsyslog收集每个容器的日志。默认情况下，这些日志文件存储在/var/log/harbor/目标主机上的目录中进行故障排除。

配置在自定义端口上监听港口

默认情况下，对于admin portal和docker命令，Harbor将在端口80（HTTP）和443（如果已配置HTTPS）上进行监听，则可以使用自定义方式进行配置。

对于HTTP协议

1.修改docker-compose.yml
将第一个“80”替换为自定义的端口，例如8888：80。

proxy:
    image: library/nginx:1.11.5
    restart: always
    volumes:
      - ./config/nginx:/etc/nginx
    ports:
      - 8888:80
      - 443:443
    depends_on:
      - mysql
      - registry
      - ui
      - log
    logging:
      driver: "syslog"
      options:  
        syslog-address: "tcp://127.0.0.1:1514"
        tag: "proxy"
2.修改ports.cfg，将端口添加到参数“hostname”

hostname = 192.168.0.2:8888
3.重新部署港口参考上一节“管理Harbor 的生命周期”。

对于HTTPS协议

按照本指南，启用Harbor 中的HTTPS 。
2.修改docker-compose.yml
将第一个“443”替换为自定义的端口，例如8888：443。

proxy:
    image: library/nginx:1.11.5
    restart: always
    volumes:
      - ./config/nginx:/etc/nginx
    ports:
      - 80:80
      - 8888:443
    depends_on:
      - mysql
      - registry
      - ui
      - log
    logging:
      driver: "syslog"
      options:  
        syslog-address: "tcp://127.0.0.1:1514"
        tag: "proxy"
3.修改ports.cfg，将端口添加到参数“hostname”

hostname = 192.168.0.2:8888
4.重新部署Harbor 参考上一节“管理Harbor 的生命周期”。

故障排除

当Harbour不能正常工作时，请运行以下命令，查看Harbor的所有容器是否处于UP状态：
    $ sudo docker-compose ps
        Name                     Command               State                    Ports                   
  -----------------------------------------------------------------------------------------------------
  harbor-db           docker-entrypoint.sh mysqld      Up      3306/tcp                                 
  harbor-jobservice   /harbor/harbor_jobservice        Up                                               
  harbor-log          /bin/sh -c crond && rsyslo ...   Up      127.0.0.1:1514->514/tcp                    
  harbor-ui           /harbor/harbor_ui                Up                                               
  nginx               nginx -g daemon off;             Up      0.0.0.0:443->443/tcp, 0.0.0.0:80->80/tcp 
  registry            /entrypoint.sh serve /etc/ ...   Up      5000/tcp                                 
如果容器未处于UP状态，请检查目录中该容器的日志文件/var/log/harbor。例如，如果容器harbor-ui没有运行，则应该查看日志文件ui.log。

2，当设置Harbor 后面的nginx的代理或弹性负载均衡，寻找线下，在common/templates/nginx/nginx.http.conf从部分删除它，如果代理已经有类似的设置：location /，location /v2/和location /service/。

proxy_set_header X-Forwarded-Proto $scheme;
并重新部署Harbor 参考上一节“管理Harbor 的生命周期”。

## docker run with openvswitch signal host

Step-by-step
Install OVS and ovs-docker utility

root@docker:~# apt-get -y install openvswitch-switch
root@docker:~# cd /usr/bin
root@docker:/usr/bin# wget https://raw.githubusercontent.com/openvswitch/ovs/master/utilities/ovs-docker
root@docker:/usr/bin# chmod a+rwx ovs-docker
Create the OVS bridge

root@docker:/usr/bin# ovs-vsctl add-br ovs-br1
root@docker:/usr/bin# ovs-vsctl show
8ea008e7-7ccf-4dbd-8a24-db092221ece4
 Bridge "ovs-br1"
 Port "ovs-br1"
 Interface "ovs-br1"
 type: internal
 ovs_version: "2.5.0"
root@docker:/usr/bin# 
Connect the containers to OVS bridge

There are two modes: NAT and bridge. The NAT mode means the ovs bridge is a virtual interface, the docker containers added to the ovs bridge will have an internal ip address, iptables NAT rules will be needed to communicate with outside world.The bridge mode means the ovs bridge is associated with a real network adapter, the docker containers added to the ovs bridge will be bridged to the external network.

### NAT mode
Configure an internal ip address on the ovs bridge
root@docker:~# ifconfig ovs-br1 192.168.0.1 netmask 255.255.0.0 up
Creat two ubuntu Docker Containers without network
root@docker:/usr/bin# docker run -d --name=container1 --net=none liguangcheng/ubuntu-16.04-ppc64el
1480c5e2d42770682191a6940bc23367cee09ff4b22598410e70646679cc4658
root@docker:/usr/bin# docker run -d --name=container2 --net=none liguangcheng/ubuntu-16.04-ppc64el
d771b9209046874c547d83f49b05cf6a146af50c44f8c84f072b10ec48b5d81d
root@docker:/usr/bin#
Connect the container to OVS bridge
root@docker:/usr/bin# ovs-docker add-port ovs-br1 eth0 container1 --ipaddress=192.168.1.1/16 --gateway=192.168.0.1
root@docker:/usr/bin# ovs-docker add-port ovs-br1 eth0 container2 --ipaddress=192.168.1.2/16 --gateway=192.168.0.1
Add NAT rules
root@docker:~# export pubintf=enp0s1
root@docker:~# export privateintf=ovs-br1
root@docker:~# iptables -t nat -A POSTROUTING -o $pubintf -j MASQUERADE
root@docker:~# iptables -A FORWARD -i $privateintf -j ACCEPT
root@docker:~# iptables -A FORWARD -i $privateintf -o $pubintf -m state --state RELATED,ESTABLISHED -j ACCEPT
Test the connection between two containers connected via OVS bridge using Ping command

### Bridge mode

Add the physical network adapter into the ovs bridge, and configure an external ip address onto the ovs bridge
root@docker:~# ovs-vsctl add-port ovs-br1 enp0s1
root@docker:~# ifconfig ovs-br1 10.0.189.102 netmask 255.255.0.0 up
Creat two ubuntu Docker Containers without network
root@docker:/usr/bin# docker run -d --name=container1 --net=none liguangcheng/ubuntu-16.04-ppc64el
1480c5e2d42770682191a6940bc23367cee09ff4b22598410e70646679cc4658
root@docker:/usr/bin# docker run -d --name=container2 --net=none liguangcheng/ubuntu-16.04-ppc64el
d771b9209046874c547d83f49b05cf6a146af50c44f8c84f072b10ec48b5d81d
root@docker:/usr/bin#
Connect the container to OVS bridge
root@docker:/usr/bin# ovs-docker add-port ovs-br1 eth0 container1 --ipaddress=10.0.190.1/16
root@docker:/usr/bin# ovs-docker add-port ovs-br1 eth0 container2 --ipaddress=10.0.190.2/16 
Test the connection between two containers connected via OVS bridge using Ping command





另外，删除该接口的命令为

$ sudo. /ovs-docker del-port br0 eth0 <CONTAINER_ID>




### 参考文档

* https://pve.proxmox.com/wiki/Open_vSwitch

### 其他博客 

* http://blog.csdn.net/linlinv3/article/details/50373511
* https://developer.ibm.com/recipes/tutorials/using-ovs-bridge-for-docker-networking/
* http://fishcried.com/2016-02-09/openvswitch-ops-guide/
* http://www.rendoumi.com/linuxxia-bridgehe-ovsyi-ji-dockerde-hun-he-ying-yong/
* [Docker+OpenvSwitch搭建VxLAN实验环境](http://www.cnblogs.com/yuuyuu/p/5180827.html)
* https://www.xtplayer.cn/2017/05/2857



* Kubernetes     入门    : http://www.cnblogs.com/suolu/p/6734528.html
* Kubernetes     组件原理： http://www.cnblogs.com/suolu/p/6771627.html
* Kubelet运行机制与安全机制： http://www.cnblogs.com/suolu/p/6841848.html
* Kubernetes     网络原理： http://www.cnblogs.com/suolu/p/6842771.html
* Kubernetes     运维技巧： http://www.cnblogs.com/suolu/p/6844414.html
