# helm/chart 基础

这篇帖子记录了学习helm/chart的入门笔记，主要讲述了helm的按转配置和chart的基本编写

# 客户端/服务端的安装

## 安装客户端程序helm

1. 下载helm-v2.10.0-linux-amd64.tar.gz 地址：https://github.com/kubernetes/helm/releases
2. 解压缩 tar -zxvf helm-v2.10.0-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin/helm
3. 查看版本 helm version
4. 配置bash命令自动补全，helm 有很多子命令和参数，为了提高使用命令行的效率，通常建议安装 helm 的 bash 命令补全脚本，方法如下：
```
helm completion bash > .helmrc
echo "source .helmrc" >> .bashrc
source .bashrc
```

## 安装服务端程序 tiller

（不能科学上网，使用国内镜像）
1、docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.10.0

2、 权限配置不然会报这种错 no release found
```
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'   #此项高版本或许不起效）
```

3、 安装或升级tiller服务端
```
helm init --service-account tiller -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.10.0 （当前版本）
或
helm init --service-account tiller --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.10.0 --skip-refresh
```

helm init常用配置项如下：
```
    --canary-image：安装金丝雀build
    --tiller-image：安装指定image
    --kube-context：安装到指定的kubernetes集群
    --tiller-namespace：安装到指定的namespace中
    --upgrade：如果tiller server已经被安装了，可以使用此选项更新镜像
    --service-account：用于指定运行tiller server的serviceaccount，该account需要事先在kubernetes集群中创建，且需要相应的rbac授权
```
## 安装后的配置检查

```
1 查看tiller的Pod执行命令          :  kubectl get pods -n kube-system
2 查看tiller的服务，执行命令    :  kubectl get services -n kube-system
3 查看tiller的Deploy, 执行命令 : kubectl get deployment -n kube-system
4 确认版本, 执行命令                      : helm version
```

## 客户端/服务端的卸载

* 删除Tiller: 执行命令: helm reset
* 删除helm: 执行命令: rm -f  /usr/local/bin/helm

# heml/chart的使用

## 基本操作


* 创建一个chart ，执行命令:  helm create nginx
* 测试安装一个chart 执行命令: helm install --dry-run --debug ./nginx/
* 打包一个chart 执行命令: helm package nginx/
* 安装一个chart 执行命令: helm install nginx-0.1.0.tgz
* 安装一个chart 执行命令,并指定.Release.Name: helm install nginx-0.1.0.tgz --name release-name
* 查看release, 执行命令: helm list    
* 删除release 执行命令: helm del ---purge <release_name>

## chart 模板概述

### chart目录

创建一个chart，默认生成目录的简要说明
```
nginx/
  Chart.yaml          # 必选，与容器有关的chart描述信息
  templates/          # 必选，chart 的模板目录
  values.yaml         # 可选，chart 的默认值
  charts/             # 可选，存放  chart 依赖包的目录 
  LICENSE             # 可选，chart版权声明
  README.md           # 可选，帮助说明文件
  requirements.yaml   # 可选，定义 chart 之间的依赖关系 
  templates/NOTES.txt # 可选，与容器有关的简要说明文件

Chart.yaml
apiVersion: 必选，chart API 版本, 一般是 "v1"
name:       必选，chart 的名称，必须和所在的根目录名称一致
version:    必选，chart 的版本
```

### 创建一个简单的chart

```
mkdir  configmap/templates/
touch  configmap/templates/configmap.yaml
touch  configmap/Chart.yaml
```


configmap/templates/configmap.yaml 写入如下内容
```
apiversion: v1
kind: ConfigMap
metadata:
  name: mychart-configmap
data:
  myvalue: "Hello World"
```

# 参考文档: 

* https://github.com/helm/helm/blob/master/docs/charts.md
