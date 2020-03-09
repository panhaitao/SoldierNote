# kolla-ansible部署openstack的all-in-one环境（stein版）

## 系统准备

需要准备一台主机，一个运行ansible的ops主机，一台运行openstack的主机

openstack的节点主机:

  * 4C cpu cores
  * 8GB main memory
  * 40GB disk space
  * 2 network interfaces

## 初始化openstack节点
 
1. 关闭selinux      vi /etc/selinux/config SELINUX=disabled
2. 关闭防火墙       systemctl stop firewalld;systemctl disable firewalld
3. 关闭libvirtd服务 systemctl stop libvirtd.service; systemctl disable libvirtd.service
4. 安装docker
```        
* CentOS: 
    curl -o /etc/yum.repos.d/docker-ce.repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    yum makecache; yum install docker-ce -y 
* Debian: 
    echo "deb [arch=amd64] https://download.docker.com/linux/debian buster stable" >> /etc/apt/sources.list
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    apt update && apt install docker-ce docker-ce-cli containerd.io -y
```
6. 配置挂载共享,添加私有仓库
```
mkdir /etc/systemd/system/docker.service.d
tee /etc/systemd/system/docker.service.d/kolla.conf <<-'EOF'
[Service]
MountFlags=shared
EOF

mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "insecure-registries": [ "registry.cn-beijing.aliyuncs.com" ]
}
EOF

systemctl enable docker.service
systemctl restart docker.service
```
7. 节点主机网卡配置:
```
/etc/network/interfaces
auto eth0
iface eth0 inet static
        address 192.0.2.2
        netmask 255.255.255.0
        network 192.0.2.0
        broadcast 192.0.2.255
        gateway 192.0.2.1
# Bring up eth1 without an IP address (You can have one if you want, but the point here is its not needed)
auto eth1
iface eth1 inet manual
        up ifconfig eth1 up 
```
8. 如果机器只有一个接口，可以创建一个bridge和veth
```
yum install kmod-openvswitch openvswitch -y || apt install openvswitch-switch -y
systemctl enable openvswitch ; systemctl start openvswitch || systemctl enable openvswitch-switch ; systemctl restart openvswitch-switch
ovs-vsctl add-br br0
ovs-vsctl add-port br0 veth1 -- set Interface veth1 ofport_request=1 将端口veth1添加到bridge br0中，并将veth1的OpenFlow端口设置成1 
ovs-vsctl --columns=ofport list interface veth1
ip link set br0 up
ip link set veth1 up
```

#  获取ansible和拷贝配置文件
```
git clone https://github.com/openstack/kolla -b stable/stein
git clone https://github.com/openstack/kolla-ansible -b stable/stein
mkdir -p /etc/kolla
cp -r kolla-ansible/etc/kolla/* /etc/kolla
```

# 单节点

单节点默认使用all-in-one不用做修改
ansible -i all-in-one all -m ping

8. 生成随机密码

kolla-genpwd

使用kolla提供的密码生成工具自动生成，如果密码不填充，后面的部署环境检查时不会通过。为了后面登录方便，可以自定义keystone_admin_password密码，这里改为admi

修改 /etc/kolla/passwords.yml 确保如下配置要被配置
```
keystone_admin_password: admin
docker_registry_password: password_xxx
nova_ssh_key:
  private_key: /root/.ssh/id_rsa
  public_key: /root/.ssh/id_rsa.pub
keystone_ssh_key:
  private_key: /root/.ssh/id_rsa
  public_key: /root/.ssh/id_rsa.pub
kolla_ssh_key:
  public_key: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrbYNpgJ0917NALKT2Ys6dVQ5Ebd/Id5T4iZ+C27hmxevvF5Gx1Nmctv750bO+3Z/1ZPJiWUH/pNTn2r0Ek5l+b7N7AM1VQb7oEMZ3wLO3y7MqdAEcP5kMXith6vU9DKbxiKVVM2hRBOF8PqSgze/FN/YQdfJyu+6DzR/Jw3f0BNnprgp/DAVLFMHaaSg91eWbLHNprqVxCQUt4+RJi3EV7suHiop79NRekGr1YsvQvmyXsWArkAXBdRc3Bdnr5GqctsZM8hd6FaeykWtHU55vGGFKpvj0qcccleC5/r3oKDKmJCqi2IbMPcH82kPz47RV3pLa4/mYy4yeo4r/KTEL
    root@shenlan-PC
kolla_user: root
rabbitmq_cluster_cookie: /var/lib/rabbitmq/.erlang.cookie
database_password: password_xxx
rabbitmq_password: password_xxx
rabbitmq_monitoring_password: password_xxx
redis_master_password: password_xxx
keystone_database_password: password_xxx
glance_keystone_password: password_xxx
glance_database_password: password_xxx
cinder_keystone_password: password_xxx
nova_keystone_password: password_xxx
cinder_database_password: password_xxx
placement_keystone_password: password_xxx
placement_database_password: password_xxx
nova_api_database_password: password_xxx
nova_database_password: password_xxx
neutron_keystone_password: password_xxx
neutron_database_password: password_xxx
heat_keystone_password: password_xxx
heat_domain_admin_password: password_xxx
heat_database_password: password_xxx
magnum_keystone_password: password_xxx
magnum_database_password: password_xxx
metadata_secret: WdCuS+G+EMOOZtZ3lIli2feZNUV+51R9dv/CR01SffU=
memcache_secret_key: 9bdbb6dc9fbb6f6e8dbf93b36f3cceb11ecaf94f140c18b8213acba7dc5fbd00
horizon_secret_key: xcSDDx06cKiHrZ7reOrN7mQ5laoahvt1Wp4RJqM5A0Y=

```


