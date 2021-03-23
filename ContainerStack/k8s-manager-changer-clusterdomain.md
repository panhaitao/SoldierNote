# k8s集群变更 clusterDomain 

## 变更部分

变更k8s集群 clusterDomain 

1. 所有node节点: /etc/kubernetes/kubelet.conf 字段 clusterDomain
2. 修改configmap coredns 中的配置项  kubernetes cluster.local 
   确保 configmap coredns字段和node节点变更一致
变更步骤
3. 所有node节点修改配置：/etc/kubernetes/kubelet.conf 
   例如：将字段 clusterDomain: cluster.local 修改为 clusterDomain: custom.net 
4. 所有node节点重启kubelet服务，执行命令：systemctl restart kubelet
5. 登录master node 修改coredns configmap，执行命令：kubectl edit cm/coredns -n kube-system
   例如：将字段  kubernetes cluster.local 修改为自定义域名，例如  custom.net
6. 最后重启集群所有pod，执行命令：kubectl  delete pods --all -A

## 验证变更是否生效

重启集群所有pod,确认集群状态正常后:

## 检查点：

1. 在集群 pod 内查看 /etc/resolv.conf  中 cluster.local  是否替换为自定域名
2. 进入任意一个组件容器，例如 coredns:  kubectl exec -it uk8s-kubectl-xxxxxx-xxxxx -n kube-system /bin/sh  使用 ping 来验证变更后的域名解析是否正常，如 
nslookup kubernetes.default.svc.custom.net
nslookup kube-dns.kube-system.svc.custom.net
