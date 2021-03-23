# 构建Loki日志系统

日志系统，从产生到检索，主要经历以下几个阶段：

采集 -> 传输/缓冲 -> 处理 -> 存储 -> 检索

日志流: filebeat -> kakfa -> logtash -> loki -> grafana

# 部署日志agent

```
helm repo add elastic https://helm.elastic.co
helm repo update

cat > filebeat-values.yaml <<EOF
nameOverride: "filebeat"
fullnameOverride: "elastic-filebeat"
tolerations:
- effect: NoSchedule
  key: node-role.kubernetes.io/master
  operator: Exists

filebeatConfig:
  filebeat.yml: |
    filebeat.inputs:
    - type: container
      paths:
        - /data/docker/containers/*/*-json.log
      processors:
      - add_kubernetes_metadata:
          in_cluster: true
          matchers:
          - logs_path:
              logs_path: "/data/docker/containers/"

    output.logstash:
      hosts: ["172.17.223.225:5044"]
EOF
helm upgrade --install filebeat elastic/filebeat  --values=filebeat-values.yaml -n loki

```

# 部署fluent-bit

```
helm upgrade --install fluent-bit loki/fluent-bit --set "loki.serviceName=loki.svc.cluster.local" -n loki  

```

# 部署Loki-logstash

```
helm repo add elastic https://helm.elastic.co
helm repo update
cat > logstash-values.yaml <<EOF
replicas: 2
image: "grafana/logstash-output-loki"
imageTag: "1.0.1"
logstashPipeline:
  logstash.conf: |
    input {
      beats {
      port => "5044"
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
    if [@metadata][beat] == "journalbeat" {
        mutate {
          add_field => {  host_name => "%{[host][name]}" }
        }
    }
    if [@metadata][beat] == "journalbeat" and [systemd][unit] == "kubelet.service" {
        mutate {
            add_field => { journal_log => "kubelet" } 
        }
    }
    if [@metadata][beat] == "journalbeat" and [systemd][unit] == "docker.service" {
        mutate { 
            add_field => { journal_log => "docker" }
        }
    }

    if [kubernetes] {
          mutate {
            add_field => {
              "container_name" => "%{[kubernetes][container][name]}"
              "namespace" => "%{[kubernetes][namespace]}"
              "pod" => "%{[kubernetes][pod][name]}"
            }
          }
        }
    }
    output {
      loki {
        url => "http://172.17.175.193:3100/loki/api/v1/push"
      }
    }
service:
  type: ClusterIP
  ports:
    - name: beats
      port: 5044
      protocol: TCP
      targetPort: 5044
    - name: http
      port: 8080
      protocol: TCP
      targetPort: 8080  
EOF

helm upgrade --install logstash elastic/logstash --values=logstash-values.yaml -n loki        

```

Ingress 支持TCP https://segmentfault.com/a/1190000038582391

# 部署Loki- Grafana

```
helm repo add loki https://grafana.github.io/loki/charts
helm repo update
kubectl  create ns loki
cat > loki-stack-values.yaml <<EOF
filebeat:
  enabled: false
promtail:
  enabled: false
logstash:
  enabled: false
loki:
  enabled: true
grafana:
  enabled: true
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
    labels: {}
    path: /
    hosts:
      - grafana.loki.admin.com
EOF

helm upgrade --install loki-stack loki/loki-stack --values=loki-stack-values.yaml -n loki

```

使用US3需要先创建 Bucket: https://console.ucloud.cn/uapi/detail?id=CreateBucket

Loki 参考配置: https://grafana.com/docs/loki/latest/configuration/examples/

# 查询日志

配置grafana 域名解析，浏览器访问grafana 域名，文中示例为：grafana.loki.admin.com

# 查看grafana密码

```
kubectl get secret --namespace loki loki-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

```

![image](https://upload-images.jianshu.io/upload_images/5592768-4e12342fe3d6e55d?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# 收集 systemd 日志

```
cat > journalbeat.yml <<EOF
journalbeat.inputs:
- id: docker.service
  paths: []
  include_matches:
    - _SYSTEMD_UNIT=docker.service
  processors:
    - add_host_metadata:
        cache.ttl: 5

- id: kubelet.service
  paths: []
  include_matches:
    - _SYSTEMD_UNIT=kubelet.service  
  processors:
    - add_host_metadata:
        cache.ttl: 5m
output.logstash:
  hosts: ["logstash.loki.admin.com"]
EOF

docker rm journalbeat -f
docker run -d        \
  --net=host         \
  --name=journalbeat \
  --user=root        \
  --volume="/root/journalbeat.yml:/usr/share/journalbeat/journalbeat.yml" \
  --volume="/var/log/journal:/var/log/journal" \
  --volume="/etc/machine-id:/etc/machine-id" \
  --volume="/run/systemd:/run/systemd" \
  --volume="/etc/hostname:/etc/hostname:ro" \
  docker.elastic.co/beats/journalbeat:7.11.2 journalbeat -e -strict.perms=false

```

