## ISO版本：

* deepin server 版本(debian8)   http://10.1.10.26/backup/isofs/releases/deepin-server-v15-20180305-amd64.iso
* deepin server 版本(centos6.4) http://10.1.10.26/repo/kui-15-amd64/6.4/deepin-server-enterprise-amd64-15-BJ-20171023-B54.iso 
* deepin server 版本(centos6.8) http://10.1.10.26/repo/kui-15-amd64/deepin-cd/deepin-server-enterprise-amd64-15.2-dvd1.iso 
* deepin server 版本(centos7.4) http://10.1.10.26/repo/TengSnake-16-amd64/isos/deepin-server-enterprise-16-amd64.iso
* deepin server 版本(龙芯版本)  http://10.1.10.26/repo/kui-15-mips64el/deepin-cd/deepin-server-mips64el-15.2-BJ-20170816-B19.iso 

## 仓库:

* 龙芯版本：http://10.1.10.26/repo/kui-15-mips64el/
* V15企业版本: http://10.1.10.26/repo/kui-15-amd64/6.8/
* V16企业版本: http://10.1.10.26/repo/TengSnake-16-amd64/ 

## 安装器

debian： debian-installer
centos:  Anaconda

## 软件包与仓库

* rpm：
  * 打包工具: rpm-build
  * 仓库管理: createrepo

deb: 
  * 打包工具: dpkg-buildpackage
  * 仓库管理: reprepro

## ISO制作方法：

* centos7 系列
```
lorax -p "${ProduceName}" -v ${ReleaseID} -r ${ReleaseID} --isfinal -s https://mirrors.tuna.tsinghua.edu.cn/centos/7.4.1708/os/x86_64/ ./iso-temp/

mkdir -pv iso-temp/Packages/  
yumdownloader --archlist=x86_64 --destdir=iso-temp/Packages/ `cat project/core.list`
rm -rvf iso-temp/Packages/*.i686.rpm
cd iso-temp/ && createrepo -g ../project/minimal-x86_64-comps.xml . && cd ../

genisoimage -U -r -v -T -J -joliet-long                                      \
            -V ${ProduceName} -A ${ProduceName} -volset ${ProduceName}	     \
            -c isolinux/boot.cat    -b isolinux/isolinux.bin                 \
            -no-emul-boot -boot-load-size 4 -boot-info-table                 \
            -eltorito-alt-boot -e images/efiboot.img -no-emul-boot           \
            -o ../centos7-custom-${ReleaseID}-${BuildID}.iso \
	    iso-temp                                                     
implantisomd5 ../centos7-custom-${ReleaseID}-${BuildID}.iso
```

* debian 系列

```
export WORKDIR=/home/panhaitao/debian8-custom-iso-build
export codename=stretch
export repo_url=http://mirrors.ustc.edu.cn/debian/
export installer_url=http://mirrors.ustc.edu.cn/debian/dists/stretch/main/installer-amd64/current/images/cdrom/
export volid='Debian Custom ISO 20180201'
export core="locales,busybox,initramfs-tools,ssh,iptables,linux-image-amd64,grub-pc,grub-efi"
export pkgs="$core,psmisc,vim"
export isoname="Debian-Custom-20180201-amd64"
mkdir -pv ${WORKDIR}/isotree/
mkdir -pv ${WORKDIR}/isotree/{boot,efi,isolinux,installer,.disk}
mkdir -pv ${WORKDIR}/isotree/efi/boot/
touch     ${WORKDIR}/isotree/.disk/{base_components,base_installable,cd_type,info,udeb_include}

# 将安装器相关的启动文件解压到模板目录中

cd ${WORKDIR}/
wget ${installer_url}/debian-cd_info.tar.gz
wget ${installer_url}/initrd.gz
wget ${installer_url}/vmlinuz
mkdir -pv tmp && tar -xvpf debian-cd_info.tar.gz -C tmp
cp    -av ./{vmlinuz,initrd.gz}                                       isotree/installer            
mcopy     -i tmp/grub/efi.img ::efi/boot/bootx64.efi                  isotree/efi/boot/bootx64.efi
mv        tmp/grub/                                                   isotree/boot/
cp -av    tmp/*                                                       isotree/isolinux/
cp        /usr/lib/ISOLINUX/isolinux.bin                              isotree/isolinux/
cp        splash.png                                                  isotree/isolinux/splash.png  
cp        /usr/lib/syslinux/modules/bios/{ldlinux.c32,libcom32.c32,libutil.c32,vesamenu.c32} isotree/isolinux/

# Boot Menu for BIOS

cat > isotree/isolinux/txt.cfg << EOF
default install
label install
	menu label ^Install
	menu default
        kernel /installer/vmlinuz
        append initrd=/installer/initrd.gz vga=788 --- quiet
EOF

# Boot Menu for UEFI

cat >> isotree/boot/grub/grub.cfg << EOF
menuentry 'Install' {
    set background_color=black
    linux    /installer/vmlinuz  vga=788 --- quiet 
    initrd   /installer/initrd.gz
}
EOF

# 获取cdrom需要的deb包和udeb包

sudo ln -sv /usr/share/debootstrap/scripts/sid /usr/share/debootstrap/scripts/$codename

cd ${WORKDIR}/
mkdir tmp/rootfs
sudo debootstrap --no-check-gpg --download-only --include=$pkgs --components=main,non-free,contrib --arch=amd64 $codename tmp/rootfs $repo_url  
#cd tmp/rootfs/var/cache/apt/archives/
#sudo apt-get download `cat $pkgs`

wget ${repo_url}/dists/${codename}/main/debian-installer/binary-amd64/Packages.gz
zcat Packages.gz | grep Filename | awk  '{print $2}' > all_udeb.list
sed -i "s@^@$repo_url/@g" all_udeb.list  
mkdir -pv tmp/udeb/ && wget -i all_udeb.list -P tmp/udeb/

cd isotree/ && mkdir conf
cat > conf/distributions << EOF
Codename: $codename 
Description: cdrom intra repository
Architectures: i386 amd64
Components: main contrib non-free
UDebComponents: main
Contents: .gz
Suite: stable
EOF

reprepro includedeb $codename ../tmp/rootfs/var/cache/apt/archives/*.deb
reprepro includeudeb $codename ../tmp/udeb/*.udeb

echo $volid > .disk/info
find . -type f | grep -v -e ^\./\.disk -e ^\./dists | xargs md5sum >> md5sum.txt

#生成最终定制版本的ISO

cd ${WORKDIR}/
xorriso -as mkisofs -r -V "$volid"                                                                           \
    -J -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin                                                      \
    -J -joliet-long                                                                                       \
    -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot                                           \
    -boot-load-size 4 -boot-info-table -eltorito-alt-boot                                                 \
    -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat -isohybrid-apm-hfsplus isotree/              \
    -o $isoname.iso
```
