# 容器安全实践

# 操作系统安全:

## 节点服务用户统计及普通用户运行权限创建
 
node节点 docker kubelet 需要以 root身份运行，默认不能改变, 普通用户执行权限更改方式如下：

* 创建应用管理员账户，执行命令: usderadd cpaas ; paaswd cpaas
* 加入docker组，执行命令:  usermod cpaas -G docker
* 增加 k8s管理权限，无需操作，默认可以执行kubectl命令即可
* 管理本地应用数据:  加入 sudo配置，修改 /etc/sudoers 添加如下配置：cpaas ALL=(ALL)    /bin/rm /cpaas/*,  /bin/rm -r /cpaas/* 

## 容器内用户统计及平台组件开启特权模式统计

1、统计所有容器组件 dockerfile 默认运行用户,  统计脚本：

```
for pod in `kubectl get pods -n cpaas system`
do
  echo -e $pod
  kubectl exec -t -i -n cpaas-system $pod whoami
done
```

## 容器内非root用户运行的组件 

```
kube-prometheus-exporter-node     nobody
prometheus-operator               nobody
nginx-ingress                     www-data
其他全部是root用户运行的组件
```

## 以下特权模式运行的容器组件（开启privileged参数）

kubectl get pod -A -o yaml >all.yaml ; cat all.yaml | grep -C 20 privileged .其中kube-proxy和kube-apiserver有开provileged=true。gpu-quota容器的一个初始化容器有开provileged=true，其他组件容器没有。

## 其他

其中kube-proxy和kube-apiserver有开provileged=true。gpu-quota容器的一个初始化容器有开provileged=true，其他组件容器没有。开特权模式的容器，是否存在风险？如何避免?
