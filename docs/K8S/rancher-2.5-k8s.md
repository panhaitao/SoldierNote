# K8S集群中部署Rancher 2.5

## 准备工作

1.  准备一个k8s集群
2.  安装helm

登陆k8s集群任意一个节点，安装

```
wget https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz
tar -zxf helm-v3.2.4-linux-amd64.tar.gz
mv linux-amd64/helm /usr/bin/

```

3.  添加 rancher-stable 仓库: 

```
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable

```

4.  创建rancher 默认运行的命名空间: 

```
kubectl create namespace cattle-system

```

5.  创建自签名证书

```
#!/bin/bash
openssl req -newkey rsa:2048       \
            -keyout ca.key         \
            -out ca.crt            \
            -days 3650             \
            -x509                  \
            -passout pass:ca_key_xxxxx \
            -subj '/C=CN/ST=beijing/L=BJ/O=RD/OU=RDTEAM/CN=my.com'

for cert_name in rancher
do
   openssl genrsa -out ${cert_name}.key 2048             \
                  -passout pass:111111
   openssl req -new -key ${cert_name}.key                \
                    -out ${cert_name}.csr                \
                    -passin pass:111111                  \
                    -subj "/C=CN/ST=beijing/L=BJ/O=RD/OU=RDTEAM/CN=${cert_name}.my.com"
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

6.  创建secret

```
kubectl -n cattle-system create secret tls tls-rancher-ingress --cert=./rancher.crt --key=./rancher.key
kubectl -n cattle-system create secret generic tls-ca   --from-file=cacerts.pem=./ca.crt

```

7.  部署 Rancher-Server

```
helm install rancher-server rancher-stable/rancher \
 --namespace cattle-system                         \
 --set hostname=rancher.my.com                     \
 --set privateCA=true                              \
 --set ingress.tls.source=tls-rancher-ingress

```

8.  修改服务请求方式
    1.  Rancher默认是 ingress 方式 暴露服务，这里修改为NodePort方式，也可以选择LB方式

```
apiVersion: v1
kind: Service
metadata:
  name: rancher-server
  namespace: cattle-system
  annotations:
    meta.helm.sh/release-name: rancher-server
    meta.helm.sh/release-namespace: cattle-system
  labels:
    app: rancher-server
    app.kubernetes.io/managed-by: Helm
    chart: rancher-2.5.5
    heritage: Helm
    release: rancher-server
spec:
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 80
  - name: https-internal
    port: 443
    protocol: TCP
    targetPort: 444
  selector:
    app: rancher-server
  sessionAffinity: None
  type: NodePort

```

```
kubectl delete svc rancher-server -n cattle-system
kubectl apply -f rancher-server.yaml

```

9.  验证是否成功

*   系统导入ca.crt 作信任证书
*   设置DNS解析，rancher.my.com ，或本地域名解析
*   访问集群域名是否能登陆成功：https://rancher.my.com:端口，可以通过kubectl get svc -A 查看

**备注说明**  : Rancher 2.5版 使用etcd做管理平台数据存储，不需要在对接外部数据，更轻量，更云原生

## 参考文档

1.  官方文档：[https://docs.rancher.cn/](https://docs.rancher.cn/)
2.  部署Rancher https://docs.rancher.cn/docs/rancher2/installation_new/install-rancher-on-k8s/chart-options/_index

