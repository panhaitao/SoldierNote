### 配置Uhub镜像加速

* 登陆 https://console.ucloud.cn/ 从全部产品中找到, 容器镜像库-UHub
* 用户镜像-> 镜像库名称 -> 新建镜像仓库，比如起个名字k8srepo(Ucloud这个名字我已经占用了),在k8srepo仓库下配置镜像加速规则
```
源镜像 quay.io/external_storage/nfs-client-provisioner:latest 目标镜像 k8srepo/nfs-client-provisioner:latest
```

### 申请UFS

登陆 https://console.ucloud.cn/ 从全部产品中找到, 文件存储 UFS -> 创建文件系统
```
文件系统名称: 自定义
存储类型: 选择SSD性能型
付费方式: 如果是测试可以选择按时付费
容量: 100GB起  
```
确认后，点击新建的UFS，找到挂在信息 -> 添加挂载点 ->  选择和主机所在网络一致的VPC,Subnet, 添加完毕后记录挂载地址, 示例如下10.10.154.165:/ 

### 创建nfs-storageclass-provisioner

登陆任意一个k8s master 执行命令: git clone https://github.com/panhaitao/k8s-app.git

* 编辑k8s-app/deploy/deployment.yaml
```
image: quay.io/external_storage/nfs-client-provisioner:latest 修改为 image: uhub.service.ucloud.cn/k8srepo/nfs-client-provisioner:latest
NFS_SERVER 的value 改为 UFS Server IP
NFS_PATH 的value 改为 /
```

配置修改完成后，执行命令:
```
cd k8s-app/deploy/ ; kubectl apply -f rbac.yaml deployment.yaml class.yaml
```
更多参考 https://docs.ucloud.cn/uk8s/volume/dynamic_ufs
