# Run https registry with base auth  

由于目前Uhub提供的镜像加速功能不够灵活，原本搭建一个简单http的registry，但是个人觉得添加docker配置项insecure-registries的方式不够原生，不够优雅，还是花时间验证如何搭建https的registry 用于完成内网环境下kubespshre部署在Uk8s集群上。
## 搭建过程概述

* 需要一台Ucloud云主机，最好使用云存储，方便扩容
* 安装docker  用于运行registry 
* httpd-tools 用于生成http auth文件
* 创建自签名证书,并添加到系统信息
* 启动registry
* 客户端主机添加配置

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
```

## 创建自签名证书

```
cd /data/certs/
openssl genrsa 1024 > domain.key
chmod 400 domain.key
openssl req -new -x509 -nodes -sha1 -days 365 -key domain.key -out domain.crt

其中 Common Name (eg, your name or your server's hostname) []:myhub.com 要对应域名
```

## 创建认证

```
htpasswd -Bbn admin a4h3ljbn > /data/auth/htpasswd
```

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


1. 添加myhub.com解析记录,执行命令: ` echo  "10.10.184.169 myhub.com" >> /etc/hosts `
2. 将domain.crt分发到节点,执行命令: ``cat /data/certs/domain.crt  /etc/pki/tls/certs/ca-bundle.crt ` 
3. 重启docker服务生效执行命令: ` systemctl restart docker`
4. 仓库登陆认证，执行命令: ` docker login myhub.com -u user -p "password" ` 执行成功后认证信息会记录在 ~/.docker/config.json

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
