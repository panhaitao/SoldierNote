## 集群管理: 使用Rancher 对接已有k8s集群

1.  部署好 RancherSever (文中以域名 rancher.admin.com 为例)
2.  目标 k8s集群提前导入镜像: rancher/rancher-agent:v2.5.6 
3.  DNS中设置 RancherSever 域名解析,或在k8s集群节点中添加本地域名解析，修改/etc/hosts

```
xx.xx.xx.xx rancher.admin.com

```

4.  k8s集群CoreDNS中添加域名解析, 执行命令: kubectl edit cm coredns -n kube-system 添加如下参考配置

```
hosts {
xx.xx.xx.xx rancher.admin.com
}

```

## 登陆Rancher控制台

![image](https://upload-images.jianshu.io/upload_images/5592768-ae1f1152d745ff03?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

集群 -> 添加集群 -> 导入，设置集群名称

![image](https://upload-images.jianshu.io/upload_images/5592768-b26d0d7fb8f41eac?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image](https://upload-images.jianshu.io/upload_images/5592768-7760c478fb74f55c?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

执行集群导入操作：

![image](https://upload-images.jianshu.io/upload_images/5592768-5114dd6aaea95803?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

检查rancher-agent 运行状态，执行命令: kubectl get pods -n cattle-system

```
[root@10-8-179-140 ~]# kubectl  get pods -n cattle-system
NAME                                   READY   STATUS    RESTARTS   AGE
cattle-cluster-agent-b586c8b94-22vmj   1/1     Running   0          8m11s

```

回到rancher-server检查导入集群的状态，显示 Active 为就绪状态

![image](https://upload-images.jianshu.io/upload_images/5592768-498b7c9a20037d1c?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



