# 使用ansible对平台运维进行定期巡检

   在客户现场运维的时候，经常面临各种各样的问题，有些甚至是不断重复的机械劳动,这个时候就需要我们想尽办法去偷懒，去达到即快又好的解决问题，又能让自己在客户现场运维的节奏更轻松，更自在些！

## 主机节点巡检

主机节点巡检，可以使用ansible或者pdsh等工具快速对集群内所有主机列表进行查询，结合日常工作，常用检查项如下:   

### 使用ansible shell 模块做批量检查：

* 查看所有主机运行状态: `ansible -i hosts all -m shell -a "uptime;mpstat;free" -o | sort`
* 查看所有主机内核版本：`ansible -i hosts all -m shell -a "hostname -i;uname -r" -o | sort`
* 查看所有主机docker版本：`ansible -i hosts all -m shell -a "docker version | grep version" -o | sort`
* 查看K8S集群节点版本：`ansible -i hosts k8s-m01 -m shell -a "kubectl get nodes"`
* 查看K8S集群pod运行状态：`ansible -i hosts k8s-m01 -m shell -a "kubectl get pods --all-namespaces | grep -v Running"`

### 使用ansible script 模块做批量检查等操作：

* 批量更改主机密码: `ansible all -m script -a "change_password.sh"`

change_password.sh 脚本参考
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

### 使用ansible playbook 做集群日常维护：

* 获取playbook，执行命令:`git clone https://github.com/panhaitao/ansible-playbook-store.git`
cd ansible-playbook-store/
* 为所有主机添加ssh key: ansible-playbook -i hosts tasks/ssh/ssh-key.yaml -e hostgroup=all
* 为所有主机添加ssh key: ansible-playbook -i hosts tasks/hosts/change-hostname.yaml -e hostgroup=all
* tasks/hosts/hosts.yaml hostgroup=all
* tasks/apt/apt.yaml hostgroup=all
