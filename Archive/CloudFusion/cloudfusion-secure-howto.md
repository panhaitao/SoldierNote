# 容器安全实践

# 操作系统安全:

1. root用户: node节点 docker kubelet 需要以root身份运行
2. 限定权限的管理员用户
* 执行命令: usderadd cpaas ; paaswd cpaas
* 加入docker组，执行命令:  usermod cpaas -G docker
* 增加 k8s管理权限，无需操作，默认可以执行kubectl命令即可
* 管理本地应用数据:  加入 sudo配置，修改 /etc/sudoers 添加如下配置：cpaas ALL=(ALL)    /bin/rm /data/*,  /bin/rm -r /data/*

# 容器内安全

1. 统计所有容器组件 dockerfile 默认运行用户,  统计脚本：
```    
for pod in `kubectl get pods -n ns-name
do
      echo -e $pod
      kubectl exec -t -i -n cpaas-system $pod whoami
done
```
2. 统计容器内非root用户运行的组件 , 
            
* kube-prometheus-exporter-node     nobody
* prometheus-operator                          nobody
* nginx-ingress                                        www-data
其他全部是root用户运行的组件

3. 统计以特权模式运行的容器组件（开启privileged参数） kubectl pod 
