# AKE-V1部署K8S高可用集群-1.9

#### 环境准备

```
1. 下载镜像模板及安装包
centos7.4-k8s镜像模板（qcow2）
链接：https://pan.baidu.com/s/1tNHWMKFGdpd13TdIqFSXAQ 密码：alz6

AKE容器集群安装包
链接：https://pan.baidu.com/s/1_JTV4HgMuTCuRIGwSonyHg 密码：2mdg

2. 根据centos7.4-k8s镜像模板创建云主机
LB角色主机开通在不同的IaaS物理机上，master、node角色主机也同理

3. 关闭IaaS已创建云主机的安全组，保证节点间网络畅通（举例：关闭10.110.49.50-60云主机安全组策略）
. openrc
for i in `seq 50 60`; do neutron port-update port_id --allowed-address-pairs type=dict list=true ip_address=0.0.0.0/0 `neutron port-list | grep 10.110.49.$i | awk '{print $2}'`; done

4. 需要有内网centos7.4 yum源
云环境准备yum源（centos7.4）安装haproxy、keepalived、lvm2等

5. 云环境准备NTP服务器
```

**k8s集群相关**

AKE节点可以单独部署在一台主机，也可以部署在集群中，本次安装在集群内部，需提前部署LB。

创建完主机，优先看下时间是否同步

|   主机系统    |      主机角色       |     主机IP      |   主机名   |    系统配置    | 添加数据盘（100G) | 日志盘     |
| :-------: | :-------------: | :-----------: | :-----: | :--------: | :---------: | ------- |
| Centos7.4 | master/etcd/ake | 20.20.104.133 | master1 | 16C32G100G |     vdb     |         |
| Centos7.4 |   master/etcd   | 20.20.104.134 | master2 | 16C32G100G |     vdb     |         |
| Centos7.4 |   master/etcd   | 20.20.104.135 | master3 | 16C32G100G |     vdb     |         |
| Centos7.4 |      node       | 20.20.104.136 |  node1  | 32C64G100G |     vdb     | vdc(1T) |
| Centos7.4 |      node       | 20.20.104.137 |  node2  | 32C64G100G |     vdb     |         |
| Centos7.4 |      node       | 20.20.104.138 |  node3  | 32C64G100G |     vdb     |         |



**LB相关**

创建三台主机，然后关闭LB-VIP，占用IP做VIP用

|   主机系统    |  主机角色  |     主机IP      |  主机名   |   系统配置    |
| :-------: | :----: | :-----------: | :----: | :-------: |
| Centos7.4 |   LB   | 20.20.104.139 |  Lb-1  | 8C16G100G |
| Centos7.4 |   LB   | 20.20.104.140 |  Lb-2  | 8C16G100G |
| Centos7.4 | LB-VIP | 20.20.104.141 | LB-VIP | 8C16G100G |



---



#### 安装LB

如果客户提供LB请跳过，没有的话请安装【两台LB都需要操作 】

1. 安装haproxy( 提前准备好yum源  )

```
yum -y installl haproxy keepalived
```

2. 修改/etc/haproxy/haproxy.cfg 

```
defaults
    mode                    tcp					# 改为tcp
    log                     global
    option                  tcplog				# 改为tcplog
```

添加如下内容，监控三个master的6443端口【两台LB都需要操作】

```
defaults
    mode                    tcp
    log                     global
    option                  tcplog
   

frontend        k8s_https       *:6443
    mode        tcp
    maxconn     2000
    default_backend     https_sri

backend         https_sri
    balance     roundrobin
    server      s1      20.20.104.133:6443 check inter 10000 fall 3 rise 3 weight 1
    server      s2      20.20.104.134:6443 check inter 10000 fall 3 rise 3 weight 1
    server      s3      20.20.104.135:6443 check inter 10000 fall 3 rise 3 weight 1		
```

有已经写好的配置文件，改下IP复制也OK.【文件位置/root/mini-alauda/haproxy/】

```
cp haproxy.cfg /etc/haproxy/haproxy.cfg
```

3. 修改/etc/keepalived/keepalived.cfg修改如下配置

```
! Configuration File for keepalived

global_defs {
   notification_email {
     acassen@firewall.loc
     failover@firewall.loc
     sysadmin@firewall.loc
   }
   notification_email_from Alexandre.Cassen@firewall.loc
   smtp_server 192.168.200.1
   smtp_connect_timeout 30
   router_id LVS_DEVEL
   vrrp_skip_check_adv_addr
   vrrp_strict
   vrrp_garp_interval 0
   vrrp_gna_interval 0
}

vrrp_script chk_haproxy {								#  被监控的服务名称
        script "/etc/keepalived/check_haproxy.sh"	    
        interval 2
        weight 2
}

vrrp_instance VI_1 {
    state MASTER				# 另外一个改为BACKUP
    interface eth0
    virtual_router_id 51
    priority 100				# 另外一个改为50
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    track_script {
        chk_haproxy  # 执行监控的服务
    }
    virtual_ipaddress {
        20.20.104.141/24  # 漂移VIP地址
    }
}
```

