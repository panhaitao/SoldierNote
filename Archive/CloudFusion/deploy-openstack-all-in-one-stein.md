# kolla-ansible部署openstack的all-in-one环境（stein版）

## 系统准备

需要准备两台主机，一个运行ansible的ops主机，一台运行openstack的主机

ops主机: 

  * 1C cpu cores
  * 2GB main memory
  * 40GB disk space
  * 1 network interfaces

openstack的节点主机:

  * 4C cpu cores
  * 8GB main memory
  * 40GB disk space
  * 2 network interfaces

## 初始化openstack节点

1. 关闭selinux      vi /etc/selinux/config SELINUX=disabled
2. 关闭防火墙       systemctl stop firewalld;systemctl disable firewalld
3. 关闭libvirtd服务 systemctl stop libvirtd.service; systemctl disable libvirtd.service
4. 设置yum源        curl -o /etc/yum.repos.d/docker-ce.repo / http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo 
5. 安装docker       yum makecache; yum instal docker-ce -y 
6. 配置挂载共享
```
tee /etc/systemd/system/docker.service.d/kolla.conf <<-'EOF'
[Service]
MountFlags=shared
EOF
systemctl restart docker
```
## ansible 主机准备

1. 安装ansible yum install ansible git -y
2. 从github 获取Kolla和Kolla-Ansible
```
git clone https://github.com/openstack/kolla -b stable/stein
git clone https://github.com/openstack/kolla-ansible -b stable/stein
```

3. 拷贝配置文件

cp -r ./kolla-ansible/etc/kolla /etc/kolla 
cp kolla-ansible/ansible/inventory/* .

# 单节点默认使用all-in-one不用做修改，多节点部署需要修改multinode
检查playbook文件配置是否正确

# 单节点

ansible -i all-in-one all -m ping

8. 生成随机密码

kolla-genpwd

使用kolla提供的密码生成工具自动生成，如果密码不填充，后面的部署环境检查时不会通过。为了后面登录方便，可以自定义keystone_admin_password密码，这里改为admin

vi /etc/kolla/passwords.yml

keystone_admin_password:admin

9. 修改globals.yml
vi /etc/kolla/globals.yml

# 指定镜像的系统版本
kolla_base_distro: "centos"

# 指定安装的方式，source为源码
kolla_install_type: "source"

# openstack版本
openstack_release: "stein"

# OpenStack使用的网络接口

network_interface: "[Bond0]"

# 宿主机IP
kolla_internal_address: "[172.28.3.101]"

# Neutron外部网络，必须是没有与network_interface Bond的可用网卡
neutron_external_interface: "[enp26s0f1]"

# 如果单点部署，高可用设为no
enable_haproxy: "no"
enable_placement: "yes"

# 使用cinder存储
enable_cinder: "yes"
enable_glance: "yes"
enable_magnum: "yes"
enable_heat: "yes"

# 如果使用lvm，需先创建cinder-volumes的卷组
enable_cinder_backend_lvm: "yes"
创建卷组的方法如下：

dd if=/dev/zero of=./disk.img count=200 bs=512MB
losetup -f
losetup /dev/loop0 disk.img
pvcreate /dev/loop0
vgcreate cinder-volumes /dev/loop0

10. 下载镜像

部署时，会检查本地有没有镜像，有的话，使用本地，没有，自动拉取，由于镜像特别大，先下载镜像到本地

kolla-ansible pull

11. 开始部署
11.1 带有kolla的引导服务器部署依赖关系

kolla-ansible -i ./all-in-one bootstrap-servers
11.2 对主机执行预部署检查

kolla-ansible -i ./all-in-one prechecks
11.3 执行OpenStack部署

kolla-ansible -i ./all-in-one deploy
12. 后续的配置
12.1 安装openstack CLI客户端：

pip install python-openstackclient
12.2 OpenStack需要一个openrc文件，其中设置了admin用户的凭证，依次执行：

kolla-ansible post-deploy 

. /etc/kolla/admin-openrc.sh
12.3 在浏览器输入IP即可访问

