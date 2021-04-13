# 配置 Nginx-Ingress实现http跳转https功能

# 准备工作

1. Kubernetes 1.13 或更高版本的集群 
2. kubectl 1.13 或者更高版本
3. Helm v3 或更高版本，安装命令参考

## 1. 安装 Helm 

```
wget https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz #或
wget https://mirrors.huaweicloud.com/helm/v3.5.2/helm-v3.5.2-linux-amd64.tar.gz 
tar -xf helm-v3.5.2-linux-amd64.tar.gz
mv linux-amd64/helm /usr/bin/
chmod 755 /usr/bin/helm
```

## 2. 安装nginx-ingress

```
kubectl create namespace ingress-nginx
helm repo add ingress https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress/ingress-nginx  -n ingress-nginx
```

如果在国内拉取官方镜像失败，可以将ingress-nginx需要的镜像推送到自有镜像仓库，然后使用自有镜像仓库参考操作如下：

1. 创建  docker-registry类的secrets

```
kubectl create secret docker-registry your-registry-secret --namespace=ingress-nginx --docker-server=your.registry.domain --docker-username=${USERNAME} --docker-password=${PASSWORD}
```

2. 如果希望针对整个命名空间生效，可以使patch来设置imagePullSecrets
```
kubectl patch serviceaccount ingress-nginx -p '{"imagePullSecrets": [{"name": "your-registry-secret"}]}'
```

3. 如果需要修改某个应用可以修改 spec 字段，添加如下配置

```
      imagePullSecrets:
      - name: your-registry-secret
      containers:
      - image: your.registry.domain/xxx/xxx:tag
```

4. 准备SSL/TLS证书，这里使用的自签名证书
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

5. 创建 nginx 需要的 configmap

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

6. 创建 nginx 需要的 secret

```
kubectl create ns nginx
kubectl create secret tls nginx-secret --cert=nginx.crt --key=nginx.key -n nginx
```

7. 创建 nginx 服务

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

8. 创建 nginx ingress 
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

## 验证服务

1. 本地测试修改 /etc/hosts 添加解析记录: ingress_lb_ip  svc.domain 
2. curl http://svc.domain  确认服务是否正常
3. 确认ingress服务正常，可以为svc.domain添加DNS解析记录，余下略

## 参考文档
1. ingress-nginx官方文档: https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/
2. 阿里云文档：https://help.aliyun.com/document_detail/86533.html
