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
