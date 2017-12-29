# 容器云基础二:kubernetes基于CA签名的双向证书认证方式

基于CA签名的双向证书的生成过程如下：

1\. 创建CA根证书

2\. 为kube-apiserver生成一个证书，并用CA证书进行签名，设置启动参数

3.
根据k8s集群数量，分别为每个主机生成一个证书，并用CA证书进行签名，设置相应节点上的服务启动参数

集群架构
--------

k8s-master: 运行服务 apiserver, controllerManager, scheduler

k8s-node1 : 运行服务 kubelet, proxy

k8s-node2 : 运行服务 kubelet, proxy

k8s-node3 : 运行服务 kubelet, proxy

生成证书
--------

### 创建集群的root CA

生成CA、私钥、证书

`   openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ca.key -out ca.crt -subj "/CN=k8s-master"  `

`   CA的CommonName 需要和运行kube-apiserver服务器的主机一直`

### 创建apiServer的私钥、服务端证书

创建证书配置文件 /etc/kubernetes/openssl.cnf
，在alt\_names里指定所有访问服务时会使用的目标域名和IP；
因为SSL/TLS协议要求服务器地址需与CA签署的服务器证书里的subjectAltName信息一致

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
    IP.2 = 10.254.0.1
    IP.3 = 10.1.10.238

最后两个IP分别是clusterIP取值范围里的第一个可用值、master机器的IP。
k8s会自动创建一个service和对应的endpoint，来为集群内的容器提供apiServer服务；
service默认使用第一个可用的clusterIP作为虚拟IP，放置于default名称空间，名称为kubernetes，端口是443；
openssl.cnf里的DNS1\~4就是从容器里访问这个service时会使用到的域名。

创建分配给apiServer的私钥与证书

    cd /etc/kubernetes/ca/
    openssl genrsa -out server.key 2048
    openssl req -new -key server.key -out server.csr -subj "/CN=k8s-master" -config ../openssl.cnf
    openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 9000 -extensions v3_req -extfile ../openssl.cnf

验证证书： openssl verify -CAfile ca.crt server.crt

### 创建访问apiServer的各个组件使用的客户端证书

    for f in client k8s-node1 k8s-node2 k8s-node3  
    do
        KEY_NAME=$f
        if [[ $KEY_NAME == client ]];then
          #HOST_NAME=k8s-master
          HOST_NAME=$KEY_NAME 
        else
          HOST_NAME=$KEY_NAME
        fi
          
        openssl genrsa -out $KEY_NAME.key 2048
        openssl req -new -key $KEY_NAME.key -out $KEY_NAME.csr -subj "/CN=$HOST_NAME"
        openssl x509 -req -days 9000 -in $KEY_NAME.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out $KEY_NAME.crt 
    done

注意设置CN(CommonName) 要在k8s集群中（client k8s-node1 k8s-node2
k8s-node3）域名解析生效

验证证书： openssl verify -CAfile ca.crt \*.crt

创建 /etc/kubernetes/kubeconfig 模板
------------------------------------

    kubectl config set-cluster k8s-cluster --server=https://10.1.10.238:6443 --certificate-authority=/etc/kubernetes/ca/ca.crt 
    kubectl config set-credentials default-admin --certificate-authority=/etc/kubernetes/ca/ca.crt --client-key=/etc/kubernetes/ca/client.key --client-certificate=/etc/kubernetes/ca/client.crt
    kubectl config set-context default-system --cluster=k8s-cluster --user=default-admin
    kubectl config use-context default-system
    kubectl config view > /etc/kubernetes/kubeconfig

    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority: /etc/kubernetes/ca/ca.crt
        server: https://10.1.10.238:6443
      name: k8s-cluster
    contexts:
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
        client-certificate: /etc/kubernetes/ca/client.crt
        client-key: /etc/kubernetes/ca/client.key

提供给各个客户端组件作为启动参数:
"--kubeconfig=/etc/kubernetes/kubeconfig"

集群分发证书
------------

1.  假设controllerManager、scheduler 和
    apiservers运行在同一台主机上，因此CommonName 为k8s-master

最后生成的证书

    client.key client.crt       : 提供给运行在k8s-master主机上的controllerManager、scheduler服务和kubectl工具使用   
    k8s-node1.key k8s-node1.crt : 提供给运行在k8s-node1主机上的kubelet, proxy服务使用
    k8s-node2.key k8s-node2.crt ：余下类同 
    ...

每台主机存放的证书位置如下，和kubeconfig配置中需要保持一致:

-   /etc/kubernetes/kubeconfig
-   /etc/kubernetes/ca/ca.crt
-   /etc/kubernetes/ca/client.crt
-   /etc/kubernetes/ca/client.key

因为CA在k8s-master主机上，直接使用client.key client.crt,
k8s-node主机需要把对应证书拷贝到对应目录和重命名文件，
以k8s-node1主机为例:

`   from CA: /etc/kubernetes/ca/ca.crt >          k8s-node1 主机: /etc/kubernetes/ca/ca.crt`\
`   from CA: /etc/kubernetes/ca/k8s-node1.crt ->  k8s-node1 主机: /etc/kubernetes/ca/client.crt`\
`   from CA: /etc/kubernetes/ca/k8s-node1.key ->  k8s-node1 主机: /etc/kubernetes/ca/client.key`\
`   ...余下类同`

-   系统中导入可信CA根证书

1.安装 ca-certificates package: yum install ca-certificates

2.启用dynamic CA configuration feature: update-ca-trust force-enable

3.新增加一个可信的根证书 cp /etc/kubernetes/ca/ca.crt
/etc/pki/ca-trust/source/anchors/

4.更新列表: update-ca-trust extract

参考
----

<https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/>

<https://kubernetes.io/docs/admin/authentication/#authentication-strategies>

<https://kubernetes.io/docs/concepts/cluster-administration/certificates/#openssl>
