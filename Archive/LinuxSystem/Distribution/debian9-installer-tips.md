#  Debian9版本定制: deian-installer 组件定制

* 修改安装器默认背景logo：                     git@bj.git.sndu.cn:Debian9-Server-Packages/rootskel-gtk.git
* 调整安装器自动挂载磁盘：                     git@bj.git.sndu.cn:Debian9-Server-Packages/mountmedia.git
* 添加U盘安装支持功能:                         git@bj.git.sndu.cn:Debian9-Server-Packages/cdrom-detect.git
* 修改默认分区格式:                            git@bj.git.sndu.cn:Debian9-Server-Packages/partman-base.git
* 修改分区提示信息:                            git@bj.git.sndu.cn:Debian9-Server-Packages/partman-ext3.git 
* 选择内核软件包：                             git@bj.git.sndu.cn:Debian9-Server-Packages/base-installer.git
* 安装器补充非自由固件:                        git@bj.git.sndu.cn:server-packages/firmware-nonfree-udeb.git
* ext2/3/4分区格式化参数：                     修改 e2fsprogs 源码包 misc/mke2fs.conf.in


# 原debian8版本已经完成的工作 

* tasksel                定义软件分组 
* base-files             设置基本系统标志
* grub2                  设置启动项 ProduceName 标志
* debootstrap            添加深度 codename kui 支持
* debian-archive-keyring 补充深度仓库key
* lsb                    修改lsb_release -a 输出信息
* distro-info-data       发型版信息数据库
* desktop-base           设置默认主题和默认背景
* mate-backgrounds       设置系统默认背景
* bash                   设置tty终端 LANGUAGE 永远为 C              
* systemd                设置/lib/systemd/system/ctrl-alt-del.target默认链接为/dev/null
* iptables               添加iptable 服务管理脚本：git@bj.git.sndu.cn:server-packages/iptables.git

# 内核有模块，但是缺少对应硬件设备固件 #

以 megaraid-sas-9361-8i raid卡和 deepin server 15.1 为例,设备驱动官网下载地址 https://www.broadcom.com/products/storage/raid-controllers/megaraid-sas-9361-8i#downloads

1. 下载ISO，使用深度启动盘制作工具制作成USB安装盘，

2. 将对应网卡固件mr3108fw.rom,放到U盘分区firmware文件夹下

3. 修改U盘分区下custom.postinstall脚本，添加如下一行，解决安装后系统驱动raid卡的问题 
```
cp /cdrom/firmware/mr3108fw.rom /target/lib/firmware/
```
4. 确认修改无误，重新安装系统即可
