# k8s 集群日常管理与维护


## 场景一：master1节点被clean.sh脚本清空

恢复操作:
1. 登录其他任意个一个正常的master节点 执行命令 kubeadm token create --print-join-command 提取 --token 后面的值记录
2. 先使用ake恢复,例如：chmod 755 /root/ake && /root/ake addnodes --nodes=节点 --ssh-port=22 --ssh-username=root --ssh-password=密码 --token=上一步骤的token --apiserver=10.213.109.14:6443 --registry=10.213.107.207:60080 --pkg-repo=http://10.213.107.207:7000/yum --debug --dockercfg=/etc/docker/daemon.json -kv v1.13.4 
3. 重新初始化master ，从 第一步 kubeadm token create --print-join-command 执行输出加 --experimental-control-plane --ignore-preflight-errors=all 例如：kubeadm join 10.213.109.14:6443 --token 3mpkg6.z0sr4tqep9aibgdb --discovery-token-ca-cert-hash sha256:58f1293d132b5c83cb93474db5fdf1f7c925c79c05fb6868f184822dab65553a --experimental-control-plane --ignore-preflight-errors=all 
4. 最后恢复nsx-agent 重装 rpm -ivh nsx-cni-2.4.0.12511604-1.x86_64.rpm --force 

## 场景二: master节点dockerd进程还在，所有容器实例已经没有了

恢复操作:
1. 使用kubeadm　拉起所有k8s核心服务kubeadm alpha phase controlplane all --config /etc/kubeadm/kubeadm_config.yaml
2. 重启　kubelet 服务
3. 检查确认etcd工作正常,master1功能恢复
