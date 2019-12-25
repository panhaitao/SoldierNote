# MacOS下使用ks-installer部署KubeSphere 

## 准备工作

* 获取 Docker Desktop 下载地址：https://docs.docker.com/docker-for-mac/
* 获取 helm v2 版本 下载地址：https://get.helm.sh/helm-v2.15.0-darwin-amd64.tar.gz
* 获取 ks-installer 获取地址：https://github.com/kubesphere/ks-installer
* brew git 等工具的安装参考: https://brew.sh/index_zh-cn
* 需要自行解决翻墙问题，推荐使用v2ray ，如果自行搭建参考如下步骤

```
安装V2Ray服务端
   准备一个国外的 centos7 vps
    执行命令: bash <(curl -L -s https://install.direct/go.sh)
    记下UUID和PORT 或者查看 /etc/v2ray/config.json
    启动V2Ray服务,执行命令: systemctl start v2ray && systemctl enable v2ray
    关闭防火墙: iptables -F; systemctl stop firewalld
客户端
    macos客户端: https://github.com/Cenmrev/V2RayX/releases 配置略
```
 
## 安装docker和Kubernetes

在解决翻墙后，安装好Docker Desktop后，调整下基本配置

1. preferences -> disk image size 调大 按照后续部署KubeSphere的需求，可以调成100G
2. preferences -> advanced  调整配置： CPUs-> 4, Memory -> 6.0GiB，Swap->512MiB, Docker subnet 默认即可
3. preferences -> Kubernetes ：Enable Kubernetes 开启

需要运行一段时间，点击Docker Desktop图标，确认

```
Docker Desktop is running
Kubernetes is running
```

检查k8s运行状态，终端执行命令，`kubectl get cs` 将会返回如下：

```
NAME                 STATUS    MESSAGE              ERROR
scheduler            Healthy   ok
controller-manager   Healthy   ok
etcd-0               Healthy   {"health": "true"}
```

检查k8s组件pod，终端执行命令：`kubectl get pods --all-namespaces` ，将返回如下：

```
NAMESPACE     NAME                                         READY     STATUS    RESTARTS   AGE
docker        compose-74649b4db6-mls79                     1/1       Running   0          1m
docker        compose-api-785ff756f8-zgbfx                 1/1       Running   0          1m
kube-system   etcd-docker-for-desktop                      1/1       Running   0          1m
kube-system   kube-apiserver-docker-for-desktop            1/1       Running   0          1m
kube-system   kube-controller-manager-docker-for-desktop   1/1       Running   0          1m
kube-system   kube-dns-86f4d74b45-t7sb7                    3/3       Running   0          2m
kube-system   kube-proxy-6l7hp                             1/1       Running   0          2m
kube-system   kube-scheduler-docker-for-desktop            1/1       Running   0          1m
```

## 初始化helm 

解压helm-v2.15.0-darwin-amd64.tar.gz 将darwin-amd64/helm 拷贝到/usr/local/bin/ 后执行命令`helm init`

```
命令执行过程，macos会弹出“无法打开“helm”，因为无法验证开发者...”的提示框，选择取消
启动台 -> 系统偏好设置 -> 安全性与隐私 -> 仍然允许
重新执行 helm init macOS无法验证“helm”的开发者。您确定要打开它吗？选择打开
```
## 安装 kubesphere 

1. 进入 ks-installer 目录, 编辑kubesphere-minimal.yaml 其中 etcd.endpointIps: 填充`kubectl get pods --all-namespaces -o wide | grep etcd` 返回的ip，例如：

```
shenlandeMacBook-Pro:ks-installer shenlan$ kubectl get pods --all-namespaces -o wide | grep etcd
kube-system   etcd-docker-for-desktop                      1/1       Running   0          15m       192.168.65.3   docker-for-desktop
```
2.  其他根据需要进行修改，最后执行命令：`kubectl apply -f kubesphere-minimal.yaml`
3. 由于DockerHub仓库redis版本已经更新到5.0.7-alpine版本了,执行命令：`kubectl edit deploy -n kubesphere-system redis` 修改 image: redis:5.0.5-alpine -> image: redis:5.0.7-alpine 保存退出即可
4. 确认除了node-exporter的所有pod都是Running状态，执行命令：`kubectl get pods --all-namespaces`,  node-exporter 不支持macos，可以忽略

## 登陆 kubesphere 平台页面

打开浏览器访问 http://127.0.0.1:30880 输入默认用户密码，详见https://github.com/kubesphere/ks-installer/blob/master/README_zh.md
[upl-image-preview url=https://kubesphere.com.cn/forum/assets/files/2019-12-22/1576982310-450047-2019-12-21115417.png]

