# Linux使用过程记录的小问题


## 使用脚本批量创建用户
```
for user in `cat /tmp/user.list`
    do
      echo "Starting add user $user";
      useradd $user -G docker -N;
      echo "$user" | passwd --stdin $user;
      echo "The user $user add success !";
done
```

## 使用脚本批量更改密码

```
#!/bin/bash
# filename: change_passwd.sh
useradd zhs
echo "zhs:Zhs123456" | chpasswd
usermod zhs -G docker
echo "zhs  ALL=(ALL)       ALL" >> /etc/sudoers
```

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

ubuntu/debian下可以touchpad-indicator工具来

1. 安装软件包，执行命令如下：
        sudo apt install software-properties-common
        sudo add-apt-repository ppa:atareao/atareao
        sudo apt-get update
        sudo apt-get install touchpad-indicator
<br>

2. 启动touchpad-indicator,参考配置如下：
 1. 动作列表: 鼠标接入时候禁用触摸板，打开 
 2. 常规选项: 开机自动运行，打开
<br>
3.  也可以执行命令手动开启或禁用触摸板功能
  1. 关闭触摸板命令：synclient touchpadoff=1 
  2. 开启触摸板命令：synclient touchpadoff=0 


##  查看当前目录空间占用

du -h --max-depth=1  ./


## deepn-core

deepin@deepin:~$ dpkg-query -W | awk '{print $1}' | grep deepin
```
deepin-artwork-themes
deepin-boot-maker
deepin-clone
deepin-desktop-base
deepin-desktop-schemas
deepin-gtk-theme
deepin-icon-theme
deepin-keyring
deepin-lang-selector
deepin-menu
deepin-metacity
deepin-metacity-common
deepin-notifications
deepin-repair-tools
deepin-screenshot
deepin-sound-theme
deepin-terminal
deepin-wm-switcher
libdeepin-metacity-private3
```
deepin@deepin:~$ dpkg-query -W | awk '{print $1}' | grep dde
```
dde-account-faces
dde-api
dde-control-center
dde-daemon
dde-desktop
dde-dock
dde-file-manager
dde-launcher
dde-polkit-agent
dde-qt5integration
dde-session-ui
dde-trash-plugin
libdde-file-manager:amd64
startdde
```

## Git配置代理的方式：

git config –global https.proxy http://127.0.0.1:1080 
git config –global https.proxy https://127.0.0.1:1080 
更重要的是，Git取消代理的方式：

git config –global –unset http.proxy 
git config –global –unset https.proxy

## ssh 目录权限 
sshd为了安全，对属主的目录和文件权限有所要求。如果权限不对，则ssh的免密码登陆不生效。
用户目录权限为 755 或者 700，就是不能是77x。
.ssh目录权限一般为755或者700。
rsa_id.pub 及authorized_keys权限一般为644
rsa_id权限必须为600


## firefox repo for debian

```
echo "deb http://downloads.sourceforge.net/project/ubuntuzilla/mozilla/apt all main" > /etc/apt/sources.list.d/firefox.list 
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com CCC158AFC1289A29
apt-get install firefox-mozilla-build
```


## wget 下载特定目录

1. 需要下载某个目录下面的所有文件。命令如下`wget -c -r -np -k -L -p www.xxx.org/pub/path/`
2. 在下载时。有用到外部域名的图片或连接。如果需要同时下载就要用-H参数。`wget -np -nH -r --span-hosts www.xxx.org/pub/path/`

* -c 断点续传
* -r 递归下载，下载指定网页某一目录下（包括子目录）的所有文件
* -nd 递归下载时不创建一层一层的目录，把所有的文件下载到当前目录
* -np 递归下载时不搜索上层目录，如wget -c -r www.xxx.org/pub/path/
* 没有加参数-np，就会同时下载path的上一级目录pub下的其它文件
* -k 将绝对链接转为相对链接，下载整个站点后脱机浏览网页，最好加上这个参数
* -L 递归时不进入其它主机，如wget -c -r www.xxx.org/ 
* 如果网站内有一个这样的链接： 
* www.yyy.org，不加参数-L，就会像大火烧山一样，会递归下载www.yyy.org网站
* -p 下载网页所需的所有文件，如图片等
* -A 指定要下载的文件样式列表，多个样式用逗号分隔
* -i 后面跟一个文件，文件内指明要下载的URL

还有其他的用法，我从网上搜索的，也一并写上来，方便以后自己使用。


## k8s 集群内域名端口检查

场景一: 集群内服务名不可解析，检查k8s DNS
        kubectl get pods -n kube-system -o wide| grep dns | awk '{print $(NF-1)}'  > dns.txt

        for server_ip in `cat dns.txt`; do nslookup 域名 $server_ip
          if [ $? -ne 0 ]
             then
             echo $i >> bad.txt
          fi
         done

场景二: 走lb域名 端口通  走集群内服务域名不通

 1. 检查服务名是否可以解析，如果不能解析，可以检查对应service yaml配置是否正确
 2. 如果服务名可以解析，但是 服务名+端口不通，可检查 service yaml 配置是否存在

用服务名访问的话，dns会解析到这个服务的ClusterIP，访问 clusterIP 实际上是一个 iptables的规则，这个规则需要同时匹配 clusterIP 和 端口，而这个端口就需要在服务的yaml中进行声名，也就是在prots的那一段加上如下参数：
```
- name: port-111
  port: 111
  protocol: TCP
  targetPort: 111
``` 

## docker 代理设置


`Environment="HTTP_PROXY=http://proxy.example.com:80/"`