有已经写好的配置文件，改下IP复制也OK.【文件位置/root/mini-alauda/keepalived/】

```
cp /root/mini-alauda/keepalived/keepalived.cfg /etc/keepalived/
```

4. 编写/etc/keepalived/check_haproxy.sh脚本

```
#!/bin/bash
if [ $(ps -C haproxy --no-header | wc -l) -eq 0 ]; then
	systemctl start haproxy
fi
```

有已经写好的配置文件【文件位置/root/mini-alauda/keepalived/】

```
cp /root/mini-alauda/keepalived/check_haproxy.sh /etc/keepalived/ && chmod +x /etc/keepalived/check_haproxy.sh
```

5. 启动并查看状态( 先启动keepalived	master然后backup )

```
systemctl start keepalived && systemctl enable keepalived && systemctl status keepalived 
```

```
systemctl start haproxy && systemctl enable haproxy && systemctl status haproxy
```

6. 关闭iaas的安全组命令如下【在他们的跳板机上操作，如果不知道地址，直接问他们的员工】

   host-gw模式和LB的VIP需要iaas层的支持

```
. openrc
```

```
for i in `seq 133 140`; do neutron port-update --port_security_enabled=false --no-security-groups --no-allowed-address-pairs `neutron port-list | grep 20.20.104.$i | awk '{print $2}'`; done
```

或者

```
for i in `seq 50 60`; do neutron port-update port_id --allowed-address-pairs type=dict list=true ip_address=0.0.0.0/0 `neutron port-list | grep 10.110.49.$i | awk '{print $2}'`; done
```



---



#### 安装集群

1. 确认主机名是否于显示主机名一致( 关于主机名，ake暂时不支持    .   这边创建主机默认会在后面加一些后缀 )

```
hostname 
```

如果不一致请修改【所有主机】

```
hostnamectl --static set-hostname 主机名
```

2. 确认是否挂上硬盘【所有主机】

```
lsblk
```

3. 添加hosts【所有主机上添加 /etc/hosts】

```
20.20.104.133	master1
20.20.104.134	master2
20.20.104.135	master3
20.20.104.136	node1
20.20.104.137	node2
20.20.104.138	node3
```

4. 免密要登录(  在ake的主机上操作  )

```
ssh-keyget -t rsa														
```

```
for i in `cat /etc/hosts | awk 'NR>2{print $2}'`;do ssh-copy-id -i /root/.ssh/id_rsa.pub $i; done
```

5. 解压mini-k8s.tar(  在ake的主机上操作  )

```
tar xvf mini-k8s.tar
```

6. 进入到解压的目录内(  在ake的主机上操作  )

```
cd mini-alauda
```

7. 执行脚本lvm.sh(  所有主机都需要操作,如果硬盘不叫vdb ,修改lvm.sh中的名字 )

```   
for i in `cat /etc/hosts | awk 'NR>2{print $2}'`;do scp /root/mini-alauda/lvm.sh $i:/root; done 									
```

```
for i in `cat /etc/hosts | awk 'NR>2{print $2}'`;do ssh $i bash /root/lvm.sh; done 
```

8. 清空/etc/yum.repo/目录(  所有节点都需要操作,需要备份就备份,不需要就删掉  )

```
for i in `cat /etc/hosts | awk 'NR>2{print $2}'`;do ssh $i rm -rf /etc/yum.repos.d/*; done
```

9. 修改/root/mini-alauda/damon.json文件并执行(  镜像仓库地址改成安装ake的ip地址 ,在ake的主机上操作 )

```
{
    "insecure-registries": [
        "20.20.104.133:60080",			# 修改为AKE所在主机的ip地址
        ""								# 这个位置是留给他们的仓库地址，提前确认下
    ],
    "storage-driver": "devicemapper",
    "storage-opts": [
        "dm.thinpooldev=/dev/mapper/docker-thinpool",
        "dm.min_free_space=0%",
        "dm.use_deferred_deletion=true",
        "dm.use_deferred_removal=true",
        "dm.fs=ext4"
    ],
    "log-driver": "json-file",
    "log-opts": {
      "max-size": "20m",
      "max-file": "10"
    },
    "hosts": [
	"unix:///var/run/docker.sock"
    ],
    "graph": ""
}
```

