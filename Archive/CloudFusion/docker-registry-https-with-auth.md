# Run https registry with base auth  

## 准备工作:

* 需要一台主机，最好使用存储

## 安装docker  

```
CentOS8 install docker

dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf install docker-ce --nobest -y

CentOS7 install docker 
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce -y

dnf install httpd-tools -y
systemctl  restart docker && docker pull registry  &> /dev/null &
```

## 创建需要的目录:

```
mkdir -pv /data/certs/
mkdir -pv /data/auth/
mkdir -pv /data/docker/registry/
``

## 创建自签名证书

```
cd /data/certs/
openssl genrsa 1024 > domain.key
chmod 400 domain.key
openssl req -new -x509 -nodes -sha1 -days 365 -key domain.key -out domain.crt

其中 Common Name (eg, your name or your server's hostname) []:myhub.com 要对应域名
```

## 创建认证

htpasswd -Bbn admin a4h3ljbn > /data/auth/htpasswd

## 启动registry

```
docker run -d      \
--name registry    \
-p 443:443         \
--restart=always   \
--privileged=true  \
-e "REGISTRY_HTTP_ADDR=0.0.0.0:443"                       \
-e "REGISTRY_AUTH=htpasswd"                               \
-e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm"          \
-e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd"           \
-e "REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt"      \
-e "REGISTRY_HTTP_TLS_KEY=/certs/domain.key"              \
-v /data/docker/registry:/var/lib/registry                \
-v /data/certs/:/certs                                    \
-v /data/auth:/auth                                       \
registry
```
## 其他客户端主机需要的操作 

docker版本 (1.13.1 18.09 19.03 )验证通过:

```
echo  "10.10.184.169 myhub.com" >> /etc/hosts
cat /data/certs/domain.crt  >> /etc/pki/tls/certs/ca-bundle.crt 
systemctl restart docker
docker login myhub.com -u admin -p "a4h3ljbn" 
```

执行成功后 认证信息会记录在 ~/.docker/config.json

如果是k8s节点还需要完成如下操作:

```
cp /root/.docker/config.json /var/lib/kubelet/
systemctl daemon-reload
systemctl restart kubelet"
```

## FAQ

Error response from daemon: Get https://myhub.com/v2/: x509: certificate signed by unknown authority

```
cat domain.crt  >> /etc/pki/tls/certs/ca-bundle.crt 
systemctl restart docker
```

或者在/etc/docker/daemon.json 写入配置
```
{
  "insecure-registries" : ["myregistrydomain.com:5000"]
}
```
systemctl restart docker 重启服务生效

## 参考

* https://medium.com/better-programming/deploy-a-docker-registry-using-tls-and-htpasswd-56dd57a1215a
