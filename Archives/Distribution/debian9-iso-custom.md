制作 debian-installer
---------------------

1\. 安装编译依赖包 apt-get build-dep debian-installer -y

2\. 获取安装器源码 apt-get source debian-installer

3\. 编译安装器，进入 /home/deepin/debian-installer-20170615+deb9u2/build
目录，创建配置文件 sources.list.udeb 添加如下内容

`   deb [trusted=yes] copy:/home/deepin/debian-installer-20170615+deb9u2/build localudebs/`\
`   deb  `[`http://mirrors.tuna.tsinghua.edu.cn/debian/`](http://mirrors.tuna.tsinghua.edu.cn/debian/)` stretch main/debian-installer`

4\. 在 /home/deepin/debian-installer-20170615+deb9u2/build
目录执行如下命令

`   make build_cdrom_gtk`

5\. /home/deepin/debian-installer-20170615+deb9u2/build/dest

    MANIFEST                            编译结果清单列表 
    MANIFEST.udebs                      构建initrd用到的udeb包列表清单 
    cdrom/gtk/vmlinuz                   用于光盘安装的 kernel
    cdrom/gtk/initrd.gz                 用于光盘安装的 initrd 等文件 
    cdrom/gtk/debian-cd_info.tar.gz     和启动引导相关的文件

创建一个用于生成ISO的模板目录
-----------------------------

    cd /home/deepin/debian-installer-20170615+deb9u2/
    mkdir -pv isotree/
    mkdir -pv isotree/{boot,efi,isolinux,installer,.disk}
    mkdir -pv isotree/efi/boot/
    touch     isotree/.disk/{base_components,base_installable,cd_type,info,udeb_include}

将安装器相关的启动文件解压到模板目录中
--------------------------------------

    cd /home/deepin/debian-installer-20170615+deb9u2/
    mkdir tmp && tar -xvpf build/dest/cdrom/gtk/debian-cd_info.tar.gz -C tmp
    cp -av    build/dest/cdrom/gtk/{vmlinuz,initrd.gz}    isotree/installer            
      
    mcopy     -i tmp/grub/efi.img ::efi/boot/bootx64.efi isotree/efi/boot/bootx64.efi
    mv        tmp/grub/                                  isotree/boot/
    cp -av    tmp/*                                      isotree/isolinux/
    cp        /usr/lib/ISOLINUX/isolinux.bin             isotree/isolinux/
    cp        /usr/lib/syslinux/modules/bios/{ldlinux.c32,libcom32.c32,libutil.c32,vesamenu.c32} isotree/isolinux/

修改 isotree/isolinux/txt.cfg

    label install
            menu label ^Install
            kernel /installer/vmlinuz
            append initrd=/installer/initrd.gz file=/cdrom/preseed.cfg vga=788 --- quiet 

修改 isotree/boot/grub/grub.cfg

    menuentry 'Install' {
        set background_color=black
        linux    /installer/vmlinuz  vga=788 file=/cdrom/preseed.cfg --- quiet 
        initrd   /installer/initrd.gz
    }

获取cdrom需要的deb包和udeb包
----------------------------

    export repo_url=http://mirrors.tuna.tsinghua.edu.cn/debian/
    export codename=stretch

    mkdir tmp/rootfs
    debootstrap --no-check-gpg --include=locales,busybox,initramfs-tools,sudo,vim,psmisc,ssh,iptables,linux-image-amd64,grub-pc,grub-efi --components=main,non-free,contrib --arch=amd64 $codename tmp/rootfs $repo_url  

    wget $repo_url/dists/$codename/main/debian-installer/binary-amd64/Packages.gz
    zcat Packages.gz | grep Filename | awk  '{print $2}' > all_udeb.list
    sed -i "s@^@$repo_url/@g" all_udeb.list  
    mkdir -pv tmp/udeb/ && wget -i all_udeb.list -P tmp/udeb/

    cd isotree/ && mkdir conf
    cat > conf/distributions << EOF
    Codename: $codename 
    Description: official main repository
    Architectures: i386 amd64
    Components: main contrib non-free
    UDebComponents: main
    Contents: .gz
    Suite: stable
    EOF
    reprepro includedeb $codename ../tmp/rootfs/var/cache/apt/archives/*.deb
    reprepro includeudeb $codename ../tmp/udeb/*.udeb

    echo "Debian Custom" > .disk/info
    find . -type f | grep -v -e ^\./\.disk -e ^\./dists | xargs md5sum >> md5sum.txt

    cd /home/deepin/debian-installer-20170615+deb9u2/

    xorriso -as mkisofs -r -V 'Debian Custom '                                                                \
        -J -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin                                                      \
        -J -joliet-long                                                                                       \
        -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot                                           \
        -boot-load-size 4 -boot-info-table -eltorito-alt-boot                                                 \
        -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat -isohybrid-apm-hfsplus isotree/              \
        -o debian-custom-minimal-amd64.iso

    rm -rvf /tmp/rootfs/var/cache/apt/archives/*.deb
    mksquashfs /tmp/rootfs/ kui-15-build/live/filesystem.suqashfs

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
