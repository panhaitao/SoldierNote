
# build live kernel and initramfs.img

apt-get install live-boot-initramfs-tools

mkinitramfs -o /initrd.gz kernel_verison

debootstrap --no-check-gpg --include="cat list | tr '\n' ','"  --components=main,restricted,universe,multiverse --arch=amd64 bionic tmp/rootfs file:///root/debian-installer-20101020ubuntu543/isotree/

mksquashfs *  ~/filesystem.squashfs



list 中需要包含live-boot 软件包，未验证
filesystem.squashfs 对应的rootfs 需要创建一个UID大于500 的普通用户，DDE桌面才能启动


