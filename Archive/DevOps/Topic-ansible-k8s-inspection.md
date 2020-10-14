# ansible手动巡检k8s集群

在某些私有云客户场景，客户的监控做的非常不完善，有时候主机节点巡检，可以使用ansible或者pdsh等工具快速对集群内所有主机列表进行查询，结合日常工作，常用检查项如下:   

1. 节点批量检查：

* 查看所有主机运行状态: `ansible -i hosts all -m shell -a "uptime;mpstat;free" -o | sort`
* 查看所有主机内核版本：`ansible -i hosts all -m shell -a "hostname -i;uname -r" -o | sort`
* 查看所有主机docker版本：`ansible -i hosts all -m shell -a "docker version | grep version" -o | sort`
* 查看K8S集群节点版本：`ansible -i hosts k8s-m01 -m shell -a "kubectl get nodes"`
* 查看K8S集群pod运行状态：`ansible -i hosts k8s-m01 -m shell -a "kubectl get pods --all-namespaces | grep -v Running"`

2. 批量更改主机密码: 

执行命令: `ansible all -m script -a "change_password.sh"` change_password.sh 脚本参考
```
echo "user:user_new_password" | chpasswd
```

* 找出分区占用过大的的主机: `ansible all -m script -a "check_disk_use.sh" `

check_disk_use.sh 脚本参考
```
df -h  |  awk 'NR>1 { print $5" "$6 }' | while read line
do
        part_use=`echo $line | awk '{print $1}' | awk -F% '{print $1}'`
	part_mount=`echo $line | awk '{print $2}'`
	    
	if [[ ${part_use} -ge 70 ]];then
	    	echo "       Local Dir $part_mount Usage is over $part_use %  "
	fi
done
```

* 列出集群使用的nas存储卷信息: `ansible all -m script -a "check_cluster_nfs_pv.sh" `

check_cluster_nfs_pv.sh 脚本参考
```
df -h  |  awk '{ print $2"" $5" "$6 }' | while read line
do
        part_size=`echo $line | awk '{print $1}' | awk -F% '{print $1}'`
        part_use=`echo $line | awk '{print $2}'  | awk -F% '{print $1}'`
	part_mount=`echo $line | awk '{print $3}'| awk -F "nfs/" '{print $2}'`
        		
        echo -e "$part_mount $part_size $part_use%"
done
```

## 找出集群内的特定pod并重建

当时有这样一个场景，客户切换了数据集群，IP发生变化，当变更了为微服务配置中心配置后，重启了大部分pod，但是要找到对旧数据库IP依旧保持连接的那些pod，找到并重建

执行命令: `ansible -i hostfile master -m script -a "change_password.sh" `  restart_pod.sh 脚本参考

```
#!/bin/bash
ns=$1

for pod in `kubectl get pods -n $ns | awk '{print $1}'`
do
    kubectl exec -t  -i -n $ns $pod  -- sh -c "netstat | grep 11.11.157.138"  &> /dev/null
    if [[ "$?" == "0" ]];then
    　echo " $pod of $ns will be rebuid "
      kubectl delete pods $pod -n $ns
    fi
done
```
