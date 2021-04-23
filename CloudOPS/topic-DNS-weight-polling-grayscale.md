# 使用DNS权重轮询实现业务流量灰度切量

# DNS设置

1.  ## 首先将DNS解析服务升级为支持权重轮询的版本

![image](https://upload-images.jianshu.io/upload_images/5592768-c89c58f2518fbcc6?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2.  ## 添加多条DNS解析A记录

![image](https://upload-images.jianshu.io/upload_images/5592768-65bed659f0fcb79a?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

3.  ## 开启权重配置

![image](https://upload-images.jianshu.io/upload_images/5592768-56eef5a288eb208f?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

4.  ## 设置DNS权重值

![image](https://upload-images.jianshu.io/upload_images/5592768-b20fc98238e9074e?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# 流量切换

1.  业务域名-> A记录 -> Old-LB 权重 90% 

A记录 -> NEW-LB 权重 10%

中间逐渐调整OLD-LB，NEW-LB流量比例，直到流量全部切到Ucloud-LB

2.  业务域名-> A记录 -> OLD-LB 权重 0% 

A记录 -> NEW-LB 权重 100%

3.  最后确认业务域名返回解析记录的全部是NEW-LB IP后，去掉OLD-LB解析记录，完成全部DNS流量切换，如果考虑客户端所在网络DNS缓存时间长短不同的问题，可以保持OLD-LB在继续提供24小时，然后再彻底下线服务

# 切量失败回滚方案
极端情况，如果在灰度切的部分DNS流量有问题，可以参考如下备选方案
  1. 调整权重，设置 OLD-LB  权重 100% NEW-LB 0%
  2. 启用备用代理， NEW-LB -> nginx转发 -> OLD-LB 把客户端网络缓存部分的请求转发回原有服务  

# 完整验证过程

1.  ## k8s集群中，创建nginx服务，参考如下：

```
kubectl create ns nginx-1

cat > default.conf << EOF
server {

    listen 80 default_server;
    server_name _;
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm; 
    }
}
EOF
kubectl create ns nginx-1
kubectl delete configmap nginx-configmap -n nginx-1
kubectl create configmap nginx-configmap --from-file=default.conf -n nginx-1

cat > nginx-deploy-svc.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx
  namespace: nginx-1
  labels:
    app: nginx
spec:
  type: LoadBalancer
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
    name: http
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: nginx-1 
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      volumes:
      - name: configmap-volume
        configMap:
          name: nginx-configmap 
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        volumeMounts:
        - mountPath: /etc/nginx/conf.d
          name: configmap-volume
EOF
kubectl apply -f nginx-deploy-svc.yaml  

```

2.  ## 查看svc ip 

kubectl get svc -n nginx-1

kubectl get svc -n nginx-2

```
[root@10-8-57-25 ~]# kubectl  get svc -n nginx-1
NAME    TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)        AGE
nginx   LoadBalancer   172.17.191.190   152.32.239.127   80:34829/TCP   16m
[root@10-8-57-25 ~]# kubectl  get svc -n nginx-2
NAME    TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)        AGE
nginx   LoadBalancer   172.17.143.215   101.36.127.247   80:44440/TCP   9m41s

```

3.  ## 设置DNS解析记录

![image](https://upload-images.jianshu.io/upload_images/5592768-b2e9c9b330fa9ba8?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image](https://upload-images.jianshu.io/upload_images/5592768-65e246d26877357e?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

4.  ## 配置APM监测和日志分析

观测流量调度和服务可用性

2021年4月20日 5:25 第一次配置权重 9:1

![image](https://upload-images.jianshu.io/upload_images/5592768-acc6d94d005b093a?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image](https://upload-images.jianshu.io/upload_images/5592768-27b53222a9f9b4af?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image](https://upload-images.jianshu.io/upload_images/5592768-e20af510d7d980bf?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2021年4月21日 8:45 调整权重 9:1

![image](https://upload-images.jianshu.io/upload_images/5592768-d258d0cdba60b85c?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image](https://upload-images.jianshu.io/upload_images/5592768-af12060ba58c2fed?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image](https://upload-images.jianshu.io/upload_images/5592768-16722e8bf359b0c2?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2021年4月21日 3:39 调整权重 0:100

![image](https://upload-images.jianshu.io/upload_images/5592768-7a3895d64f79cff4?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image](https://upload-images.jianshu.io/upload_images/5592768-0845e6f3d9b4aea3?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image](https://upload-images.jianshu.io/upload_images/5592768-6f351fff175829c1?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# 结论

在测试环境，通过DNS配置A记录权重调整，请求流量从LB 101.36.127.247 平滑切换到 152.32.239.127，在听云平台开启任务监测 全国85个地区，模拟客户端访问业务域名， 平均可用性可达99.98，每次调整权重，可用性未出现波动


