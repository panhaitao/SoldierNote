# K8S集群中部署Rancher 2.5

# 准备工作

1.  准备一个k8s集群

建议所有节点提前导入rancher镜像，减少部署时间，以rancher 2.5.6为例：

```
docker pull uhub.service.ucloud.cn/ucloud_pts/nginx-ingress:1.10.0
docker tag uhub.service.ucloud.cn/ucloud_pts/nginx-ingress:1.10.0 nginx/nginx-ingress:1.10.0

docker pull uhub.service.ucloud.cn/ucloud_pts/rancher:v2.5.6
docker tag uhub.service.ucloud.cn/ucloud_pts/rancher:v2.5.6 rancher/rancher:v2.5.6

```

2.  安装 helm

```
wget https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz #或
wget https://mirrors.huaweicloud.com/helm/v3.5.2/helm-v3.5.2-linux-amd64.tar.gz 
tar -xf helm-v3.5.2-linux-amd64.tar.gz
mv linux-amd64/helm /usr/bin/

```

3.  安装nginx-ingress

```
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
kubectl create namespace nginx-ingress
helm install controller nginx-stable/nginx-ingress -n nginx-ingress

```

4.  准备SSL/TLS证书，这里是自签名的证书

```
#!/bin/bash
openssl req -newkey rsa:2048       \
            -keyout ca.key         \
            -out ca.crt            \
            -days 3650             \
            -x509                  \
            -passout pass:ca_key_xxxxx \
            -subj '/C=CN/ST=beijing/L=BJ/O=RD/OU=RDTEAM/CN=admin.com'

for cert_name in rancher
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
cat ca.crt  >> rancher.crt

```

5.  创建 ingress需要的secret

rancher-server 在 k8s 环境中只提供 http 协议端口，tls 证书在ingress 中卸载，因此需要在ingress-nginx运行的命名空间，创建存放证书的 secret

```
kubectl -n nginx-ingress create secret generic tls-ca --from-file=cacerts.pem=./ca.crt
kubectl -n nginx-ingress create secret tls tls-rancher-ingress --cert=rancher.crt --key=rancher.key

```

# 部署 Rancher

1.  创建Rancher Server 的 Secret

```
kubectl create namespace cattle-system 
kubectl -n cattle-system create secret generic tls-ca --from-file=cacerts.pem=./ca.crt
kubectl -n cattle-system create secret tls tls-rancher-ingress --cert=rancher.crt --key=rancher.key

```

2.  完成 Rancher Server的部署

```
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update
helm install rancher rancher-stable/rancher        \
--namespace cattle-system                          \
--set privateCA=true                               \
--set ingress.tls.source=tls-rancher-ingress       \
--set hostname=rancher.admin.com                     

```

3.  配置说明

*   创建 rancher 的 namespace
*   --set privateCA=true 使用自签证书是必选项
*   --set ingress.tls.source=ls-rancher-secret rancher-server服务用到的证书和密钥
*   --set hostname=rancher.my.com 配置访问 rancher-server 的域名，这个域名配置在 ingress 中，如果域名没有解析到 ingress 节点，也可以绑个 host 访问

3.  其他可选配置

```
kubectl -n ingress-nginx create secret generic tls-ca-additional --from-file=ca-additional.pem= ca-additional.crt

```

--set additionalTrustedCAs=true (可选)访问各种 tls （https） 时额外信任的 ca 证书，比如自使用签证书的镜像仓库、git仓库、s3 对象存储，亦或是类似公司出网白名单代理网关、fiddler 抓 https 包之类的需要安装 ca 证书的情况

# 安装后配置

1.  **查看集群中的ingressClass**

```
[root@10-9-156-147 ]# kubectl get ingressClass
NAME    CONTROLLER                     PARAMETERS   AGE
nginx   nginx.org/ingress-controller   <none>       44m

```

2.  **修改rancher的默认ingress**

由于是自建的 ingress，修改ingress是配置正确，执行命令: kubectl edit ingress -n cattle-system 在 annotations 处添加一行注解: ( 修改为和集群中名称一致的 **ingressClass，这里名为 nginx )**

```
kubernetes.io/ingress.class: nginx

```

*   检查 rancher ingress 配置 kubectl get ingress rancher -n cattle-system
*   检查 ingress-controller  配置，kubectl get svc -n nginx-ingress 
*   确认 EXTERNAL-IP 和 ADDRESS 一致，说明配置正确

![image](https://upload-images.jianshu.io/upload_images/5592768-12db703d3c1f504b?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# 验证

1.  将 ADDRESS_IP 添加到rancher.admin.com 域名的DNS解析A记录，或本地域名解析
2.  浏览器或系统导入创建的自签名根证书 ca.crt, 并设置为始终信任
3.  浏览器访问 https://rancher.admin.com 检查是否能登陆成功，以及各项功能是否正常 

![image](https://upload-images.jianshu.io/upload_images/5592768-264e5aa74b4b169d?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# 参考文档

1.  Rancher官方文档：
    1.  [https://docs.rancher.cn/](https://docs.rancher.cn/)
    2.  https://docs.rancher.cn/docs/rancher2/installation_new/install-rancher-on-k8s/chart-options/_index
2.  nginx-ingress 文档 
    1.  https://kubernetes.github.io/ingress-nginx/deploy/#using-helm

