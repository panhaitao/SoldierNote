# 使用grub2制作启动U盘
====================

原理概述：将U盘格式为GPT类型的分区，添加bios引导支持的启动分区和EFI引导分区，然后将grub2引导程序安装到U盘上，引导借助grub的loopback模块来读取U盘分区内ISO文件的内容，完成安装器的引导，从而达到灵活制作启动U盘的目标，并且后续更新ISO只需要替换ISO文件即可，目前在centos7测试通过，具体步骤如下

* 在U盘上创建GPT类型的分区
------------------------

  分区     文件系统类型   大小      启动标志    分区标签
  -------- -------------- --------- ----------- --------------------
  分区一   fat32          4M        bios-grub   
  分区二   fat32          64M       boot esp    
  分区三   ext4           &gt; 5G               CentOS\x207\x20x86_64

* grub 引导程序安装到U盘上
---------------------------

    mount /dev/sdb3 /mnt/
    mkdir /mnt/EFI/
    mount /dev/sdb2 /mnt/EFI

安装EFI引导文件，操作参考如下，需要使用grub-efi软件包提供的命令：

    grub-install --removable --boot-directory=/mnt/ --efi-directory=/mnt/EFI/ /dev/sdb

安装BIOS引导文件，操作参考如下，需要使用grub-pc软件包提供的命令：

    grub-install --removable --boot-directory=/mnt/ /dev/sdb

最后将ISO文件拷贝到 /mnt/ 目录，在/mnt/grub/ 目录下创建 grub.cfg
启动菜单文件

* grub.cfg 参考实例
-----------------

    menuentry "Centos7 (Auto Install for EFI)" {
        insmod ext2
        insmod loopback
        set isofile=/CentOS-7-x86_64-DVD-1708.iso
        loopback loop $isofile
        linuxefi (loop)/images/pxeboot/vmlinuz inst.stage2=hd:LABEL=CentOS\x207\x20x86_64:/$isofile inst.ks=hd:LABEL=CentOS\x207\x20x86_64:/ks-uefi-install.cfg noeject 
        initrdefi (loop)/images/pxeboot/initrd.img
    }

    menuentry "Centos7 (Auto Install for BIOS)" {
        insmod ext2
        insmod loopback
        insmod iso9660
        set isofile=/CentOS-7-x86_64-DVD-1708.iso
        loopback loop $isofile
        linux (loop)/isolinux/vmlinuz inst.stage2=hd:LABEL=CentOS\x207\x20x86_64:/$isofile inst.ks=hd:LABEL=CentOS\x207\x20x86_64:/ks-bios-install.cfg noeject 
        initrd (loop)/isolinux/initrd.img
    }

# 使用dd工具制作启动U盘
=====================

-   针对BIOS主板的U盘启动制作方式：

<!-- -->

     isohybrid CentOS-7-x86_64-DVD-1708.iso
     dd if=CentOS-7-x86_64-DVD-1708.iso of=/dev/sdX

-   针对UEFI主板的U盘启动制作方式

<!-- -->

    isohybrid --uefi CentOS-7-x86_64-DVD-1708.iso
    dd if=CentOS-7-x86_64-DVD-1708.iso of=/dev/sdX

# 使用syslinux工具制作启动U盘
===========================

首先确保系统已经安装 syslinux 和 dosfstools 两个软件包

    mkfs.vfat /dev/sdb1 
    syslinux -i /dev/sdb1
    fatlabel /dev/sdb1 CentOS\x207\x20x86_64
    parted /dev/sdb set 1 boot on
    dd if=/usr/lib/SYSLINUX/mbr.bin of=/dev/sdb conv=notrunc bs=440 count=1 

其中notrunc的含义是，如果目标文件比来源文件大，不截断之后内容

-   将ISO中全部文件，包括两个隐藏文件（.discinfo 和 .treeinfo )
    拷贝到U盘分区
-   然后将U盘中的isolinux目录重命名为syslinux,将syslinux目录内的isolinux.cfg
    重命文件名为 syslinux.cfg
