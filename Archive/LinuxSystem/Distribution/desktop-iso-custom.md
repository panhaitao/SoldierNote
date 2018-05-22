# 定制适合自己的精简桌面环境

## 概述

DDE确实最好的桌面环境之一，喜欢在Linux下工作，只是不喜欢基于debian untable 仓库桌面版本，也不喜欢很多默认安装的应用，卸载部分应用的时候破会dde桌面环境，可能会可能也永不到，于是我整理了一下目前还算满意使用的一个基于ubuntu-18.04定制版本的修改记录，仅供一定动手能力的朋友参考！

* 系统 ubuntu 18.04 
* ppa仓库 /etc/apt/sources.list.d/leaeasy-ubuntu-dde-bionic.list
```
deb http://ppa.launchpad.net/leaeasy/dde/ubuntu bionic main
deb-src http://ppa.launchpad.net/leaeasy/dde/ubuntu bionic main
```
## 定制开始

想去掉默认的安装的应用，需要定制dde这个包

```
# apt-get install dpkg-dev
# apt-get source dde
# apt-get build-dep dde
```

编辑   dde-15.4+16/debian/control 调整 Depends，Recommends，Suggests

1. Depends		定义的是保证软件运行的依赖关系，其中dde名称开头的软件包是dde桌面的核心，以下是实际的可选的 deepin-terminal, dde-calendar, deepin-system-monitor, deepin-image-viewer, deepin-screenshot, 可以调整到，Recommends 或者 Suggests 里
2. Recommends	定义的是推荐依赖，并不是主程序运行必须的运行依赖，如果仓库里面有，apt-get 默认还是会安装的，所以这里也是需要定制的一个关键点，这里可以根据你的需要进行删减，我喜欢dde的核心桌面环境，喜欢mate终端和mate 的 caja文件浏览器，那就在这里添加对应的软件包名字
3. Suggests		定义的建议依赖，默认不会安装


下面是一个我个人的修改记录，仅供参考！

```
    Depends: ${misc:Depends},
       deepin-desktop-base,
       dde-desktop,
       dde-polkit-agent,
       dde-dock,
       dde-launcher,
       dde-control-center(>> 2.90.5),
       dde-daemon,
       deepin-metacity,
       deepin-wm,
       startdde,
       dde-session-ui,
       deepin-notifications,
       deepin-menu,
       deepin-icon-theme
    Recommends:
       deepin-deb-installer,
       deepin-screen-recorder,
       deepin-voice-recorder,
       deepin-shortcut-viewer,
       file-roller,
       gedit,
       mate-terminal，
       caja
    Suggests:
```

最后修改， debian/changelog 把最上面的 dde (15.4+16) bionic; urgency=medium 中的版本号改得大点，避免以后升级被覆盖，dde 只是个虚包，定义个桌面环境默认安装软件包的组成，修改这个包不会应用DDE桌面的任何功能，回到 dde-15.4+16 目录  执行命令构建软件包:

```
dpkg-buildpackage -sa
```

命令执行完毕后，会在上一层目录生成deb包，执行dpkg 把这个定制后的软件包安装好，然后执行 apt-get autoremove --purge 就可以安全卸载那些你不需要的应用了，也不会破会整个桌面环境了！

顺便分享一下我工作中用到的软件：

*   微信：           snap install electronic-wechat
*   钉钉：           https://github.com/nashaofu/dingtalk
*   onedrive        https://github.com/skilion/onedrive.git
*   Teamviewer https://download.teamviewer.com/download/linux/teamviewer_amd64.deb


这几年用习惯了MacOS和Linux，只要找到linux下的软件替代品，依旧不想回到windows下工作！


## 使用live-boot 制作可启动LiveCD  

* 准备，启动内核和initramfs

```
apt-get install live-boot-initramfs-tools
mkinitramfs -o /initrd.gz kernel_verison
debootstrap --no-check-gpg --include="cat list | tr '\n' ','"  --components=main,restricted,universe,multiverse --arch=amd64 bionic tmp/rootfs file:///root/debian-installer-20101020ubuntu543/isotree/
mksquashfs *  ~/filesystem.squashfs
```

list 中需要包含live-boot 软件包，未验证
filesystem.squashfs 对应的rootfs 需要创建一个UID大于500 的普通用户，DDE桌面才能启动

* 封装ISO 可以参考 Debian9版本定制 <http://onwalk.net/LinuxSystem/Distribution/debian9-iso-custom.html>

