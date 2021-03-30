# 制品库-Harbor的安装部署

1.  Kubernetes 1.13 或更高版本的集群 
2.  kubectl 1.13 或者更高版本
3.  Helm v3 或更高版本，安装命令参考

```
wget https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz #或
wget https://mirrors.huaweicloud.com/helm/v3.5.2/helm-v3.5.2-linux-amd64.tar.gz 
tar -xf helm-v3.5.2-linux-amd64.tar.gz
mv linux-amd64/helm /usr/bin/
chmod 755 /usr/bin/helm

```

4.  如果集群内未创建StorageClass 配置，首先在ucloud 控制台创建UFS存储，选择 k8s集群所在的vpc 子网 创建UFS挂载点，
    1.  StorageClass部署参考 https://github.com/panhaitao/k8s-app/tree/main/deploy-for-k8s/StorageClass-UFS 
    2.  创建修改 deployment.yaml 配置中 挂载点ufs_server_ip 顺序执行如下命令:

```
git clone https://github.com/panhaitao/k8s-app.git
cd k8s-app/deploy-for-k8s/StorageClass-UFS/
kubectl  apply -f deployment.yaml
kubectl  apply -f rbac.yaml
kubectl  apply -f class.yaml

```

执行命令 kubectl get sc -A 记录返回的 storageClass 名字, 默认是 ufs-nfsv4-storage

5.  安装nginx-ingress

```
kubectl create namespace ingress-nginx
helm repo add ingress https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress/ingress-nginx  -n ingress-nginx

```

6.  准备SSL/TLS证书，这里是自签名的证书

```
#!/bin/bash
openssl req -newkey rsa:2048       \
            -keyout ca.key         \
            -out ca.crt            \
            -days 3650             \
            -x509                  \
            -passout pass:ca_key_xxxxx \
            -subj '/C=CN/ST=beijing/L=BJ/O=RD/OU=RDTEAM/CN=admin.com'

for cert_name in harbor.core harbor harbor.notary
do
   openssl genrsa -out ${cert_name}.key 2048             \
                  -passout pass:111111
   openssl req -new -key ${cert_name}.key                \
                    -out ${cert_name}.csr                \
                    -passin pass:111111                  \
                    -subj "/C=CN/ST=beijing/L=BJ/O=RD/OU=RDTEAM/CN=${cert_name}.repo.admin.com"
   openssl x509 -req -sha256                             \
                 -extensions v3_req                      \
                 -days 3650                              \
                 -in ${cert_name}.csr                    \
                 -CAkey ca.key                           \
                 -CA ca.crt                              \
                 -CAcreateserial                         \
                 -passin pass:ca_key_xxxxx               \
                 -out ${cert_name}.crt
  cat ca.crt  >> ${cert_name}.crt
done

```

# 安装步骤

1.  ## 部署PostgreSQL (依赖 11.x 或者更高版本）

```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
kubectl create ns harbor-db
cat > harbor-db.config.yaml << EOF
postgresqlUsername: postgres
postgresqlPassword: a4h3ljbn
persistence:
  enabled: true
  mountPath: /bitnami/postgresql
  subPath: ''

  storageClass: "ufs-nfsv4-storage"
  accessModes:
    - ReadWriteOnce
  size: 5Gi
EOF
helm upgrade --install harbor-db bitnami/postgresql -n harbor-db -f harbor-db.config.yaml

```

查看DB Host：

查看DB密码:

kubectl get secret --namespace harbor-db harbor-db-postgresql -o jsonpath="{.data.postgresql-password}" | base64 --decode

连接DB实例:

```
export POSTGRES_PASSWORD=$(kubectl get secret --namespace harbor-db harbor-db-postgresql -o jsonpath="{.data.postgresql-password}" | base64 --decode)

kubectl run harbor-db-postgresql-client --rm --tty -i --restart='Never' --namespace harbor-db --image docker.io/bitnami/postgresql:11.11.0-debian-10-r31 --env="PGPASSWORD=$POSTGRES_PASSWORD" --command -- psql --host harbor-db-postgresql -U postgres -d postgres -p 5432

create database registry;
create database notary_server;
create database notary_signer;

```

2.  ## 创建Harbor需要的TLS证书

```
kubectl create ns harbor
kubectl -n harbor create secret tls tls-harbor-core --cert=harbor.core.crt --key=harbor.core.key
kubectl -n harbor create secret tls tls-harbor-notary --cert=harbor.notary.crt --key=harbor.notary.key

```

3.  ## 完成Harbor的配置和部署

```
helm repo add harbor https://helm.goharbor.io
helm repo update

cat > harbor-config.yaml << EOF
expose:
  type: ingress
  tls:
    enabled: true
    secret:
      secretName: "tls-harbor-core"
      notarySecretName: "tls-harbor-notary"
  ingress:
    hosts:
      core: harbor.core.repo.admin.com
      notary: harbor.notary.repo.admin.com
    controller: nginx
    annotations:
      ingress.kubernetes.io/proxy-body-size: "0"
      nginx.ingress.kubernetes.io/proxy-body-size: "0"

persistence:
  enabled: true
  resourcePolicy: "keep"
  persistentVolumeClaim:
    registry:
      storageClass: "ufs-nfsv4-storage"
      accessMode: ReadWriteOnce
      size: 5Gi
    chartmuseum:
      storageClass: "ufs-nfsv4-storage"
      accessMode: ReadWriteOnce
      size: 5Gi
    jobservice:
      storageClass: "ufs-nfsv4-storage"
      accessMode: ReadWriteOnce
      size: 5Gi
    redis:
      storageClass: "ufs-nfsv4-storage"
      accessMode: ReadWriteOnce
      size: 5Gi
    trivy:
      storageClass: "ufs-nfsv4-storage"
      accessMode: ReadWriteOnce
      size: 5Gi
database:
  type: external
  external:
    host: "172.17.227.20"
    port: "5432"
    username: "postgres"
    password: "db_passwd"
    coreDatabase: "registry"
    notaryServerDatabase: "notary_server"
    notarySignerDatabase: "notary_signer"
EOF
helm upgrade --install harbor harbor/harbor -f harbor-config.yaml -n harbor

```

# 验证服务:

1.  修改 /etc/hosts 添加解析记录:

ingress_lb_ip harbor.core.repo.admin.com harbor.notary.repo.admin.com

2.  浏览器访问 https://harbor.core.repo.admin.com 默认用户名admin 密码 Harbor12345

参考文档:

*   https://github.com/goharbor/harbor-helm
*   https://github.com/goharbor/harbor-helm/blob/master/docs/High%20Availability.md

