# K8S Collect  Event

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

cd deploy 
kubectl apply -f 00-roles.yaml
kubectl apply -f 01-config.yaml
kubectl apply -f 02-deployment.yaml
