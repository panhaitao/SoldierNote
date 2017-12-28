
# 手动安装

刻录光盘和制作启动U盘已经是当前最普遍的安装方式，已经没有什么太多可重复说的了, 玩转服务器不要依赖桌面环境，能敲shell命令来做的事情就不要使用图形工具来操作，在这里我只想分享两条命令，让你在命令下玩的更轻松！

* 命令行下刻录光盘：

首先要确保系统中`xorriso`软件包被安装，将空光盘放入刻录光驱，执行如下命令完成光盘刻录！

`xorrecord -v dev=/dev/sr0 speed=8 fs=8m -waiti -multi --grow_overwriteable_iso -eject padsize=300k debian-server.iso`

* 命令下制作安装U盘

当下，U盘已经完全可以替代光盘，制作好的安装U盘可以像使用光驱设备一样来安装系统，使用`dd if=debian-server.iso of=/dev/sdX bs=8M`命令可以将iso文件复制到U盘设备

注意事项如下：

    * 制作好的安装U盘是只读设备，实际安装过程U盘被模拟为一个光驱设备
    * 如要恢复U盘原有用途，请使用命令`dd if=/dev/zero of=/dev/sdX bs=512 count=1`
      清空分区表重新格式化即可
    * (/dev/sdX 请根据U盘实际对应的设备名来选择，例如 `/dev/sdb /dev/sdc ...`)

## U盘自动安装

场景描述：在一个新建机房, 上架机器不多，十几台到数十台，没有网络，机器配置不一样，不能拆机硬盘对拷...如何实现快速部署？研发团队和工程团队花了两周的时间，通过不断测试和调整，完成了服务器U盘自动化安装化.具体细节如下：

    * 通过微调服务器安装器，让其默认从外部读取preseed.cfg文件
    * 通过适配深度启动盘制作工具，制作一个可读可写的安装U盘
    * 将准备好的preseed.cfg文件，替换启动U盘中的preseed.cfg
      开机从U盘启动，就可以进入开始自动安装模式

## 网络自动安装

场景描述：上架机器几十台到数百台，机器配置相近，所有机器在同一网段，但是不能访问外网。基于上述条件下，搭建PXE自动安装部署环境，需要完成如下配置和准备工作：

* 获取netboot.tar.gz
* 编写preseed.cfg
* HTTP服务器的配置
* TFTP服务器的配置
* DHCP服务器的配置

### 配置HTTP服务器

执行命令`apt-get install nginx -y` 完成nginx的安装，修改配置文件 /etc/nginx/sites-available/default 完成后重启nginx服务

参考配置如下:

```
server {
       	listen 80 default_server;
       	listen [::]:80 default_server;

       	root /var/www/html;
        autoindex on;

       	location / {
       		try_files $uri $uri/ =404;
       	}
}
```

### 搭建内网软件仓库

将ISO文件内的`dists pool` 目录拷贝到 /var/www/html下 , 进入 /var/www/html/dists 目录创建链接

```
ln -sv kui kui-security
ln -sv kui kui-updates
ln -sv kui stable
```

#### 编写 preseed.cfg 文件

在 /var/www/html 根目录下创建 preseed.cfg 文件

* 可以通过命令 `debconf-get-selections --installer > file` 获取preseed参考配置
* 可以通过命令 `debconf-set-selections -c preseed.cfg` 检查preseed文件的语法错误

####  配置TFTP服务

执行命令`apt-get install tftpd-hpa -y` 完成tftp服务器的安装，修改配置文件 /etc/default/tftpd-hpa，完成后重启tftpd-hpa服务

参考配置如下：

```
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/srv/tftp"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure"
```

将netboot.tar.gz文件解压到TFTP 服务器的根目录,修改启动项目debian-installer/amd64/boot-screens/txt.cfg 参考配置如下:

```
default Install-Deepin-Server
label Install-Deepin-Server
        menu label ^Install-Deepin-Server
        menu default
        kernel debian-installer/amd64/linux
        append vga=788 initrd=debian-installer/amd64/initrd.gz auto=true priority=critical url=http://http_server_ip/preseed.cfg --- quiet
```