```
bash /root/mini-alauda/up-mini-alauda.sh -osd --network-interface=eth0 --dockercfg=/root/mini-alauda/daemon.json
```

10. 上一步结束，看到成功提示，查看容器是否启动(  正常情况下会启动2个容器  )

```
docker ps -a	
```

11. 安装kubernetes高可用集群【多个节点之间以;号隔开如果对参数有疑惑请查看下参数描述】

```                         
./ake deploy \
--dockercfg=/root/mini-alauda/daemon.json \
--network-opt="backend_type=host-gw"      \
--network-interface=eth0                  \
--network-opt="cidr=10.222.0.0/16"        \
--ssh-username=root --ssh-key-path="/root/.ssh/id_rsa" \
--pkg_repo="http://20.20.104.133:7000"                 \
--registry="20.20.104.133:60080"                       \
--masters="20.20.104.133(user=root,ssh_private_key_file=/root/.ssh/id_rsa);20.20.104.134(user=root,ssh_private_key_file=/root/.ssh/id_rsa);20.20.104.135(user=root,ssh_private_key_file=/root/.ssh/id_rsa)" \
--etcds="20.20.104.133(user=root,ssh_private_key_file=/root/.ssh/id_rsa);20.20.104.134(user=root,ssh_private_key_file=/root/.ssh/id_rsa);20.20.104.135(user=root,ssh_private_key_file=/root/.ssh/id_rsa)" \
--nodes="20.20.104.136(user=root,ssh_private_key_file=/root/.ssh/id_rsa);20.20.104.137(user=root,ssh_private_key_file=/root/.ssh/id_rsa);20.20.104.138(user=root,ssh_private_key_file=/root/.ssh/id_rsa)" \
--kube_apiserver_advertise_address=20.20.104.141 --debug				
```

12. 集群部署完毕

```Python
kubectl get nodes -o wide
```

13. 确认下k8s集群节点的时间是否同步( 安装ntp服务，需要yum源，所有节点)

    1. 配置本地yum源( local.repo )然后传到所有节点

       ```
       for i in `cat /etc/hosts | awk 'NR>2{print $2}'`; do scp /etc/yum.repos.d/local.repo root@$i:/etc/yum.repos.d/ ; done
       ```

    2. 卸载ntpdate

       ```
       for i in `cat /etc/hosts | awk 'NR>2{print $2}'`; do ssh $i yum -y remove ntpdate ;done
       ```

    3. 安装ntp

       ```
       for i in `cat /etc/hosts | awk 'NR>2{print $2}'`; do ssh $i yum -y install ntp ;done
       ```

    4. 复制ntp.conf文件

       ```
       cp /etc/ntp.conf /etc/ntp.conf.bak && echo '' > /etc/ntp.conf
       ```

    5. vim /etc/ntp.conf (输入内容如下)

       ```
       driftfile /var/lib/ntp/drift

       restrict default nomodify notrap nopeer noquery

       restrict 127.0.0.1 

       restrict ::1

       includefile /etc/ntp/crypto/pw

       keys /etc/ntp/keys

       disable monitor

       server 30.20.110.2 burst iburst prefer		# 指定的ntp服务器ip，IP地址由他们提供
       ```

    6. 传送到其他节点

       ```
       for i in `cat /etc/hosts | awk 'NR>2{print $2}'`; do scp /etc/ntp.conf $i:/etc/; done
       ```

    7. 启动和验证服务

       ```
       for i in `cat /etc/hosts | awk 'NR>2{print $2}'`; do ssh $i systemctl enable ntpd ;done
       ```

       ```
       for i in `cat /etc/hosts | awk 'NR>2{print $2}'`; do ssh $i systemctl start ntpd ;done
       ```

       ```
       for i in `cat /etc/hosts | awk 'NR>2{print $2}'`; do ssh $i ntpq -p ;done
       ```

       ```
       for i in `cat /etc/hosts | awk 'NR>2{print $2}'`; do ssh $i date ;done
       ```

#### 参数描述

具体的参数说明以及其他相关参数，可以运行```man ake```查看。参考查看帮助文档。

|                参数                |                  描述                  |
| :------------------------------: | :----------------------------------: |
|              deploy              |            部署kubernetes集群            |
|           network-opt            |          选择网络的类型。例如：flannel          |
|           Backend_type           | 选择flannel的backend的类型，支持vxlan和host-gw |
|               cidr               |            K8s pod的CIDR。             |
|             masters              |          master节点，多个节点用;号隔开          |
|              etcds               |           etcd节点，多个节点用;号隔开           |
|               node               |           work节点，多个节点用;号隔开           |
|           ssh-username           |                登录机器的                 |
|           ssh-password           |   登录机器的username的密码。密码需要用双引号("")扩起来   |
| kube_apiserver_advertise_address |      LB的IP【因为LB做了高可用这里写LB的VIP】       |



