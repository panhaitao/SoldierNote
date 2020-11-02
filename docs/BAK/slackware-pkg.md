# slackware 笔记

给 cdlinux 安装好包管理器 

```
#!/bin/bash

function local_install()
{
    export url=$1
    export pkg=$2
 
    wget $url
    tar -xvpf $pkg
    mkdir -pv /lib64/
    mkdir -pv /usr/lib64/
    unalias cp
    cp -av sbin/* /sbin/
    cp -av etc/* /etc/
    cp -av usr/* /usr/
    cp -av lib64/* /lib64/
    cp -av usr/lib64/* /usr/lib64/
    bash install/doinst.sh
    rm -rvf etc/* usr/* install/* 
}


local_install https://software.jaos.org/slackpacks/slackware64-14.2/slapt-get/slapt-get-0.10.2t-x86_64-1.tgz          slapt-get-0.10.2t-x86_64-1.tgz
local_install http://mirrors.ustc.edu.cn/slackware/slackware64-14.2/slackware64/a/pkgtools-14.2-noarch-10.txz         pkgtools-14.2-noarch-10.txz
local_install http://alien.slackbook.org/ktown/14.2/latest/x86_64/deps/gpgme-1.9.0-x86_64-1alien.txz                  gpgme-1.9.0-x86_64-1alien.txz
ln -sv /usr/lib64/libgpgme.so.11.18.0 /usr/lib64/libgpgme.so.11 
local_install http://mirrors.ustc.edu.cn/slackware/slackware64-14.2/slackware64/n/libassuan-2.4.2-x86_64-1.txz        libassuan-2.4.2-x86_64-1.txz
ln -sv /usr/lib64/libassuan.so.0.7.2 /usr/lib64/libassuan.so.0
ln -sv /usr/lib64/libassuan.so.0.7.2 /usr/lib64/libassuan.so
local_install http://mirrors.ustc.edu.cn/slackware/slackware64-14.2/slackware64/n/gnupg2-2.0.30-x86_64-1.txz          gnupg2-2.0.30-x86_64-1.txz
local_install http://mirrors.ustc.edu.cn/slackware/slackware64-14.2/slackware64/n/gnupg-1.4.20-x86_64-1.txz           gnupg-1.4.20-x86_64-1.txz
local_install http://mirrors.ustc.edu.cn/slackware/slackware64-14.2/slackware64/l/libtermcap-1.2.3-x86_64-7.txz       libtermcap-1.2.3-x86_64-7.txz
cp /lib64/libtermcap.so.2.0.8 /lib/libtermcap.so.2

cp /etc/slapt-get/slapt-getrc.new /etc/slapt-get/slapt-getrc

mkdir -pv /var/log/packages/
slapt-get --add-keys
slapt-get --update
```

安装软件包： slapt-get -i xf86-video-amdgpu-1.1.0-x86_64-1
