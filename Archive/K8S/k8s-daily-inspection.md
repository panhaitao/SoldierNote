# 灵雀云日常维护操作记录

## 查询平台过去一段时间调度次数

使用ACE2.X接口查询
```
curl -XGET -H "Authorization: Token token_str-xxxxxxxx" "http://lb_ip:32001/v2/kevents/?start_time=<unix时间>&end_time=<unix时间>&cluster=<集群名称>&page=1&page_size=1000" | jq ".total_items"
```
* token 在平台用户中心查询 集群名称 ACE2.X版本 参考管理视图-> 集群
* unix时间戳：  
```
当前时间: date +%s
一周前: date -d "1 week ago" +%s
反解时间戳: date -d @<unix 时间戳>
``` 
* unix时间戳参考 
** http://www.linuxso.com/command/date.html
** https://www.cnblogs.com/ckie/p/6552678.html
# 集群操作

## 批量重启集群内所有服务

1. 获取a6_dev_cluster集群中a6-dev项目中的服务总数

```
let NUM=`curl -X "GET" "http://<lb_ip>:20081/v2/services/?cluster=a6_dev_cluster&project_name=a6-dev&page_size=100&num_pages=1" -H 'Authorization:Token 20958ce5dffd231ab5de6a03e9353db016df01b0' | jq '.count'`
```

2. 打印每个服务的对应的名称和UUID

```
for((i=0;i<$NUM;i++))
do
  srv_name=$(curl -X "GET"  "http://<lb_ip>:20081/v2/services/?cluster=a6_dev_cluster&project_name=a6-dev&page_size=100&num_pages=1" -H 'Authorization:Token 20958ce5dffd231ab5de6a03e9353db016df01b0' | jq '.results['$i'].resource.name')
  srv_uuid=$(curl -X "GET"  "http://11.11.174.85:20081/v2/services/?cluster=a6_dev_cluster&project_name=a6-dev&page_size=100&num_pages=1" -H 'Authorization:Token 20958ce5dffd231ab5de6a03e9353db016df01b0' | jq '.results['$i'].resource.uuid')
  echo $srv_name  $srv_uuid
done
```

从以上结果中查询到要操作的服务对应的UUID

3. 停止一个服务
以运行在 a6-dev 项目中的一个服务UUID为　ea849a05-22ac-4977-9f87-da83714bccaf 的服务为例,对服务进行停止操作：
```
curl -X "PUT" "http://<lb_ip>:20081/v2/services/ea849a05-22ac-4977-9f87-da83714bccaf/stop/?project_name=a6-dev" -H 'Authorization:Token 20958ce5dffd231ab5de6a03e9353db016df01b0'
```

4. 启动一个服务
以运行在 a6-dev 项目中的一个服务UUID为　ea849a05-22ac-4977-9f87-da83714bccaf 的服务为例,对服务进行停止操作：
```
curl -X "PUT" "http://<lb_ip>:20081/v2/services/ea849a05-22ac-4977-9f87-da83714bccaf/start/?project_name=a6-dev" -H 'Authorization:Token 20958ce5dffd231ab5de6a03e9353db016df01b0'
```

## 找出集群内的特定pod并重建

在中油项目的时候，当时有这样一个场景，客户切换了数据集群，IP发生变化，当变更了为微服务配置中心配置后，重启了大部分pod，但是要找到对旧数据库IP依旧保持连接的那些pod，找到并更新

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

## 启/停部分节点的日志服务

enable-dd-agent.yaml
```
- name: dd-agent
  hosts: group_name
  tasks:
  - name:  remove disabled-dd-agent crond tasks
    shell: "rm -f /etc/cron.d/dd-agent" 
  - name: restart crond service
    shell: "systemctl restart crond" 
```

disabled-dd-agent.yaml
```
- name: dd-agent
  hosts: group_name
  tasks:
  - name:  add disabled-dd-agent /etc/cron.d
    cron:
      name: disbled dd-agent 
      minute: "*/1"
      user: root
      job: "docker rm dd-agent spectre_3.2 -f &> /dev/null"
      cron_file: dd-agent
  - name: restart crond service
    shell: "systemctl restart crond" 
```

* 停用　dd-agent　监控组件  `ansible-palybook disabled-dd-agent.yaml` 
* 启用　dd-agent　监控组件　`ansible-palybook enable-dd-agent.yaml`


## 列出群内所有服务的资源限额配置

在中石油项目上，经常要求被统计各种信息，docker存储配置，各个组件日志配置，甚至是要求统计部署的服务资源限额配置，

```
NS=$1

for DEPLOY in `kubectl get deploy -n $NS | awk '{print $1}'`
do
  limits=`kubectl get deploy $DEPLOY -n $NS -o=jsonpath='{.spec.template.spec.containers[0].resources.limits}'`
  requests=`kubectl get deploy $DEPLOY -n $NS -o=jsonpath='{.spec.template.spec.containers[0].resources.requests}'`
done
```


# 自动巡检

## 定期巡检k8s集群运行状态

关于自动巡检脚本在是国电通项目上的一个需求，目前国电通项目整体只有k8s集群是使用的我们的，其他部分都是其他公司，为了保证能到巡检k8s集群运行状态，就结合ansible, shell, crond定时计划任务，实现了一套简单的循检脚本，每隔半个小时执行一次，汇总集群主机状态，k8s运行状态等结果， 具体代码可参考　https://github.com/panhaitao/SoldierSuit/tree/master/alauda-k8s-check

```
alauda-k8s-check/
├── etc-crontabs-example        #定时计划任务参考配置
├── k8s-cluster-report-ana.sh　 #分析巡检脚本，汇总巡检结果
├── k8s-cluster-runtasks.sh     #定时计划任务执行的脚本
├── scripts
│   ├── check_k8s_cluser.sh　　 # ansible要执行的用于检查k8s集群状态的脚本
│   └── check_system_stat.sh　　# ansible要执行的用于检查系统运行状态的脚本
└── tasks　　　　　　　　　　　 #考虑到要检查不同的集群，需要分别汇总不同集群的结果
    ├── check_e-cluster.sh　　　#检查e集群需要执行的ansible任务列表
    ├── check_p-cluster.sh　　　#检查p集群需要执行的ansbile任务列表
├── report　　　　　　　　　　　#用于存放汇总后结果
├── result　　　　　　　　　　　#用于存放执行过程的巡检结果
```
