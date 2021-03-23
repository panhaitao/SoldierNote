
# Uk8s 容器集群日志系统

# **环境信息**

1.  Kubernetes：1.18
2.  NFS StorageClass：UFS
3.  Helm：v3.5.2

# 准备工作

1.  如果集群内未创建StorageClass 配置，首先在ucloud 控制台创建UFS存储，选择 k8s集群所在的vpc 子网 创建UFS挂载点，
    1.  StorageClass部署参考 https://github.com/panhaitao/k8s-app/tree/main/deploy-for-k8s/StorageClass-UFS 
    2.  创建修改 deployment.yaml 配置中 挂载点ufs_server_ip 顺序执行如下命令:

```
git clone https://github.com/panhaitao/k8s-app.git
cd k8s-app/deploy-for-k8s/StorageClass-UFS/
kubectl  apply -f deployment.yaml
kubectl  apply -f rbac.yaml
kubectl  apply -f class.yaml

```

2.  如果k8s集群内没有 helm，需要安装helm，推荐使用v3版本，登录一台master，执行如下命令：

```
wget https://mirrors.huaweicloud.com/helm/v3.5.2/helm-v3.5.2-linux-amd64.tar.gz
tar -xf helm-v3.5.2-linux-amd64.tar.gz
mv linux-amd64/helm /usr/bin/

```

# 日志系统部署

## 组件清单

4.  Filebeat: 7.4.1
5.  Logstash: 7.9.3
6.  Kafka：2.0.1
7.  Zookeeper: 3.5.5
8.  UES: 7.4.2

### 部署 filebeat

1.  创建命名空间: kubectl create ns logs
2.  获取 https://helm.elastic.co/helm/filebeat/filebeat-7.4.1.tgz 
3.  创建 filebeat-values.yaml

```
nameOverride: "filebeat"
fullnameOverride: "elk-filebeat"
image: "uhub.service.ucloud.cn/ucloud_pts/filebeat"
imageTag: "7.4.1"
tolerations:
- effect: NoSchedule
  key: node-role.kubernetes.io/master
  operator: Exists

```

helm install filebeat-7.4.1.tgz --generate-name --namespace logs -f filebeat-values.yaml

### 部署logstash

4.  获取 https://helm.elastic.co/helm/logstash/logstash-7.9.3.tgz
5.  创建 logstash-values.yaml

```
nameOverride: "logstash"
fullnameOverride: "elk-logstash"
image: "uhub.service.ucloud.cn/ucloud_pts/logstash"
imageTag: "7.9.3"

service:
  type: ClusterIP
  ports:
    - name: beats
      port: 5044
      protocol: TCP
      targetPort: 5044

```

helm install logstash-7.9.3.tgz --generate-name --namespace logs -f logstash-values.yaml

### 部署kafka

1.  获取kafka chart包 , wget http://mirror.azure.cn/kubernetes/charts-incubator/kafka-0.21.2.tgz
2.  创建kakfa-values.yaml文件，下面是具体的修改点：
    1.  persistence size 调整为合适的大小
    2.  persistence storageClass 设置为 ufs-nfsv4-storage

完整示例如下:

```
nameOverride: "mq"
fullnameOverride: "kafka"
replicas: 3
image: uhub.service.ucloud.cn/ucloud_pts/cp-kafka
imageTag: 5.0.1
tolerations:
- key: node-role.kubernetes.io/master
  operator: Exists
  effect: NoSchedule
- key: node-role.kubernetes.io/master
  operator: Exists
  effect: PreferNoSchedule
persistence:
  storageClass: ssd-csi-udisk
  size: 100Gi
zookeeper:
  nameOverride: "zk"
  fullnameOverride: "zookeeper"
  persistence:
    enabled: true
    storageClass: ufs-nfsv4-storage
    size: 1Gi
  replicaCount: 3
  image:
    repository: uhub.service.ucloud.cn/ucloud_pts/zookeeper
    tag: 3.5.5
  tolerations:
  - key: node-role.kubernetes.io/master
    operator: Exists
    effect: NoSchedule
  - key: node-role.kubernetes.io/master
    operator: Exists
    effect: PreferNoSchedule

```

