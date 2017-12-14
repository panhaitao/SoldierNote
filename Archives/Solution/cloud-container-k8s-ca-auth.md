基于CA签名的双向证书认证方式
============================

基于CA签名的双向证书的生成过程如下：

1. 创建CA根证书 
2. 为kube-apiserver生成一个证书，并用CA证书进行签名，设置启动参数
3. 根据k8s集群数量，分别为每个主机生成一个证书，并用CA证书进行签名，设置相应节点上的服务启动参数

集群架构
--------

k8s-master: 运行服务 apiserver, controllerManager、scheduler

k8s-node1 : 运行服务 kubelet, proxy

k8s-node2 : 运行服务 kubelet, proxy

k8s-node3 : 运行服务 kubelet, proxy

创建集群的root CA
-----------------

生成CA、私钥、证书

`   openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ca.key -out ca.crt -subj "/CN=k8s-master"  `

`   CA的CommonName 需要和运行kube-apiserver服务器的主机一直`

创建apiServer的私钥、服务端证书
-------------------------------

创建证书配置文件openssl.cnf，在alt\_names里指定所有访问服务时会使用的目标域名和IP；
因为SSL/TLS协议要求服务器地址需与CA签署的服务器证书里的subjectAltName信息一致

```
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
DNS.5 = localhost
DNS.6 = centos-master
IP.1 = 127.0.0.1
IP.2 = 10.1.10.251
IP.3 = 10.1.10.238
```

* 最后两个IP分别是clusterIP取值范围里的第一个可用值、master机器的IP。
* k8s会自动创建一个service和对应的endpoint，来为集群内的容器提供apiServer服务；
* service默认使用第一个可用的clusterIP作为虚拟IP，放置于default名称空间，名称为kubernetes，端口是443；
* openssl.cnf里的DNS1\~4就是从容器里访问这个service时会使用到的域名。

创建分配给apiServer的私钥与证书

-   openssl genrsa -out server.key 2048
-   openssl req -new -key server.key -out server.csr -subj "/CN=k8s-master" -config openssl.cnf
-   openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 9000 -extensions v3_req -extfile openssl.cnf

配置kube-apiserver 修改参数文件/etc/kubernetes/apiserver

```
KUBE\_API\_ARGS="--bind-address=0.0.0.0                           \
              --secure-port=6443                                  \
              --client-ca-file=/k8s/rsa/ca.pem                    \
              --tls-private-key-file=/k8s/rsa/apiserver-key.pem   \
              --tls-cert-file=/k8s/rsa/apiserver.pem              \ 
              --service-account-key-file=/k8s/rsa/apiserver-key.pem"
```


-   这里监听SSL/TLS的端口是6443；若指定小于1024的端口，有可能会导致启动apiServer启动失败
-   在master机器上，默认开8080端口提供未加密的HTTP服务,可以通过--insecure-port=0
    参数来关闭

创建访问apiServer的各个组件使用的客户端证书
-------------------------------------------

```
for f in client k8s-node1 k8s-node2 k8s-node3  
do
    KEY_NAME=$f
    if [[ $KEY_NAME == client ]];then
      HOST_NAME=k8s-master 
    else
      HOST_NAME=$KEY_NAME
    done
      
    openssl genrsa -out $KEY_NAME.key 2048
    openssl req -new -key $KEY_NAME.key -out $KEY_NAME.csr -subj "/CN=$HOST_NAME"
    openssl x509 -req -days 9000 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out $KEY_NAME.crt 
done
```

1.  假设controllerManager、scheduler 和 apiservers运行在同一台主机上，因此CommonName 为k8s-master

最后生成的证书

    client.key client.crt       : 提供给运行在k8s-master主机上的controllerManager、scheduler服务和kubectl工具使用   
    k8s-node1.key k8s-node1.srt : 提供给运行在k8s-node1主机上的kubelet, proxy服务使用
    k8s-node2.key k8s-node2.srt ：余下类同 
    ...
    

    == 创建 /etc/kubernetes/kubeconfig 模板 ==

```
kubectl config set-cluster k8s-cluster --server=https://k8s-master:6443 --certificate-authority=/etc/kubernetes/ca.crt
kubectl config set-credentials default-admin --certificate-authority=/etc/kubernetes/ca.crt --client-key=/etc/kubernetes/server.key --client-certificate=/etc/kubernetes/server.crt
kubectl config set-context default-system --cluster=k8s-cluster --user=default-admin
kubectl config use-context default-system
kubectl config view > /etc/kubernetes/kubeconfig
```

```
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /etc/kubernetes/ca.crt
    server: https://k8s-master:6443
  name: k8s-cluster
- cluster:
    server: https://10.1.10.238:443
  name: k8s-server
contexts:
- context:
    cluster: k8s-server
    namespace: the-right-prefix
    user: k8s-custer
  name: default-context
- context:
    cluster: k8s-cluster
    user: default-admin
  name: default-system
current-context: default-system
kind: Config
preferences: {}
users:
- name: default-admin
  user:
    client-certificate: /etc/kubernetes/server.crt
    client-key: /etc/kubernetes/server.key
- name: k8s-custer
  user:
    password: admin
    username: admin
```

配置controllerManager, scheduler, kubelet, proxy
------------------------------------------------

在每个主机上根据对应的主机名修改配置文件 /etc/kubernetes/kubeconfig
主要修改如下部分，修改对应的client-certificate和client-key参数

k8s-master主机中，controllerManager, scheduler服务对应的是

    client-certificate: /etc/kubernetes/client.crt
    client-key: /etc/kubernetes/client.key

k8s-node1主机中 kubelet, proxy服务对应的是

    client-certificate: /etc/kubernetes/k8s-node1.crt
    client-key: /etc/kubernetes/k8s-node1.key

k8s-node2, k8s-node3 其他主机的配置依此类推，然后修改对应服务的启动参数

    --mater=https://k8s-master:6443
    --kubeconfig=/etc/kubernetes/kubeconfig

最后重启对应的服务。

配置kubectl
-----------

验证集群启动情况
----------------

查看pod

    kubectl get nodes
    kubectl get deployments --all-namespaces
    kubectl get ReplicationController  --all-namespaces
    kubectl get DaemonSets  --all-namespaces
    kubectl get ReplicaSets --all-namespaces
    kubectl get pods --all-namespaces

查看endpoint

    kubectl get services  --all-namespaces
    kubectl get endpoints  --all-namespaces
