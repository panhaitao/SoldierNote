---
title: CentOS 系统定制完全指南
categories: 发行版
---

# centos6

## create anaconda boot images

```
/usr/lib/anaconda-runtime/buildinstall --version 15 --brand "ProdueName" --product "ProdueName" --release 2 --final --output /opt /repo/
```

## create iso 

```
rm -rvf iso-temp/packages/*
yum clean all && yum update

yumdownloader `cat project/pkg.list` --destdir=iso-temp/packages/ 
cd iso-temp/ && createrepo -g ../project/dvd-comps.xml . && cd ../

xorriso -as mkisofs                                                      \
         -V 'centos6-server-custom-install'                              \
         -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin                   \
	 -c isolinux/boot.cat -b isolinux/isolinux.bin                   \
         -no-emul-boot -boot-load-size 4 -boot-info-table                \
	 -eltorito-alt-boot -e efiboot.img -no-emul-boot                 \
	 -isohybrid-gpt-basdat                                           \
	 iso-temp                                                        \
         -o centos6-server-custom-install.iso

implantisomd5 centos6-server-custom-install.iso
```

# centos7

全部该皮换面所需修改软件包列表

* adwaita-icon-theme-3.22.0-2.el7.centos.src.rpm  # 替换自定义 icon   
* anaconda-21.48.22.121-6.el7.centos.src.rpm
    * 修改自定义样式     /usr/share/anaconda/anaconda-gtk.css      
    * 添加自定义修改实例 pyanaconda/installclasses/custom.py 
    * 参考: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html-single/anaconda_customization_guide/index
* centos-bookmarks-7-1.el7.centos.src.rpm         # firefox默认书签
* centos-indexhtml-7-9.el7.centos.src.rpm         # firefox默认主页 
* centos-logos-70.0.6-8.el7.centos.src.rpm        # 默认主题背景资源
* centos-release-7-4.1708.el7.centos.src.rpm      # 产品名称标志
* firefox-52.4.0-1.el7.centos.src.rpm             # 首次启动主页
* grub2-2.02-0.64.el7.centos.src.rpm              # 定义 /boot/efi/EFI/目录： 修改 efidir变量
* shim-12-2.el7.centos.src.rpm                    # 定义 /boot/efi/EFI/目录： 修改 efidir变量
* shim-signed-12-3.el7.centos.src.rpm             # 定义 /boot/efi/EFI/目录： 修改 efidir变量

##  create anaconda boot images
```
lorax -p "ProdueName" -r 16 -v 16 --isfinal -s http://10.1.10.26/repo/TengSnake-16-amd64/os/ iso-temp
```

构建完成后在 iso-temp 生成如下目录和文件

```
 .discinfo
 .treeinfo
├── EFI
│   └── BOOT
├── images
│   ├── boot.iso
│   ├── efiboot.img
│   └── pxeboot
│       ├── initrd.img
│       └── vmlinuz
├── isolinux
│   ├── initrd.img
│   └── vmlinuz
└── LiveOS
    └── squashfs.img
```

## 一键制作ISO的脚本

```bash

rm -rvf iso-temp/Packages/*
yum clean all && yum update

mkdir -pv iso-temp/Packages/
yumdownloader --archlist=x86_64 --destdir=iso-temp/Packages/ `cat project/dvd-pkg.list`
rm -rvf iso-temp/Packages/*.i686.rpm
cd iso-temp/ && createrepo -g ../project/dvd-comps.xml . && cd ../

genisoimage -U -r -v -T -J -joliet-long                                   \
            -V DEEPINOS -A DEEPINOS -volset DEEPINOS                      \
            -c isolinux/boot.cat    -b isolinux/isolinux.bin              \
            -no-emul-boot -boot-load-size 4 -boot-info-table              \
            -eltorito-alt-boot -e images/efiboot.img -no-emul-boot        \
            -o  centos7-server-custom-install.iso \
            iso-temp
implantisomd5  centos7-server-custom-install.iso

#isohybrid  centos7-server-custom-install.iso
#isohybrid --uefi  centos7-server-custom-install.iso

rm -rvf iso-temp/Packages/*
```
