
##  vagrant-libvirt 使用指南

* homepage: https://releases.hashicorp.com/vagrant/
* system: debian9

## 安装基本软件

```
apt-get install vagrant qemu-kvm libvirt-daemon-system  vagrant-libvirt libvirt-dev
```

### 获取 VM模版文件
```
git clone http://anonscm.debian.org/cgit/cloud/debian-vm-templates.git
```
需要修改默认用户密码，preseed文件，和初始化配置脚本文件，具体改动文件列表如下：
* helpers/vagrant-setup
* packer-virtualbox-vagrant/http/vanilla-debian-8-jessie-preseed.cfg
* packer-virtualbox-vagrant/jessie.json
具体修改可以参考 [最新提交补丁](https://bj.git.sndu.cn/panhaitao/deepin-vm-templates/commit/e88bbd435f9d263e74519a4b59fb6773bc832f1e)  

### 获取打包工具
从官方下载[packer](https://releases.hashicorp.com/packer/0.10.1/packer_0.10.1_linux_amd64.zip),解压到系统 `/usr/bin/` 目录

### 构建系统镜像
```
cd debian-vm-templates/packer-virtualbox-vagrant/ 
packer build jessie.json
```
成功构建后，会在当前目录生成 deepin-v15.box 镜像文件 

### 使用系统镜像

```
vagrant box add ci-vm-node *.box
vagrant init ci-vm-node
vagrant up --provider=libvirt
```
### Vagrantfile 配置实例 
```
Vagrant.configure("2") do |config|
  config.vm.box = "ci-vm-node"
    config.vm.provider :libvirt do |libvirt|
      libvirt.driver = "kvm"
    end
    config.vm.define :node1 do |node1_config|
        node1_config.vm.network :public_network, :dev => "br0"
    end
    config.vm.define :node2 do |node2_config|
        node2_config.vm.network :public_network, :dev => "br0"
    end
end
```

## 参考

* <http://linuxsimba.com/vagrant-libvirt-install>
* <http://ftp.cvut.cz/debian/pool/main/r/ruby-fog-libvirt/>
* <http://www.oschina.net/translate/get-vagrant-up-and-running-in-no-time>
* <https://www.packer.io/>
* <http://www.rubydoc.info/gems/vagrant-libvirt/0.0.28#Create_Vagrantfile>
* <http://www.jianshu.com/p/2d2648451f28>
* <http://rmingwang.com/vagrant-commands-and-config.html>
* <http://blog.csdn.net/54powerman/article/details/50676320>
