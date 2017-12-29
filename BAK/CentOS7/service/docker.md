---
title: "docker"
categories: CentOS7
tags: 基础服务
---

## Docker 容器引擎

Docker 是一个开源的应用容器引擎，让开发者可以打包他们的应用以及依赖包到一个可移植的容器中，然后发布到任何流行的 Linux 机器上。Docker不仅仅提供了一个引擎，更是一个重新定义了程序开发测试、交付和部署过程的开放平台。深度服务器操作系统V16版本开始全面支持Docker，并提供基于容器技术的解决方案。

### Docker 的安装
    
开启扩展仓库， 创建yum配置文件，执行如下命令： 

```
cat > /etc/yum.repo.d/extras.repo << “EOF”
[extras]
Name=deepin extras
baseurl=http://packages.deepin.com/server/amd64/16/extras/x86_64
gpgcheck=0
enable=1
EOF
```

执行命令： yum update && yum install docker -y 完成软件包的安装

### docker的组成
    
Docker是C/S（客户端client-服务器server）架构模式。 docker通过客户端连接守护进程，通过命令向守护进程发出请求，守护进程通过一系列的操作返回结果。docker客户端可以连接本地或者远程的守护进程。docker客户端和服务器通过socket或RESTful API进行通信。

### docker的基本概念

* docker image 镜像 
 
镜像是容器的基石，容器基于镜像启动和运行。镜像就好像容器的源代码，保存了容器各种启动的条件。镜像是一个层叠的只读文件系统。

* docker container 容器   

容器通过镜像来启动，容器是docker的执行来源，可以执行一个或多个进程。镜像相当于构建和打包阶段，容器相当于启动和执行阶段。容器启动时，Docker容器可以运行、开始、停止、移动和删除。每一个Docker容器都是独立和安全的应用平台。

* docker registry 仓库 
 
docker仓库用来保存镜像。docker仓库分为公有和私有。docker公司提供公有仓库docker hub,网址：https://hub.docker.com/。也可以创建自己私有的仓库。
三者之间关系示意图如下：

### docker的的基本操作

* 拉取仓库镜像：
    
    docker pull  <image:label>  
* 运行一个容器实例： 

    docker run -t -i -d --name  <container_name>  <image:label>     
* 查看运行状态：

    docker  ps -a 
* 查看网络：

    docker  port <container_name>
* 容器的启停：
    
docker  start | stop | restart <container_name>

* 进入容器内部：

    docker  exec -t -i <container_name> /bin/bash
* 构建一个镜像

    docker  build -t <image:label> . 
* 查看本地镜像

    docker  image -a
