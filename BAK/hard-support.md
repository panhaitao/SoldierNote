## 安装过程加载加载驱动 

## 安装后的系统解决驱动加载问题

* debian系列: 修改 /etc/initramfs-tools/modules 文件 添加内核模块 后执行 update-initramfs -u 生成新的内核模块

## 禁用显卡驱动

* 内核黑名单禁用驱动
* xserver 驱动so文件 位置 /usr/lib/xorg/modules/drivers/  