---



#### 提升权限

1. 因需要和云操对接，需要对default和kube-system两个ns提升权限，命令如下

```
kubectl edit clusterrolebinding cluster-admin # 在subjects字段下加入
subjects:
- kind: ServiceAccount
  name: default
  namespace: default
- kind: ServiceAccount
  name: default
  namespace: kube-system       				  # 保存退出
```

2. 申请一个1T的硬盘挂载到node节点(我挂到了**node1**上)格式成**ext4**

```
mkfs.ext4 /dev/vdc
```

3. mount到/root/tenxcloud

```
mkdir /root/tenxcloud 
mount /dev/vdc /root/tenxcloud
```

4. 写入/etc/fstab

```
/dev/vdc	/root/tenxcloud		ext4	default		0 0
```

或写到/etc/rc.local

```
mount /dev/vdc	/root/tenxcloud	
```

---



#### 系统优化

```
系统用户登录密码要求：大写+小写+数字+特殊字符 11位以上


调整时区校正时间
ln -sf  /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate time.nist.gov
hwclock -w


优化系统最大进程数与最大文件打开数限制
echo "modprobe br_netfilter" >>/etc/rc.local
echo "modprobe nf_conntrack" >>/etc/rc.local


cat <<EOF >>/etc/security/limits.conf
* soft nofile 819200
* hard nofile 819200
* soft noproc 819200
* hard noproc 819200
EOF
ulimit -a

cat <<EOF >> /etc/sysctl.conf
net.ipv4.tcp_max_orphans = 131072
net.netfilter.nf_conntrack_max = 524288
net.ipv4.tcp_retries2 = 8
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
kernel.sem = 250            32000    32         1024
fs.inotify.max_user_watches = 1048576
fs.may_detach_mounts = 1
vm.dirty_background_ratio = 5
vm.dirty_ratio = 10
vm.swappiness = 0
EOF
sysctl -p


增加系统事件监控数量
sysctl fs.inotify.max_user_watches=1048576


关闭无用服务
systemctl stop snmpd
systemctl disable snmpd
systemctl stop sendmail
systemctl disable sendmail
systemctl stop firewalld
systemctl disable firewalld
systemctl stop postfix
systemctl disable postfix


禁止操作系统存在sync、shutdown、halt默认账户登录
chsh sync -s /sbin/nologin
chsh shutdown -s /sbin/nologin
chsh halt -s /sbin/nologin


限定密码复杂度和有效时间
sed  -i '/PASS_MAX_DAYS/s/99999/200/g' /etc/login.defs
sed  -i '/PASS_MIN_DAYS/s/0/180/g' /etc/login.defs
sed  -i '/PASS_MIN_LEN/s/5/8/g' /etc/login.defs


增加登录超时时间
echo "export TMOUT=3600" >> /etc/profile

source /etc/profile


确认日志服务已启动
systemctl restart rsyslog && systemctl enable rsyslog


加固k8s组件服务
systemctl start kubelet && systemctl enable kubelet
systemctl start docker && systemctl enable docker
echo "* * * * * root systemctl start docker" >> /etc/crontab
echo "* * * * * root sleep 30 && systemctl start docker" >> /etc/crontab
echo "* * * * * root systemctl start kubelet" >> /etc/crontab
echo "* * * * * root sleep 30 && systemctl start kubelet" >> /etc/crontab
```



---



#### 部署完毕

1. 在部署好的集群中添加node节点

```
kubeadm token list
```

```
./ake addnodes --apiserver VIP:6443 --nodes node-ip --dockercfg=/root/mini-alauda/daemon.json --ssh-username root --ssh-key-path="/root/.ssh/id_rsa" --token token --pkg_repo="http://20.20.104.133:7000" --registry="20.20.104.133:60080"  --debug
```

2. 在部署好的集群中添加master节点**(在上一步基础上)**

   > 在master节点把admin.conf复制到新加入的node节点

```
scp /etc/kubernetes/admin.conf master-ip:/etc/kubernetes/
```

 ```
kubeadm alpha phase mark-master		#在新加入的节点执行命令
 ```

```
kubectl edit nodes master-ip	#把lables中关于node的标签删除,添加节点完成
```

3. 清除集群( 部署过程中如果部署失败，请使用如下脚本清空集群 )

``` Python 
bash cleanup.sh
```

 

----





#### 添加解析

1. 创建一个文件: kube-dns.yaml

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-dns
  namespace: kube-system
data:
  upstreamNameservers: |
    ["10.111.202.93"]
```

```
kubectl create -f kube-dns.yaml
```







