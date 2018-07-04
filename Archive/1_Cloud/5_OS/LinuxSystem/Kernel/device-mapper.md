
##  Device Mapper

Device Mapper 是 从linux 内核支持逻辑卷管理的通用设备映射机制，它为实现用于存储资源管理的块设备驱动提供了一个高度模块化的内核架构。整个 device mapper 机制由两部分组成:
1. 内核空间的 device mapper 驱动
2. 用户空间的device mapper 库以及它提供的 dmsetup 工具

* Device mapper 内核空间空间相关部分 是一个一个模块化的 target driver 插件实现对 IO 请求的过滤或者重新定向等工作，当前已经实现的 target driver 插件包括：
  * 软 raid
  * 软加密
  * 逻辑卷条带
  * 多路径
  * 镜像
  * 快照等

* Device mapper 用户空间相关部分主要负责配置具体的策略和控制逻辑，比如逻辑设备和哪些物理设备建立映射，怎么建立这些映射关系等等，而具体过滤和重定向 IO 请求的工作由内核中相关代码完成。


## docker direct-lvm 


1. 安装好 docker 的服务器上，配置 direct-lvm
2. 先停掉 docker 服务，删除/var/lib/docker 目录（如果graph 参数指定了 docker root 目录在其他位置，一样删掉）
3. 创建lvm (假设分配给lvm 的设备是/dev/sdb）

``` 
pvcreate /dev/sdb                                                                            
vgcreate docker /dev/sdb                                                                     
vgdisplay docker
lvcreate --wipesignatures y -n thinpool docker -l 90%VG
lvcreate --wipesignatures y -n thinpoolmeta docker -l 5%VG
lvconvert -y --zero n -c 512K --thinpool docker/thinpool --poolmetadata docker/thinpoolmeta

```
* 创建 pv  /dev/sdb
* 创建 vg  名为docker
* 创建 lv，在名字叫 docker 的 vg 上创建名字叫 thinpoolmeta 的 lv，并指定这个 lv 使用的空间是 vg 的5%，
* 创建 lv ，在名字叫 docker 的 vg 上创建名字叫 thinpool 的 lv，并指定这个 lv 使用的空间是 vg 的90%，
* --wipesignatures y 参数的意思是擦除signatures
* 将pool转换为thinpool， 
  * -c 参数指定块大小 
  * --zero n 参数清理控制块
  * --thinpool  参数指定精简池的名字是 docker/thinpool 
  * --poolmetadata 参数指定了池的元数据的 lv 的名字是 docker/thinpoolmeta

## 配置thinpoo 配置池的自动扩展

```
mkdir -p /etc/lvm/profile/
cat > /etc/lvm/profile/docker-thinpool.profile <<EOF
activation {
thin_pool_autoextend_threshold=80
thin_pool_autoextend_percent=20
}
EOF
```

## 应用配置变更
lvchange --metadataprofile docker-thinpool docker/thinpool   

* 通过文件名是docker-thinpool 的配置文件，更新逻辑卷的属性

## 状态检查

lvs -o+seg_monitor

## 


lvm thin pool 如何删除
Skip to end of metadata
Created by Zheng Wang, last modified on Jan 04, 2018 Go to start of metadata
用direct lvm，重装docker，会发生Base Device UUID and Filesystem verification failed的问题，导致docker起不来。这样处理。

systemctl stop docker

vgcfgbackup -f  vg.bak   docker

修改vg.bak，把里面thin相关的lv内容删除

vgcfgrestore -f vg.bak docker

dmsetup remove docker-thinpool

dmsetup remove docker-thinpool_tmeta

dmsetup remove docker-thinpool_tdata

到这一步，lv就删除掉了。然后按照文档重建lv

lvcreate --wipesignatures y -n thinpool docker -l 90%VG 
lvcreate --wipesignatures y -n thinpoolmeta docker -l 5%VG

lvconvert -y --zero n -c 512K --thinpool docker/thinpool --poolmetadata docker/thinpoolmeta

然后systemctl start docker，就应该可以启动了。

##  参考文档

* IBM 文档  ：https://www.ibm.com/developerworks/cn/linux/l-devmapper/index.html
* 用户态工具： dmsetup https://blog.csdn.net/richardysteven/article/details/7937249