*以上配置仅供参考，其中 http_server_ip 请修改为实际IP*

#### 配置dhcp服务

执行命令 `apt-get install isc-dhcp-server -y` 安装搭建dhcp服务的软件包。

* 修改 /etc/default/isc-dhcp-server，指定网络设备

```
INTERFACES="eth0"
```

* 修改 /etc/dhcp/dhcpd.conf，完成关键配置，指定pxe引导文件名称和存放位置，修改完成后重启isc-dhcp-server服务，参考配置如下：

```
default-lease-time 600;
max-lease-time 7200;
allow booting;

subnet 192.168.1.0 netmask 255.255.255.0 {
  range 192.168.1.100 192.168.1.200;
  option broadcast-address 192.168.1.255;
  option routers 192.168.1.1;             # our router
  option domain-name-servers 192.168.1.1; # our router, again
  filename "pxelinux.0";                  # 指定引导文件名称
}

group {
  next-server 192.168.1.108;              # 指定 TFTP 服务器IP 
  host tftpclient {
    filename "pxelinux.0"; # (this we will provide later)
  }
}
```

*以上配置仅供参考，其中 subnet，routers，next-server 等配置请根据实际情况修改*

#### 排错和测试

* 可通过观察 `tail -f /var/log/syslog` 来检查服务的运行状态
* 安装过程出错，可以通过 Control+Alt+F4 组合键来观察日志输出

## preseed.cfg 参考配置

```
### Localization
d-i debian-installer/locale string en_US
d-i debian-installer/language string en
d-i debian-installer/country string CN
d-i debian-installer/locale string en_US.UTF-8
d-i localechooser/supported-locales multiselect en_US.UTF-8,zh_CN.UTF-8, zh_CN.GBK, zh_CN.GB18030, zh_CN GB2312

### Keyboard selection.
d-i keyboard-configuration/xkb-keymap select us

### Preseed Early
d-i preseed/early_command string kill-all-dhcp; netcfg

### Network configuration
d-i netcfg/choose_interface select auto
d-i netcfg/hostname string deepin

d-i hw-detect/load_firmware boolean true

### Mirror settings
d-i mirror/country string manual
d-i mirror/http/hostname string http_server_ip
d-i mirror/http/directory string /
d-i mirror/suite string kui
d-i mirror/udeb/suite string kui
d-i debian-installer/allow_unauthenticated string true

### Account setup 请将下文中 password-str 替换为你定义的密码 
d-i passwd/root-login boolean false
d-i passwd/username string admin
d-i passwd/user-fullname string admin
d-i passwd/user-password password password-str        
d-i passwd/user-password-again password password-str

### Clock and time zone setup
d-i clock-setup/utc boolean true
d-i time/zone string Asia/Shanghai
d-i clock-setup/ntp boolean false

### Partitioning
d-i partman-auto/method string regular
d-i partman-auto/choose_recipe select atomic
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
d-i partman/mount_style select uuid

### Apt setup
d-i apt-setup/non-free boolean true
d-i apt-setup/contrib boolean true
d-i apt-setup/local0/repository string http://http_server_ip/ kui main non-free contrib
d-i apt-setup/security_host string
base-config apt-setup/security-updates boolean false

### Package selection
tasksel tasksel/first multiselect
d-i pkgsel/include string openssh-server vim 
popularity-contest popularity-contest/participate boolean false

### GRUB
d-i grub-installer/only_debian boolean true
d-i grub-installer/bootdev  string default

### Finishing up the installation
d-i finish-install/keep-consoles boolean true
d-i finish-install/reboot_in_progress note
d-i debian-installer/exit/poweroff boolean true
```

*以上配置仅供参考，其中 http_server_ip 请修改为实际IP*


## 优劣差异

* 手动安装
    * 优点：最通用的安装方式，安装过程可交互
    * 缺点： 只能一台台的安装
* 自动安装
    * U盘自动安装
        * 优点：步骤简单，制作调试方便，不依赖网络
        * 缺点：仅仅适用于小规模机器安装部署
    * 网络自动安装
        * 优点：大规模部署具有明显的效率优势
        * 缺点：搭建步骤繁琐，严重依赖网络
