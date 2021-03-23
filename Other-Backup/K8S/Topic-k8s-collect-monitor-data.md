# K8S Collect Event

```
yum install -y nfs-utils -y
docker login -u user -p "password" uhub.service.ucloud.cn
cp /root/.docker/config.json /var/lib/kubelet/ -f
systemctl daemon-reload && systemctl restart kubelet
```

* https://github.com/opsgenie/kubernetes-event-exporter

将k8s event 写入ES,  修改 01-config.yaml 

```
  config.yaml: |
    logLevel: error
    logFormat: json
    route:
      routes:
        - match:
          - receiver: "es"
    receivers:
      - name: "es"
        elasticsearch:
          hosts:
          - http://10.10.18.231:9200
          indexFormat: "kube-pod-events-{2020-09-08}"
          useEventID: true
```


* cd deploy 
* kubectl apply -f 00-roles.yaml
* kubectl apply -f 01-config.yaml
* kubectl apply -f 02-deployment.yaml

## promethus

https://github.com/panhaitao/k8s-app-deploy.git

## Pod Lifecycle Metrics


## Deploy kube-state-metrics

```
annotations:
  prometheus.io/scrape: 'true'
```

* clusterIP: None

初步判断可以修改kube-state-metrics 来添加
https://github.com/kubernetes/kube-state-metrics/blob/master/internal/store/pod.go

"kube_pod_created" `date -d @1603813611`
"kube_pod_status_scheduled_time " `date -d @1603813613`
"kube_pod_start_time" `date -d @1603813613`
"kube_pod_container_state_started" `date -d @1603813614`

计算时间差 

```
kube_pod_container_state_started{job="kubernetes-pods",pod=~"myweb-.*"}  -  on(job, pod) kube_pod_start_time{job="kubernetes-pods",pod=~"myweb-.*"} 
```
按照job, pod 相同的条件匹配，计算差值


## grafana 

* https://github.com/prometheus-operator/kube-prometheus/blob/master/manifests/grafana-deployment.yaml
* https://grafana.com/docs/grafana/latest/administration/configure-docker/
* https://xuxinkun.github.io/2018/11/27/grafana-provisioning/
* https://grafana.com/docs/grafana/latest/administration/provisioning/#datasources