9. 修改 /etc/kolla/globals.yml

* openstack_release: "stein"              openstack版本
* docker_registry: "registry.cn-beijing.aliyuncs.com"   指定镜像的仓库的地址(配置使用私有仓库需要的选项) 
* docker_namespace: "openstack_release"   指定镜像的仓库的命名空间(配置使用私有仓库需要的选项)
* kolla_base_distro: "centos"             指定镜像的系统版本
* kolla_install_type: "source"            指定安装的方式，source为源码
* kolla_internal_address: "x.x.x.x"       宿主机IP
* network_interface: "eth0"               openStack使用的网络接口
* neutron_external_interface: "eth1"     连接neutron的external bridge
* enable_haproxy: "no"                    如果单点部署，高可用设为no
* enable_placement: "yes"

# 使用cinder存储
```
enable_cinder: "yes"
enable_glance: "yes"
enable_magnum: "yes"
enable_heat: "yes"
```

# 如果使用lvm，需先创建cinder-volumes的卷组 enable_cinder_backend_lvm: "yes"

创建卷组的方法如下：

```
dd if=/dev/zero of=./disk.img count=200 bs=512MB
losetup -f
losetup /dev/loop0 disk.img
pvcreate /dev/loop0
vgcreate cinder-volumes /dev/loop0
```

10. 下载镜像

部署时，会检查本地有没有镜像，有的话，使用本地，没有，自动拉取，由于镜像特别大，先下载镜像到本地

kolla-ansible pull


测试是否成功：

# curl -k localhost:4000/v2/_catalog
# curl -k localhost:4000/v2/lokolla/centos-source-fluentd/tags/list
{"name":"lokolla/centos-source-fluentd","tags":["5.0.1"]}


## 开始部署

```
kolla-ansible -i /all-in-one bootstrap-servers                                           #带有kolla的引导服务器部署依赖关系
kolla-ansible -i ../../all-in-one prechecks                                              #对主机执行预部署检查
kolla-ansible -i /usr/local/share/kolla-ansible/ansible/inventory/all-in-one deploy      #开始部署
```

## 后续的配置

OpenStack需要一个openrc文件，其中设置了admin用户的凭证，依次执行：

pip install python-openstackclient                                                       #安装openstack CLI客户端：
kolla-ansible -i /usr/local/share/kolla-ansible/ansible/inventory/all-in-one post-deploy #
. /etc/kolla/admin-openrc.sh

在浏览器输入IP即可访问

## 部署问题记录:

* 问题记录1: TASK [prechecks : Checking docker SDK version]  Failed
依赖Docker Python软件包:  安装python-docker 解决

* 问题记录2：TASK [baremetal : Install pip]  "msg": "Failed to find required executable easy_install in paths
系统节点缺失依赖包: debian下需要手动安装 pip install ez_setup || wget https://bitbucket.org/pypa/setuptools/downloads/ez_setup.py -O - | python

* 问题记录3: 总是提示rabbitmq_cluster_cookie 未定义 
mkdir -pv /var/lib/rabbitmq/
touch /var/lib/rabbitmq/.erlang.cookie
chmod 600 /var/lib/rabbitmq/.erlang.cookie 然后定义变量
rabbitmq_cluster_cookie: /var/lib/rabbitmq/.erlang.cookie

* 问题记录4: Ansible - playbook : Make sure your variable name does not contain invalid characters like '-'
kolla-ansible -i /usr/local/share/kolla-ansible/ansible/inventory/all-in-one deploy  # 不要混用pip install kolla-ansible 和git拉取的kolla-ansible

* 问题记录5: [nova : Creating Nova databases user and setting permissions]
  FAILED! => {"censored": "the output has been hidden due to the fact that 'no_log: true' was specified for this result"}
  nova_database_password 未定义, 需要将对应task yaml no_log: true 关闭可以看见打印错误 

* 生成随机字符串 head -c 32 /dev/random | base64 或者 openssl rand -hex 32 

# 参考

* https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html
