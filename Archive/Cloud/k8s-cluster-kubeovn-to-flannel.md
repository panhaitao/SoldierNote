# k8s 网络


kube-ovn切换flannel 实施方案文档

## 卸载kube-ovn

* 登陆集群master节点,执行如下操作：

```
kubectl delete mutatingwebhookconfigurations.admissionregistration.k8s.io metis
bash cleanup.sh
kubectl delete deployment.apps/kube-ovn-controller -n kube-ovn
kubectl delete deployment.apps/ovn-central -n kube-ovn
kubectl delete daemonset.apps/ovs-ovn daemonset.apps/kube-ovn-pinger daemonset.apps/kube-ovn-cni service/ovn-sb service/ovn-nb service/kube-ovn-pinger -n kube-ovn
kubectl delete pods --all -n kube-ovn
```

* 登陆集群所有节点，执行如下命令后，重启节点

```
rm /etc/cni/net.d/00-kube-ovn.conflist -f
rm -rf /var/run/openvswitch -f
rm -rf /etc/origin/openvswitch/ -f
rm -rf /etc/openvswitch -f
```

* 部署flannel

修改补丁包 cni-flannel-cm.yml   的 Network 配置，更改为和准备工作记录的 CIDR 一致
依次执行命令:

```
kubectl apply  -f cni-flannel-rbac.yaml
kubectl apply  -f cni-flannel-cm.yml
kubectl apply  -f cni-flannel.yml
```

删除集群所有pod
确认所有pod 重新运行后，检查集群状态，和平台功能
