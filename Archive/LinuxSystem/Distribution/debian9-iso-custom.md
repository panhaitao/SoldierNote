# Debian9版本定制指南

## 前提条件

* 工作系统： debian9
* 开启 deb-src 源码仓库
* 工作目录 /home/user/ 

## 制作 debian-installer
 
1. 安装开发工具集合 `apt-get install dpkg-dev`
2. 安装编译依赖包    `apt-get build-dep debian-installer -y`
3. 获取安装器源码    `apt-get source debian-installer`, 命令完成后会将源码解压到 debian-installer-20170615+deb9u2目录 
4. 编译安装器，进入 debian-installer-20170615+deb9u2/build 目录，创建配置文件 sources.list.udeb 添加如下内容

```
deb [trusted=yes] copy:/home/user/debian-installer-20170615+deb9u2/build localudebs/
deb http://mirrors.tuna.tsinghua.edu.cn/debian/ stretch main/debian-installer
```  
5. 在 /home/user/debian-installer-20170615+deb9u2/build目录执行如下命令
`make build_cdrom_gtk`
6. /home/user/debian-installer-20170615+deb9u2/build/dest

    MANIFEST                                    编译结果清单列表 
    MANIFEST.udebs                          构建initrd用到的udeb包列表清单 
    cdrom/gtk/vmlinuz                          用于光盘安装的 kernel
    cdrom/gtk/initrd.gz                         用于光盘安装的 initrd 等文件 
    cdrom/gtk/debian-cd_info.tar.gz    和启动引导相关的文件

创建一个用于生成ISO的模板目录从
-----------------------------

    cd /home/user/debian-installer-20170615+deb9u2/
    mkdir -pv isotree/
    mkdir -pv isotree/{boot,efi,isolinux,installer,.disk}
    mkdir -pv isotree/efi/boot/
    touch     isotree/.disk/{base_components,base_installable,cd_type,info,udeb_include}

将安装器相关的启动文件解压到模板目录中
--------------------------------------
```
cd /home/user/debian-installer-20170615+deb9u2/
mkdir tmp && tar -xvpf build/dest/cdrom/gtk/debian-cd_info.tar.gz -C tmp
cp -av      build/dest/cdrom/gtk/{vmlinuz,initrd.gz}    isotree/installer            
mcopy   -i tmp/grub/efi.img ::efi/boot/bootx64.efi isotree/efi/boot/bootx64.efi
mv         tmp/grub/                                   isotree/boot/
cp -av    tmp/*                                        isotree/isolinux/
cp          /usr/lib/ISOLINUX/isolinux.bin             isotree/isolinux/
cp        /usr/lib/syslinux/modules/bios/{ldlinux.c32,libcom32.c32,libutil.c32,vesamenu.c32} isotree/isolinux/
```

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

生成最终定制版本的ISO
---------------------

    cd /home/deepin/debian-installer-20170615+deb9u2/

    xorriso -as mkisofs -r -V 'Debian Custom '                                                                \
        -J -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin                                                      \
        -J -joliet-long                                                                                       \
        -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot                                           \
        -boot-load-size 4 -boot-info-table -eltorito-alt-boot                                                 \
        -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat -isohybrid-apm-hfsplus isotree/              \
        -o debian-custom-minimal-amd64.iso
