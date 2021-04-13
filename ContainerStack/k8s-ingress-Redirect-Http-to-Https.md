# 配置 Nginx-Ingress实现http跳转https功能

## 准备工作

1. Kubernetes 1.13 或更高版本的集群 
2. kubectl 1.13 或者更高版本
3. Helm v3 或更高版本，安装命令参考

## 安装 Helm 

```
wget https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz #或
wget https://mirrors.huaweicloud.com/helm/v3.5.2/helm-v3.5.2-linux-amd64.tar.gz 
tar -xf helm-v3.5.2-linux-amd64.tar.gz
mv linux-amd64/helm /usr/bin/
chmod 755 /usr/bin/helm
```

## 部署 inginx-ingress

1. 添加 ingress Chart仓库
```
helm repo add ingress https://kubernetes.github.io/ingress-nginx
helm repo update
```
如果在国内拉取官方镜像失败，可以将ingress-nginx需要的镜像推送到自有镜像仓库，然后使用自有镜像仓库参考操作如下：

2. 将官方镜像上传的自有镜像仓库,需要上传的镜像列表:
```
k8s.gcr.io/ingress-nginx/controller:v0.45.0
docker.io/jettech/kube-webhook-certgen:v1.5.1
```

3. 创建  docker-registry类的secrets
```
kubectl create namespace ingress-nginx
kubectl delete secret your-registry-secret -n ingress-nginx
kubectl create secret docker-registry your-registry-secret \
--namespace=ingress-nginx             \
--docker-server=your.registry.domain  \
--docker-username=${USERNAME}         \
--docker-password=${PASSWORD}
```

4. 使用自有仓库来部署ingress-nginx（以仓库地址: uhub.service.ucloud.cn/ucloud_pts为例)

```
kubectl create namespace ingress-nginx
cat > ingress-value.yaml << EOF
controller:
  image:
    repository: uhub.service.ucloud.cn/ucloud_pts/controller
    tag: "v0.45.0"
    digest: sha256:c892e4e39885a16324d38b213d0dd42f56d183e93836b28d051c5476b1418bc1
  name: controller
  ingressClass: nginx
  admissionWebhooks:
    patch:
      enabled: true
      image:
        repository: uhub.service.ucloud.cn/ucloud_pts/kube-webhook-certgen
imagePullSecrets: 
  - name: your-registry-secret
EOF
helm upgrade --install ingress ingress/ingress-nginx -n ingress-nginx --values=ingress-value.yaml
```

# ingress参考操作

1. 创建一个ingress，需要在annotations中定义nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
2. 本地测试修改 /etc/hosts 添加解析记录: ingress_lb_ip  svc.domain 
3. curl http://svc.domain  确认服务是否正常
4. 确认ingress服务正常，可以为svc.domain添加DNS解析记录

# ingress完整验证示例

## 1. 准备SSL/TLS证书，这里使用的自签名证书

```
#!/bin/bash
openssl req -newkey rsa:2048       \
            -keyout ca.key         \
            -out ca.crt            \
            -days 3650             \
            -x509                  \
            -passout pass:ca_key_xxxxx \
            -subj '/C=CN/ST=beijing/L=BJ/O=RD/OU=RDTEAM/CN=admin.com'

for cert_name in nginx
do
   openssl genrsa -out ${cert_name}.key 2048             \
                  -passout pass:111111
   openssl req -new -key ${cert_name}.key                \
                    -out ${cert_name}.csr                \
                    -passin pass:111111                  \
                    -subj "/C=CN/ST=beijing/L=BJ/O=RD/OU=RDTEAM/CN=${cert_name}.admin.com"
   openssl x509 -req -sha256                             \
                 -extensions v3_req                      \
                 -days 3650                              \
                 -in ${cert_name}.csr                    \
                 -CAkey ca.key                           \
                 -CA ca.crt                              \
                 -CAcreateserial                         \
                 -passin pass:ca_key_xxxxx               \
                 -out ${cert_name}.crt
done
```

## 2. 创建 nginx 需要的 configmap

```
cat > default.conf << EOF
server {

    listen 80 default_server;
    server_name _;
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm; 
    }
}
server {
    listen       443 ssl;
    listen  [::]:443 ssl;
    server_name _;
 
    ssl_certificate /etc/nginx/ssl/tls.crt;
    ssl_certificate_key /etc/nginx/ssl/tls.key;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm; 
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
kubectl create ns nginx
kubectl delete configmap nginx-configmap -n nginx
kubectl create configmap nginx-configmap --from-file=default.conf -n nginx
```

## 3. 创建 nginx 需要的 secret

```
kubectl create ns nginx
kubectl create secret tls nginx-secret --cert=nginx.crt --key=nginx.key -n nginx
```

## 4. 创建 nginx 服务

```
cat > nginx-deploy-svc.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx
  namespace: nginx
  labels:
    app: nginx
spec:
  ports:
  - port: 443
    protocol: TCP
    targetPort: 443
    name: https
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
  namespace: nginx 
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
      - name: secret-volume
        secret:
           secretName: nginx-secret 
      - name: configmap-volume
        configMap:
          name: nginx-configmap 
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 443
        - containerPort: 80
        volumeMounts:
        - mountPath: /etc/nginx/ssl
          name: secret-volume
        - mountPath: /etc/nginx/conf.d
          name: configmap-volume
EOF
kubectl apply -f nginx-deploy-svc.yaml  
```

## 5. 创建 ingress 示例 

```
cat > nginx-svc-ingress.yaml << EOF
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: nginx-svc
  namespace: nginx
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  tls:
  - hosts:
    - nginx.admin.com
    secretName: nginx-secret
  rules:
  - host: nginx.admin.com
    http:
      paths:
      - backend:
          serviceName: nginx
          servicePort: 443
        path: /
EOF
kubectl apply -f nginx-svc-ingress.yaml
```

## 6. 验证 ingress 服务

本地测试修改 /etc/hosts 添加解析记录: ingress_lb_ip  svc.domain  curl http://svc.domain  确认服务是否正常

# 参考文档
- ingress-nginx官方文档: https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/
- 阿里云文档：https://help.aliyun.com/document_detail/86533.html
