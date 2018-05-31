

学习前 , 为了对 Kubernetes 的工作有一个大概的认识 , 我们需要先安装一个单节点的实例服务 ,
用于平常的开发与测试。在官网 中,有各种各样的搭建方式,但这里我们想要有更贴近实际
的例子,只有这样才能让 docker 和 k8s 体现出关系的紧密。
我们先看 k8s 的架构图,以便对它的部署有个直观的了解
Kubernetes
http://lihaoquan.me/2017/2/25/create-kubernetes-single-node-mode.html
1/102018/5/30
环境准备
深入学习Kubernetes(一):单节点k8s安装-domac的菜园子
本文的例子是基于 Centos 7 的 Linux 版本,大家也可以使用 ubuntu 或其他发行版,软件搭建的
方式基本是差不多的,为了让例子更简单, 本文省去了网络 Fannel 的安装与配置,只做基本
通用的开发环境搭建,希望对大家有帮助。
本例子用于测试的服务器 ip 为: 192.168.139.149
yum
源
为了让国内下载 etcd 和 kubernetes 更流畅,我们先切换阿里云的 yum 源
$ wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
$ yum makecache
关闭防火墙服务
默认使用 firewall 为防火墙,而 Kubernetes 的 Master 与工作 Node 之间会有大量的网络
通信,安全的做法是在防火墙上配置各种需要相互通讯的端口号,在一个安全的内部网络环
境中可以关闭防火墙服务;
这里我们将其更改为 iptables ,具体步骤如下:
centos7
$ systemctl disable firewalld.service
$ systemctl stop firewalld.service
安装 iptables ,其操作为:
$ yum install -y iptables-services
$ systemctl start iptables.service
$ systemctl enable iptables.service
安装 etcd 和 Kubernetes 软件( docker 会在安装 kubernetes 的过程
中被安装)
$ yum install -y etcd kubernetes
配置修改
http://lihaoquan.me/2017/2/25/create-kubernetes-single-node-mode.html
2/102018/5/30
深入学习Kubernetes(一):单节点k8s安装-domac的菜园子
安装完服务组件后,我们需要修改相关的配置
Docker 配置文件 /etc/sysconfig/docker ,其中的 OPTIONS 的内容设置为:
$ vim /etc/sysconfig/docker
OPTIONS='--selinux-enabled=false --insecure-registry gcr.io'
Kubernetes
修改 apiserver 的配置文件,在 /etc/kubernetes/apiserver 中
$ vim /etc/kubernetes/apiserver
KUBE_ADMISSION_CONTROL="--admission_control=NamespaceLifecycle,NamespaceExists,
LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota"
去掉 ServiceAccount 选项。否则会在往后的 pod 创建中,会出现类似以下的错误:
Error from server: error when creating "mysql-rc.yaml": Pod "mysql" is forbidden:
no API token found for service account default/default,
retry after the token is automatically created and added to the service account
切换 docker hub 镜像源
在国内为了稳定 pull 镜像,我们最好使用 Daocloud 的镜像服务 :)
curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://dbe35452.m.daocloud.io
按顺序启动所有服务
systemctl start etcd
systemctl start docker
systemctl start kube-apiserver.service
systemctl start kube-controller-manager.service
systemctl start kube-scheduler.service
systemctl start kubelet.service
systemctl start kube-proxy.service
然后,我们检验下 kubernetes 的服务是否跑起来
ps -ef | grep kube
http://lihaoquan.me/2017/2/25/create-kubernetes-single-node-mode.html
3/102018/5/30
深入学习Kubernetes(一):单节点k8s安装-domac的菜园子
到目前为止,一个单机版的 Kubernetes 的环境就安装启动完成了。接下来,我就基于这个单
机版,撸起袖子,认真干!!!
启动 MySQL 容器服务
我们先拉取 mysql 的服务镜像 :
sudo docker pull mysql
或
docker pull hub.c.163.com/library/mysql:latest
启动 MySQL 服务
首先为 MySQL 服务创建一个 RC 定义文件: mysql-rc.yaml ,下面给出了该文件的完整内容
1 apiVersion: v1
2
3 kind: ReplicationController
metadata:
4
5 name: mysql
spec:
6
7 replicas: 1
selector:
8
9 app: mysql
template:
10
11
12
13
14
15
16
metadata:
labels:
app: mysql
spec:
containers:
- name: mysql
image: hub.c.163.com/library/mysql
17
18 ports:
- containerPort: 3306
19 env:
20
21 - name: MYSQL_ROOT_PASSWORD
value: "123456"
yaml
YAML
定义文件说明:
kind :表明此资源对象的类型,例如上面表示的是一个 RC
spec: 对 RC 的相关属性定义,比如说 spec.selector 是 RC 的 Pod 标签( Label )选择器,
既监控和管理拥有这些表情的 Pod 实例,确保当前集群上始终有且 仅有 replicas 个 Pod
实例在运行。
spec.template 定义 pod 的模板,这些模板会在当集群中的 pod 数量小于 replicas 时,被作
为依据去创建新的 Pod
http://lihaoquan.me/2017/2/25/create-kubernetes-single-node-mode.html
4/102018/5/30
深入学习Kubernetes(一):单节点k8s安装-domac的菜园子
创建好 mysql-rc.yaml 后, 为了将它发布到 Kubernetes 中,我们在 Master 节点执行命令
$ kubectl create -f mysql-rc.yaml
replicationcontroller "mysql” created
接下来,我们用 kuberctl 命令查看刚刚创建的 RC:
$ kubectl get rc
NAME
mysql
DESIRED CURRENT READY
1
1
0
AGE
14s
查看 Pod 的创建情况,可以运行下面的命令:
$ kubectl get pods
NAME
READY
mysql-b0gk0 0/1
STATUS
RESTARTS AGE
ContainerCreating 0
3s
可⻅ pod 的状态处于 ContainerCreating ,我们需要耐心等待一下,直到状态为 Running
NAME
READY
mysql-b0gk0 1/1
STATUS
Running 0
RESTARTS AGE
6m
最后,我们创建一个与之关联的 Kubernetes Service - MySQL 的定义文件: mysql-svc.yaml
1
2 apiVersion: v1
kind: Service
3
4 metadata:
name: mysql
5
6 spec:
ports:
7
8
9
YAML
- port: 3306
selector:
app: mysql
其中 metadata.name 是 Service 的服务名, port 定义服务的端口, spec.selector 确定了哪些
Pod 的副本对应本地的服务。
运行 kuberctl 命令,创建 service :
http://lihaoquan.me/2017/2/25/create-kubernetes-single-node-mode.html
5/102018/5/30
深入学习Kubernetes(一):单节点k8s安装-domac的菜园子
$ kubectl create -f mysql-svc.yaml
service "mysql" created
然后我们查看 service 的状态
$ kubectl get svc
NAME
CLUSTER-IP
kubernetes 10.254.0.1
mysql
EXTERNAL-IP PORT(S)
<none>
10.254.185.20 <none>
443/TCP
AGE
18m
3306/TCP 14s
注意到 MySQL 服务被分配了一个值为 10.254.185.20 的 CLUSTER-IP ,这是一个虚地址,
随后, Kubernetes 集群中的其他新创建的 Pod 就可以通过 Service 的 CLUSTER-IP+ 端口 6379
来连接和访问它了。
启动 Web 容器服务
先拉取一个测试镜像到本地
docker pull kubeguide/tomcat-app:v1
上面我们定义和启动了 MySQL 的服务,接下来我们用同样的步骤,完成 Tomcat 应用的服务启
动过程,首先我们创建对应的 RC 文件 myweb-rc.yaml ,具体内容如下:
http://lihaoquan.me/2017/2/25/create-kubernetes-single-node-mode.html
6/102018/5/30
深入学习Kubernetes(一):单节点k8s安装-domac的菜园子
1
2 apiVersion: v1
kind: ReplicationController
3
4
5 metadata:
name: myweb
spec:
6
7
8
9
YAML
replicas: 5
selector:
app: myweb
template:
10
11
12 metadata:
labels:
app: myweb
13
14
15
16 spec:
containers:
- name: myweb
image: docker.io/kubeguide/tomcat-app:v1
17
18
19
20 ports:
- containerPort: 8080
env:
- name: MYSQL_SERVICE_HOST
21
22
23 value: "mysql"
- name: MYSQL_SERVICE_PORT
value: "3306"
与 mysql 一样,我们创建 rc 服务:
$ kubectl create -f myweb-rc.yaml
replicationcontroller "myweb" created
$ kubectl get rc
NAME
mysql
myweb
DESIRED CURRENT READY
1
1
5
0
5
AGE
14m
0
10s
接着,我们看下 pods 的状态:
$ kubectl get pods
NAME
READY
mysql-b0gk0 1/1
myweb-1oyb7 1/1
STATUS
RESTARTS AGE
Running 0
Running 0
15m
43s
myweb-8ffs6 1/1 Running 0 43s
myweb-xge1t 1/1 Running 0 43s
myweb-xr214 1/1 Running 0 43s
myweb-zia37 1/1 Running 0 43s
http://lihaoquan.me/2017/2/25/create-kubernetes-single-node-mode.html
7/102018/5/30
深入学习Kubernetes(一):单节点k8s安装-domac的菜园子
从命理结果我们发现,我们 yaml 中声明的 5 个副本都被创建并运行起来了,我们隐约感
受到 k8s 的威力咯
我们创建对应的 Service, 相关的 myweb-svc 文件如下:
wow..
YAML
1
2
3 apiVersion: v1
kind: Service
metadata:
4
5
6
7 name: myweb
spec:
type: NodePort
ports:
8
9
10
11
- port: 8080
nodePort: 30001
selector:
app: myweb
运行 kubectl create 命令进行创建
$ kubectl create -f myweb-svc.yaml
service "myweb" created
最后,我们使用 kubectl 查看前面创建的 Service
[root@kdev tmp]# kubectl get services
NAME
CLUSTER-IP
kubernetes 10.254.0.1
mysql
myweb
EXTERNAL-IP PORT(S)
<none>
10.254.185.20 <none>
10.254.18.53
<nodes>
443/TCP
AGE
4h
3306/TCP 4m
8080/TCP 57s
验证与总结
通过上面的几个步骤,我们可以成功实现了一个简单的 K8s 单机版例子,我们可以在浏览器输
入 http://192.168.139.149:30001/demo/ (http://192.168.139.149:30001/demo/) 来测试我们
发布的 web 应用。
http://lihaoquan.me/2017/2/25/create-kubernetes-single-node-mode.html
8/102018/5/30
深入学习Kubernetes(一):单节点k8s安装-domac的菜园子
$ curl http://192.168.139.149:30001
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>Apache Tomcat/8.0.35</title>
<link href="favicon.ico" rel="icon" type="image/x-icon" />
<link href="favicon.ico" rel="shortcut icon" type="image/x-icon" />
<link href="tomcat.css" rel="stylesheet" type="text/css" />
</head>
<body>
<div id="wrapper">
<div id="navigation" class="curved container">
<span id="nav-home"><a href="http://tomcat.apache.org/">Home</a></span>
<span id="nav-hosts"><a href="/docs/">Documentation</a></span>
<span id="nav-config"><a href="/docs/config/">Configuration</a></span>
<span id="nav-examples"><a href="/examples/">Examples</a></span>
<span id="nav-wiki"><a href="http://wiki.apache.org/tomcat/FrontPage">Wiki</a></span>
<span id="nav-lists"><a href="http://tomcat.apache.org/lists.html">Mailing Lists</a></span
>
<span id="nav-help"><a href="http://tomcat.apache.org/findhelp.html">Find Help</a></spa
n>
<br class="separator" />
</div>
<div id="asf-box">
<h1>Apache Tomcat/8.0.35</h1>
</div>
...
...
...
但我们不只是要搭建环境那么简单,我们希望更深入一下,比如说运用这里例子拓展一下深
度:
研究 RC 、 Service 等文件格式
熟悉 kuberctl 的命令
http://lihaoquan.me/2017/2/25/create-kubernetes-single-node-mode.html
9/102018/5/30
深入学习Kubernetes(一):单节点k8s安装-domac的菜园子
手工停止某个 Service 对应的容器进程,然后观察有什么现象发生
修改 RC 文件,改变副本数量,重新发布,观察结果
© 2018 domac
的菜园子 . Some rights reserved (http://creativecommons.org/licenses/by/3.0/) |
Feed (/feed.xml) | Sitemap (/sitemap.xml)
Powered by PuGo 0.10.0 (beta) (https://github.com/go-xiaohei/pugo). Theme by Default.
http://lihaoquan.me/2017/2/25/create-kubernetes-single-node-mode.html
