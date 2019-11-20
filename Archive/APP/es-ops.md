# elasticsearch 笔记

## 部署 ES

docker pull elasticsearch:7.2.0
docker run -d --name=es --network=host -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch:7.2.0

docker exec es /bin/bash
```
vi elasticsearch.yml
http.cors.enabled: true
http.cors.allow-origin: "*"
```
docker restart es

## CURL CMD OPTS

curl -XGET http://192.168.43.228:9200/_cluster/settings
curl -XPUT http://192.168.43.228:9200/_cluster/settings  -d '{"persistent":{},"transient":{"logger":{"discovery":"INFO"}}}'


## ES kibana 

### 准备镜像：

1. 查询ES版本 curl http://es_user:es_passwd@es_ip:9200
2. 上传和ES匹配的Kibana的版本
```
docker pull docker.elastic.co/kibana/kibana:6.7.2
docker tag docker.elastic.co/kibana/kibana:6.7.2 <集群镜像仓库地址:端口>/kibana:6.7.2
docker push <集群镜像仓库地址:端口>/kibana:6.7.2
```

###  启动应用

1. 创建 kibana.yml 写入如下内容
```
elasticsearch.username "us_user"
elasticsearch.password  "us_password"
elasticsearch.url: "http://es_ip:9200"
elasticsearch.ssl.verificationMode: none
xpack.monitoring.enabled: true
xpack.graph.enabled: false
xpack.ml.enabled: false
xpack.watcher.enabled: false
xpack.security.enabled: false
server.name: kibana
server.host: "0.0.0.0"
```
2. 创建configmap 执行命令: kubectl create configmap kibana --from-file=kibana.yml --namespace=alauda-system
3. 使用平台创建 kibana deployment 修改写入如下参考配置：  
```
    volumeMounts：
      - mouthPath: /usr/share/kibana/config/
        name: kibana-config
    volumes:
    - configMap:
        defaultMode: 420
        name: kibana
      name:kibana-config 
```
4. 可以定点部署，使用nodeport方式暴漏服务
5. 访问 http://kibana_ip:nodeport 使用es_user用户名 和 es_passwd密码登录使用

## 参考操作实例

登陆 kibana -> Dev tools 
1. 查看集群日志配置：GET /_cluster/settings 点击运行，右侧会返回结果，看是否包含debug配置项
2. 修改集群日志配置：PUT /_cluster/settings
{ "persistent" : \{ }
,
"transient" :
{ "logger.discovery" : "INFO" }
}
确认修改，点击执行，重新执行步骤1 ，确认配置已经变更

api获取：http://ip:9200/_cluster/health?pretty 或者 Kibana的开发工具Dev Tools中执行 ：

查看集群健康状态

GET _cluster/health
### 其他

如果需要注册：可以访问 https://register.elastic.co/，登录到注册的邮件，里面会有一个下载license的邮件。

通过curl，重新续一下license，执行命令 curl -XPUT -u elastic:xxxxxxx 'http://localhost:9200/_xpack/license?acknowledge=true&pretty' -H "Content-Type: application/json" -d @zhang-ying-25352885-1477-48d2-af26-be23ced519b7-v5.json 

### 参考

https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/
https://www.cnblogs.com/luoyan01/p/9734310.html
https://www.elastic.co/guide/en/kibana/6.7/docker.html

## ES存储扩容方案

ES存储扩容 可分为单节点磁盘扩容和 增加集群节点数来实现容量扩容

### 单节点磁盘扩容操作步骤：

1. 先ES节点中所在node任意一节点,标记为不可调度，执行命令，kubectl cordon <node_name>
2. 杀掉运行在不可调度node节点上的ES pod: 执行命令 kubectl delete pod <es_pod_name> -n alauda
3. 检查另外两个ES节点运行状态，执行命令: curl http://es_user:es_passwd@es_ip:9200/_cat/health  确认ES集群对外正常提供服务: 
4. 操作被标记不可调度节点，对ES的挂载点进行数据迁移和分区容量扩容
5. 扩容完毕，恢复node节点正常调度: kubectl uncordon <node_name>
6. 重启扩容后节点上的 es pod, 执行命令 kubectl delete pod <es_pod_name> -n alauda
7. 观察ES集群对外正常提供服务后，重复以上步骤，扩容其他节点

### 增加集群节点数：
          
1. 先向k8s集群新增加一个node节点
2. 为新增节点打标签 log:true 执行命令：kubectl label nodes <node1-name> log=true
3. 修改ES deployment 将pod副本数加一
4. 确认新增节点已经加入ES集群，并且集群整体对外提供服务正常
5. 将新增节点加入平台 global_var 变量中 es.lis列表中，重启alauda-system命名空间下所有pod

## 扩容后对每个ES所在的node节点执行检查项：
 
检查扩容后的ES节点正常提供服务是否正常提供服务：

1. curl http://es_user:es_passwd@es_ip:9200/_cat/health      确认ES节点运行正常
2. curl http://es_user:es_passwd@es_ip:9200/_cat/indices     确认ES节点内索引状态是否正常
3. curl http://es_user:es_passwd@es_ip:9200/_cat/allocation  确认ES节点容量状态是否预期

## 删除索引

1. 删除陈旧索引

登录后台主机节点，执行命令 curl http://es_user:es_passwd@es_ip:9200/_cat/indices 查看所有索引
根据索引日期，清理一周以前的陈旧日志，删除操作执行命令 curl -XDELETE http://es_user:es_password@es_ip:9200/index_name

2. 查询索引的的字段

查询命令 
curl -XGET http://es_user:es_passwd@es_ip:9200/indices_name/_search -H 'Content-Type: application/json' -d'
{ "query": { "match": { "application_name": "应用名" } } }'  ｜jq '.hits.total'

3. 清理索引的字段：

删除命令 curl -XPOST http://es_user:es_passwd@es_ip:9200/indices_name/_delete_by_query -H 'Content-Type: application/json' -d'
{ "query": { "match": { "application_name": "应用名" } } }'

操作步骤中的变量说明

* es_user es_password 是ES的用户名和密码，可以登录global集群master节点，执行命令 kubectl get secrets alauda-es n alauda-system -o yaml 中查询，使用 base64 -d 解码
* es_ip  是global集群es节点ip
* index_name 是要删除的索引名字

部分现场测试数据：

* 从一个40GB大小的ES索引中删除1700万条数据大概需要25分钟，
* 平均每分钟能删除60万条数据
* 按照es集群默认配置：1副本5分片 估算 大约每1000万条数据 占用索引空间10GB
* 以删除7个索引中各自中的1亿条数据计算，每次删除1000条，至少需要42小时能删除完毕
