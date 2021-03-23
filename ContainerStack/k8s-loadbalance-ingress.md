# 部署VPC内网ULB的ingress-nginx

## 获取 ingress-nginx chart包，修改为定制的ULB内网版本

```
kubectl create ns ingress-inner
helm repo add ingress https://kubernetes.github.io/ingress-nginx
helm repo update
helm fetch ingress/ingress-nginx
tar -xvpf ingress-nginx-3.24.0.tgz

修改 ingress-nginx/Chart.yaml
name: ingress-nginx-inner

修改 ingress-nginx/templates/controller-service.yaml
metadata:
  annotations:
    service.beta.kubernetes.io/ucloud-load-balancer-type: inner

修改 ingress-nginx/templates/controller-deployment.yaml    
          args:
            - /nginx-ingress-controller
            - --tcp-services-configmap=$(POD_NAMESPACE)/tcp-services
            - --udp-services-configmap=$(POD_NAMESPACE)/udp-services  

```

## 安装修改后的chart包

```
helm package ingress-nginx
cat > ingress-inner-value.yaml << EOF
controller:
  name: controller
  ingressClass: nginx-inner
EOF
helm del ingress-inner -n ingress-inner
helm upgrade --install ingress-inner /data/ingress-nginx-inner-3.24.0.tgz -n ingress-inner --values=ingress-inner-value.yaml

```

## 创建一个测试的内网ingress

```
cat > ingress-inner-test.yaml << EOF
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx-inner
    nginx.ingress.kubernetes.io/configuration-snippet: |
      proxy_set_header Upgrade "websocket";
      proxy_set_header Connection "Upgrade";
  labels:
    app: rancher
  name: rancher-inner-domain
  namespace: cattle-system
spec:
  rules:
  - host: racher.inner.admin.com
    http:
      paths:
      - backend:
          serviceName: rancher
          servicePort: 80
        pathType: ImplementationSpecific
  tls:
  - hosts:
    - racher.inner.admin.com
    secretName: tls-rancher-ingress
EOF
kubectl  apply -f ingress-inner-test.yaml

```

## 验证ingress创建状态

kubectl get ingress -n cattle-system rancher-inner-domain

kubectl get svc -n ingress-inner

![image](https://upload-images.jianshu.io/upload_images/5592768-f096e0aa8f7a8d44?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 验证服务运行状态

*   修改 /etc/hosts 添加 10.7.10.40 racher.inner.admin.com 解析记录,
*   curl https://racher.inner.admin.com -k
*   kubectl logs -f ingress-inner-ingress-nginx-inner-controller-57d46bb54b-nfszp -n ingress-inner 日志返回 HTTP 200 确认ingress配置正确，且可以正常请求后端服务 

```
10.8.32.0 - - [18/Mar/2021:16:14:51 +0000] "GET / HTTP/1.1" 200 9421 "-" "curl/7.29.0" 86 0.003 [cattle-system-rancher-80] [] 10.8.147.24:80 9407 0.003 200 0d1f631906950ce9355486403c2d6f69

```


## ingress-nginx 配置 tcp/udp 转发

1. 第一步，更改ingress-nginx的deployment启动参数
添加--tcp-services-configmap和--udp-services-configmap参数，开启tcp与udp的支持
 ```
containers:
- args:
  - --tcp-services-configmap=$(POD_NAMESPACE)/tcp-services
  - --udp-services-configmap=$(POD_NAMESPACE)/udp-services
```

2. 第二步，更改ingress-nginx的service，声明tcp和udp用的端口号
```
  ports:
  - name: proxied-tcp
    nodePort: 35044 
    port: 5044
    protocol: TCP
    targetPort: 5044
  - name: proxied-udp
    nodePort: 30091
    port: 9001
    protocol: UDP
    targetPort: 9001
  ```

3. 第三步，定义configmap，
4. 格式为 <ingress-controller-svc-port>:"<namespace>/<service-name>:<port>",
例如下面表示 将loki命名空间下的logstash-logstash服务的5044端口映射到ingress-controller service的5044 端口

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: tcp-services
  namespace: ingress-nginx
data:
  5044: "loki/logstash-logstash:5044"
```
