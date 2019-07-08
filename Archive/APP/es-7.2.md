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

## ES-kibana 

docker pull docker pull kibana:7.2.0
docker run -d --name kibana -p 5601:5601 kibana:7.2.0

参考操作实例，登陆 kibana -> Dev tools 
1 查看集群日志配置：GET /_cluster/settings 点击运行，右侧会返回结果，看是否包含debug配置项
2 修改集群日志配置：PUT /_cluster/settings
{ "persistent" : \{ }
,
"transient" :
{ "logger.discovery" : "INFO" }
}
确认修改，点击执行，重新执行步骤1 ，确认配置已经变更
