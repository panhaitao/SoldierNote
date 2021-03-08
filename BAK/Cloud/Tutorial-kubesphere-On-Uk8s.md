# Uk8s集群部署kubesphere

由于目前Uhub提供的镜像加速功能不够灵活，原本搭建一个简单http的registry，但是个人觉得添加docker配置项insecure-registries的方式不够优雅，长时间运行不够安全，还是花时间验证如何搭建https的registry 用于完成内网环境下kubespshre部署在Uk8s集群上，虽然这样最开始麻烦了些，但是好处以后申请 Uk8s 集群的时候就不用每个节点都需要绑定EIP了，如果是生产环境可以较少一定开支，也便于维护.

## 部署过程概述

* 需要一台Ucloud云主机, 用于搭建kubesphere私有镜像仓库 
* 申请需要数量的Uk8s集群
* 集群节点主机添加配置
* 完成kubesphere的部署 

## 申请Uk8s集群并完成初始化配置 

在申请完毕Uk8s集群后，每个集群可以完成以下初始化配置

### 设置默认storage
1. 登陆UK8S集群 其中一台master(可以从registry节点主机做跳板登陆) 执行命令：`kubectl  edit sc ssd-csi-udisk` 添加 ` storageclass.kubernetes.io/is-default-class: "true" `

### 初始化集群节点配置 

登陆UK8S集群 所有节点，完成如下配置：

1. 添加myhub.com解析记录,执行命令: ` echo  "10.10.184.169 myhub.com" >> /etc/hosts `
2. 将domain.crt分发到节点,并执行命令: ` cat domain.crt >> /etc/pki/tls/certs/ca-bundle.crt ` 
3. 重启docker服务生效执行命令: ` systemctl restart docker`
4. 仓库登陆认证，执行命令: ` docker login myhub.com -u user -p "password" ` 执行成功后认证信息会记录在 ~/.docker/config.json
5. cp /root/.docker/config.json /var/lib/kubelet/
6. systemctl daemon-reload && systemctl restart kubelet"

## 部署管理集群(kubesphere-host)

1. 创建UK8S 集群，给一台 master 节点，绑定eip,设置外网防火墙，允许30880端口访问
2. 确认完成 `初始化集群节点配置` 
3. 修改 kubesphere-installer.yaml `image: myhub.com/kubespheredev/ks-installer:latest`
4. 修改 cluster-configuration.yaml
```
添加 local_registry: myhub.com
将 clusterRole: none 修改为 clusterRole: host
```
5. 部署kubesphere，执行命令: `kubectl  apply -f  kubesphere-installer.yaml ;  kubectl  apply -f  kubesphere-installer.yaml `
6. 部署完毕host集群后，执行命令: `kubectl -n kubesphere-system get cm kubesphere-config -o yaml | grep -v "apiVersion" | grep jwtSecret` 记下返回的结果` jwtSecret: "xxxxxxxxxxxxxxxxxxx"` 后面配置member集群需要修改的参数  

## 部署业务集群(kubesphere-member)

1. 创建UK8S 集群
2. 确认完成 `初始化集群节点配置`
3. 修改 kubesphere-installer.yaml `image: myhub.com/kubespheredev/ks-installer:latest`
4. 修改 cluster-configuration.yaml
```
添加 local_registry: myhub.com
修改 jwtSecret：写入部署完毕host集群后最后一步返回的结果 
将 clusterRole: none 修改为 clusterRole: member
```
5. 部署kubesphere，执行命令: `kubectl  apply -f  kubesphere-installer.yaml ;  kubectl  apply -f  kubesphere-installer.yaml `
## 将member集群加入主控集群

1. 使用浏览器访问 http://主控集群_eip:30880 默认用户名 admin 密码 P@88w0rd
2. 平台管理 -> 集群管理 -> 添加集群 (完成自定义设置)-> 下一步 -> 默认-> 添加从member集群 master节点文件 /root/.kube/config 的内容  
3. 添加其他member集群，重复以上操作

## 参考文档
 
* 多集群管理 https://github.com/kubesphere/community/tree/master/sig-multicluster/how-to-setup-multicluster-on-kubesphere#MemberCluster 
