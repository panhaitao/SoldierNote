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
4. 设置yum源        curl -o /etc/yum.repos.d/docker-ce.repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo 
5. 安装docker       yum makecache; yum install docker-ce -y 
6. 配置挂载共享
```
tee /etc/systemd/system/docker.service.d/kolla.conf <<-'EOF'
[Service]
MountFlags=shared
EOF
systemctl restart docker
```
7. 如果机器只有一个接口，可以创建一个bridge和veth
```
yum install kmod-openvswitch openvswitch -y
systemctl enable openvswitch && systemctl start openvswitch
ovs-vsctl add-br br0
ovs-vsctl add-port br0 veth1 -- set Interface veth1 ofport_request=1 将端口veth1添加到bridge br0中，并将veth1的OpenFlow端口设置成1 
ovs-vsctl --columns=ofport list interface veth1
ip link set br0 up
ip link set veth1 up
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


* docker_registry: "192.168.41.29:4000"   指定镜像的仓库的地址(配置使用私有仓库需要的选项) 
* docker_namespace: "openstack_release"   指定镜像的仓库的命名空间(配置使用私有仓库需要的选项)
* kolla_base_distro: "centos"             指定镜像的系统版本
* kolla_install_type: "source"            指定安装的方式，source为源码
* kolla_internal_address: "x.x.x.x"       宿主机IP
* openstack_release: "stein"              openstack版本
* network_interface: "eth0"               openStack使用的网络接口
* neutron_external_interface: "veth1"     连接neutron的external bridge
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