3.  设置完成，开始部署，执行命令：

```
kubectl create namespace kafka
helm install /root/kafka-0.21.2.tgz --generate-name --namespace kafka -f kafka-values.yaml

```

## Kafka运维

### 管理Topic

请 zookeeper 替换为集群中实际的 zk svc 名字，或 zookeeper svc ip

1.  创建topic：

```
/usr/bin/kafka-topics --create --zookeeper zookeeper:2181 --replication-factor 1 --partitions 1 --topic test001

```

2.  查看当前topic：

```
/usr/bin/kafka-topics --list --zookeeper zookeeper:2181

```

3.  查看名为test001的topic：

```
/usr/bin/kafka-topics --describe --zookeeper zookeeper:32181 --topic test001

```

### 测试验证

Kafka 请替换为集群中实际的 kafka svc 名称，或 kafka svc ip

1.  进入创建消息的交互模式：

```
/usr/bin/kafka-console-producer --broker-list kafka:9092 --topic test001

```

2.  再打开一个窗口，执行命令消费消息：

```
/usr/bin/kafka-console-consumer --bootstrap-server kafka:9092  --topic test001 --from-beginning

```

3.  再打开一个窗口，执行命令查看消费者group：

```
/usr/bin/kafka-consumer-groups --bootstrap-server kafka:9092 --list

```

命令回输出类似的输出：console-consumer-71062

4.  执行命令查看groupid等于console-consumer-71062 的消费情况：

```
/usr/bin/kafka-consumer-groups --group console-consumer-71062 --describe --bootstrap-server kafka:9092

```

# 日志系统配置

### 配置 filebeat

1.  添加 hostPath /data/docker/containers/ kubectl get ds filebeat-xxxxxx -n logs 

```
          - mountPath: /data/docker/containers/
            name: datadockercontainers
            readOnly: true
  - hostPath:
      path: /data/docker/containers/
      type: ""
    name: datadockercontainers

```

kubectl get cm filebeat-7-1614073436-filebeat-config -n logs 添加output.kafka 配置

```
output.kafka:
  enabled: true
  hosts: ['kafka:9092']
  topic: "test001"

```

### 配置 logstash

1.  创建logstash pipeline configmap

```
cat > logstash.conf <<EOF
input {
  kafka {
    bootstrap_servers => 'kafka:9092'
    topics => test001
    codec => json {
            charset => "UTF-8"
        }
  }
}
filter {
    # 将message转为json格式
    if [type] == "log" {
        json {
            source => "message"
            target => "message"
        }
    }
}
output {
  elasticsearch {
    hosts => ["http://elasticsearch_ip:9200"]
    index => "k8s_log-20210223"
  }
}
EOF

kubectl delete cm logstash-pipeline-config -n logs
kubectl create configmap logstash-pipeline-config --from-file=logstash.conf --namespace logs

```

2.  创建logstash pipeline configmap

```
cat > logstash.yml <<EOF
http.host: "0.0.0.0"
xpack.monitoring.elasticsearch.hosts: [ "http://10.10.46.42:9200" ]
EOF
kubectl delete cm logstash-config -n logs
kubectl create configmap logstash-config --from-file=logstash.yml --namespace logs

```

3.  添加logstash configmap卷挂载配置: kubectl edit statefulset.apps/elk-logstash -n logs

```
    volumeMounts:
    - mountPath: /usr/share/logstash/pipeline/logstash.conf
      name: logstash-pipeline-volume
      readOnly: true
      subPath: logstash.conf
    - mountPath: /usr/share/logstash/config/logstash.yml
      name: logstash-volume
      readOnly: true
      subPath: logstash.yml

```

```
      volumes:
      - configMap:
          defaultMode: 420
          name: logstash-pipeline-config
        name: logstash-pipeline-volume
      - configMap:
          defaultMode: 420
          name: logstash-config
        name: logstash-volume

```

# 验证日志服务

![image](https://upload-images.jianshu.io/upload_images/5592768-d977834144d7f815?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image](https://upload-images.jianshu.io/upload_images/5592768-047d505e9c079f6d?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

