# K8S版本升级

## 准备工作

* (以升级到1.13.10为例)同步公网镜像同步到集群私有仓库，需要同步镜像如下：

```
index.alauda.cn/claas/kubebin:v1.13.10
index.alauda.cn/claas/kube-proxy:v1.13.10
index.alauda.cn/claas/kube-apiserver:v1.13.10
index.alauda.cn/claas/kube-controller-manager:v1.13.10
index.alauda.cn/claas/kube-scheduler:v1.13.10
index.alauda.cn/claas/coredns:1.2.6
index.alauda.cn/claas/etcd:3.2.24
```
   
* 运行容器实例 docker run -itd index.alauda.cn/claas/kubebin:v1.13.10 将容器内/systembin/下的kubeadm，kubelet，kubectl二进制文件拷出来，并传到集群内所有节点的/tmp下
   
## 在集群master-1执行命令：
kubectl edit configmap -n kube-system kubeadm-config  完全删除etcd部分，例如：
        
```
etcd:
      external:
        caFile: /etc/kubernetes/pki/etcd/ca.crt
        certFile: /etc/kubernetes/pki/etcd/peer.crt
        endpoints:
        - https://192.168.0.5:2379
        - https://192.168.0.12:2379
        - https://192.168.0.16:2379
        keyFile: /etc/kubernetes/pki/etcd/peer.key
```
在<apiEndpoints:>下添加其他master节点的信息，例如：
```
apiEndpoints:
      ace-master-1:
        advertiseAddress: 10.0.128.98
        bindPort: 6443
      ace-master-2:
        advertiseAddress: 10.0.128.251
        bindPort: 6443
      ace-master-3:
        advertiseAddress: 10.0.129.176
        bindPort: 6443
```

### 升级master-1节点

执行/tmp/kubeadm  upgrade apply v1.13.10 完成升级，
升级成功后先将停掉kubelet 执行命令 systemctl stop kubelet
替换旧版本kubelet  执行命令 cp /tmp/kubelet $(which kubelet) 
重启kubelet服务,执行命令 systemctl daemon-reload && systemctl restart kubelet 
检查master-1的k8s版本是否为1.13.10,执行命令 kubectl get no 

### 升级master-2，3.节点

将master-1上的/etc/kubernetes/manifests目录拷贝到master-2节点同位置目录
修改 /etc/kubernetes/manifests目录 etcd.yaml和kube-apiserver.yaml 中的相关ip换成本机的ip
停掉kubelet 执行命令 systemctl stop kubelet
替换旧版本kubelet  执行命令 cp /tmp/kubelet $(which kubelet) 
重启kubelet服务,执行命令 systemctl daemon-reload && systemctl restart kubelet 
检查master-2的k8s版本是否为1.13.10,执行命令 kubectl get no 

### 升级所有node节
       
替换旧版本kubelet  执行命令 cp /tmp/kubelet $(which kubelet) 
重启kubelet服务,执行命令 systemctl daemon-reload && systemctl restart kubelet 

## 以上操作用ansible-playbook执行

1. 获取playbook `git clone https://github.com/panhaitao/ansible-playbook-store.git`
2. 编辑 hosts 根据实际情况修改
```
[master]
k8s-m01		ansible_ssh_host=10.213.0.192
k8s-m02		ansible_ssh_host=10.213.0.193
k8s-m03		ansible_ssh_host=10.213.0.194
[node]
k8s-s01		ansible_ssh_host=10.213.0.194
k8s-s02		ansible_ssh_host=10.213.0.195
k8s-s03		ansible_ssh_host=10.213.0.196

[all:vars]
ansible_connection=ssh
ansible_ssh_user=root
ansible_ssh_pass="host_password"
init_ip=10.213.0.191
init_host=devcpaas-ace-init
master_ip=10.213.0.191
master_host=k8s-m01
```
3. 执行playbook 
```
ansible-playbook -i hosts tasks/k8s-1.13.10/upgrade-prep.yaml -e master_host=k8s-m01 -e group=all
ansible-playbook -i hosts tasks/k8s-1.13.10/upgrade-master-1.yaml -e host=k8s-m01
ansible-playbook -i hosts tasks/k8s-1.13.10/upgrade-master.yaml -e host=k8s-m02
ansible-playbook -i hosts tasks/k8s-1.13.10/upgrade-master.yaml -e host=k8s-m03
ansible-playbook -i hosts tasks/k8s-1.13.10/upgrade-node.yaml -e group=node
```
