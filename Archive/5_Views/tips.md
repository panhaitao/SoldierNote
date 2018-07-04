# TIPS 


## 远程终端超时问题

1. $TMOUT 系统环境变量，如果输出空或0表示不超时，大于0的数字n表示n秒没有收入则超时

2. sshd 服务配置 

```
ClientAliveInterval 指定了服务器端向客户端请求消息的时间间隔, 默认是0, 不发送。设置60表示每分钟发送一次, 然后客户端响应, 这样就保持长连接了。
ClientAliveCountMax 表示服务器发出请求后客户端没有响应的次数达到一定值, 就自动断开。正常情况下, 客户端不会不响应，使用默认值3即可。
```

## btrfs 卷备份还原

```
btrfs subvolume snapshot / /backup
btrfs subvolume list /
mount /dev/sda1 /mnt/
mv /mnt/backup /mnt/@
reboot
umount /mnt
btrfs subvolume delete /mnt/backup/
```

## facebook centos 升级systemd 234

* https://copr.fedorainfracloud.org/coprs/jsynacek/systemd-backports-for-centos-7/ 
* 仓库     https://copr-be.cloud.fedoraproject.org/results/jsynacek/systemd-backports-for-centos-7/epel-7-x86_64/
* 仓库配置 https://copr.fedorainfracloud.org/coprs/jsynacek/systemd-backports-for-centos-7/repo/epel-7/jsynacek-systemd-backports-for-centos-7-epel-7.repo

```
curl 	        7.47.1-1.1.el7 	
libgudev 	230-3.fc26
lz4 	        1.7.4.2-1.fc26
python-systemd 	234-1
systemd 	234-0.1
util-linux      2.29-2.el7 
```

## add apt key

```
wget -qO - http://deb.opera.com/archive.key | sudo apt-key add -
```

```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7C24E5AB949045F5
```

```
gpg --keyserver-options http-proxy --keyserver keyserver.ubuntu.com --recv 40976EAF437D05B5
gpg --export --armor 40976EAF437D05B5 | sudo apt-key add -
```

```
gpg --delete-key --armor 40976EAF437D05B5
sudo apt-key del 40976EAF437D05B5
```

## SSH 代理

```
ssh -L 28090:远端内网IP:28090 alauda@远端外部IP -N

```


## MATE 桌面环境设置 compiz 窗口管理器

使用下面的 GSettings 命令可以将默认的窗口管理器 marco 改为 Compiz。

    $ gsettings set org.mate.session.required-components windowmanager compiz

使用 mate-session-properties 注意: 当使用这种方法时，Marco会首先启动，然后自动被Compiz替换。

另一种做法是使用mate-session-properties来启用Compiz。 在终端中输入下面的命令：

    $ mate-session-properties

单击“添加”按钮，并在“命令”文本框中输入 compiz --replace & 命令。 名称和介绍栏目并不重要，只是用来说明的，不要在意这些细节。 注销再登陆，Compiz应该就会顺利启动了。 

## HOME 目录从中文切换到英文

```
export LC_ALL=en_US.UTF-8
xdg-user-dirs-update --force
```

重新打开一个 terminal 进行操作，完了关闭即可，不需要额外再恢复中文显示什么的。如果不想再次登入后被提示更新目录，当前环境为中文则执行 echo zh_CN > ~/.config/user-dirs.locale，英文则执行 echo en_US > ~/.config/user-dirs.locale。

注销重新登陆桌面，会提示将标准文件夹更新到当前语言，勾选”下次不要询问我”，并 选择保留旧的名称，即可！

相关配置：
* ~/.config/user-dirs.dirs 
* ~/.config/user-dirs.locale

##  离线安装chrome 浏览器扩展

1. 修改 .crx 后缀名为 .zip，解压到一个文件夹中
2. 打开 Chrome “设置” —— “扩展程序”，勾选右上角的“开发者模式”
3. 点击“加载正在开发的扩展程序”，选择插件文件夹 


## 运行jnlp 文件

1. 安装JRE/JDK
2. 在需要打开的jnlp文件夹，按shift 键，右键打开命令窗口
3. 在命令窗口输入javaws  xxx.inlp  即可


## Linux 下关闭触摸板


一般情况下，Linux是使用synaptics触摸板驱动,

1. 卸载synaptics驱动 `sudo apt-get autoremove synaptics` 但是如果一旦需要使用触摸板，还要把驱动装上，太麻烦了。

2. 还有一种比较简单的方法。

编辑 /etc/X11/xorg.conf

```
Section "InputDevice"
Identifier "Synaptics Touchpad"
Driver "synaptics"
Option "SendCoreEvents" "true"
Option "Device" "/dev/psaux"
Option "Protocol" "auto-dev"
Option "HorizEdgeScroll" "0"
Option "SHMConfig" "on"
EndSection

```
添加 Option "SHMConfig" "on" 这行内容, SHMConfig on 表明开启触摸板的参数设置权限

- 命令：synclient touchpadoff=1 －－关闭触摸板
- 命令：synclient touchpadoff=0 －－开启触摸板


## ssh 分发公钥后　登录失败

现象
```
debug3: send packet: type 50                                                                                                                                                                   
debug2: we sent a publickey packet, wait for reply                                             
debug3: receive packet: type 51   
...

Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
```

仔细检查后 ssh 秘钥公钥正确，最后经过各种google找到原因是.ssh/权限问题

chmod 0700 ~/.ssh/ 
chmod 0600 ~/.ssh/authorized_keys 
chmod 0400 ~/.ssh/id_rsa 

另外还是注意属组的问题, 如果.ssh目录和下面的文件属主错误也会导致权限文件
