### 制作 debian-installer

安装编译依赖包 apt-get build-dep debian-installer -y 编译安装器

`   git clone git@bj.git.sndu.cn:server-dev/debian-installer.git    cd debian-installer`\
`   git checkout -b deepin-server-2015 origin/deepin-server-2015`

创建配置文件 debian-installer/build/sources.list.udeb 添加如下内容

`   deb [trusted=yes] copy:/data/codes/project/debian-installer/build/ localudebs/`\
`   deb `[`http://10.1.10.21/server-dev`](http://10.1.10.21/server-dev)` kui main/debian-installer`

其中 /data/codes/project/debian-installer/build/
请根据实际位置对应修改，执行 build.sh 完成编译，将 build/dest/
目录下全部文件复制到 /data/debian-installer-latest/dest/ 以备后续使用
(参见 /etc/isobuilder.conf 中配置项 DI\_FILE)

编译结果清单如下：

`   cdrom           用于光盘安装，U盘安装 kernel, initrd 等文件`\
`   netboot         用于网络安装的 kernel, initrd 等文件`\
`   MANIFEST        编译结果清单列表`\
`   MANIFEST.udebs  构建initrd用到的udeb包列表清单`

    debootstrap --no-check-gpg --include=locales,busybox,initramfs-tools,sudo,vim,psmisc,ssh,iptables,linux-image-4.9.0-2-amd64-unsigned,grub-pc,grub-efi --components=main,non-free,contrib --arch=amd64 kui /tmp/rootfs http://10.1.10.21/server-dev/dsce-15-amd64/
    wget http://10.1.10.21/server-dev/dsce-15-amd64/dists/kui/main/debian-installer/binary-amd64/Packages.gz
    zcat Packages.gz | grep Filename | awk  '{print $2}' > all_udeb.list
    sed -i "s@^@http://10.1.10.21/server-dev/dsce-15-amd64/@g" all_udeb.list  
    wget -i all_udeb.list -P udeb/

    echo "Deepin Community Linux Server ${BuildID}" > kui-15-build/.disk/info

    cd kui-15-build/
    reprepro includedeb kui /tmp/rootfs/var/cache/apt/archives/*.deb
    reprepro includeudeb kui ../udeb/*.udeb
    rm -rvf /tmp/rootfs/var/cache/apt/archives/*.deb
    mksquashfs /tmp/rootfs/kui-15-build/live/filesystem.suqashfs
    find . -type f | grep -v -e ^\./\.disk -e ^\./dists | xargs md5sum >> md5sum.txt

    cd ../
    xorriso -as mkisofs -r -V 'Deepin Community Linux Server'                                                 \
        -J -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin                                                      \
        -J -joliet-long                                                                                       \
        -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot                                           \
        -boot-load-size 4 -boot-info-table -eltorito-alt-boot                                                 \
        -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat -isohybrid-apm-hfsplus kui-15-build/         \
        -o deepin-community-server-minimal-amd64-${BuildID}.iso

迁移原debian8版本已经完成的工作

-   tasksel 定义软件分组
-   \~\~base-files 设置基本系统标志\~\~
-   \~\~grub2 设置启动项 deepin 标志\~\~
-   \~\~debootstrap 添加深度 codename kui 支持\~\~
-   \~\~debian-archive-keyring 补充深度仓库key\~\~
-   lsb 修改lsb\_release -a 输出信息
-   distro-info-data 发型版信息数据库
-   desktop-base 设置默认主题和默认背景
-   mate-backgrounds 设置系统默认背景
-   \~\~bash 设置tty终端 LANGUAGE 永远为 C\~\~
-   systemd
    设置/lib/systemd/system/ctrl-alt-del.target默认链接为/dev/null
-   iptables 添加iptable
    服务管理脚本：git@bj.git.sndu.cn:server-packages/iptables.git
-   deepin-tools 添加 restore-os.sh 用于初始化系统
-   linux 4.9

`   * 针对服务器进行内核编译配置调优`\
`   * 开启 cgroup 内存控制模块`\
`   * 热打补丁技术 `\
`   * 内核模块签名`

-   installer

`   * ~~rootskel-gtk   修改安装器默认背景logo~~`\
`   * ~~mountmedia     调整安装器自动挂载磁盘~~`\
`   * ~~cdrom-detect   添加启动U盘支持~~`

`   * e2fsprogs      ext2/3/4分区格式化参数 ：     修改 e2fsprogs 源码包 misc/mke2fs.conf.in`\
`   * partman-base   修改默认分区格式:             git@bj.git.sndu.cn:Debian9-Server-Packages/partman-base.git`\
`   * partman-ext3   修改分区提示信息:             git@bj.git.sndu.cn:Debian9-Server-Packages/partman-ext3.git`\
`   * base-installer 选择内核软件包：              git@bj.git.sndu.cn:Debian9-Server-Packages/base-installer.git`\
`   * firmware-nonfree-udeb  安装器补充非自由固件: git@bj.git.sndu.cn:server-packages/firmware-nonfree-udeb.git`
