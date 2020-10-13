#  K8S 集群 部署 ncp 2.4

## k8s 集群 nsx-t 网络准备工作

部署业务集群，需要提前在 nsx-t-manager 中创建好 k8s_api_server_lb , ncp_ingress_ip_pool,   cluster_ip_block , 其中lb端口转发规则如下：
k8s_api_server_lb  端口转发规则
k8s_api_server_lb    lb端口    目标端口    k8s-api-server_pool
k8s-api-vs           6443      6443

master1_ip
master2_ip
master3_ip 

为集群内节点所在的逻辑交换机端口打标签 sitet-compute-overlay-devcpaas-pod-ls 为集群内节点所在的逻辑交换机端口打标签，

登录NSX-T Manager –> 高级网络和安全 –> 交换机 –> 选择目标交换机，如sitet-compute-overlay-devcpaas-pod-ls–> 
端口(勾选kubernetes集群对应节点的) –> 操作 –> 管理标记 –> +添加： 
标记：{‘<node_name>’} 范围：{‘ncp/node_name’}
标记：{‘<cluster_name>’} 范围：{‘ncp/cluster’}

其中，node_name 替换为vmware vcenter中集群对应的主机节点名，cluster_name 替换为NCP配置中一致的集群名称保证一致，以上定义的原因是：NSX-T Container Plug-in (NCP) 必须知道用于每个节点中的容器流量的 vNIC 的 VIF ID。必须按以下方式标记相应的逻辑交换机端口:

{‘ncp/node_name’: ‘node_name’}
{‘ncp/cluster’: ‘cluster_name’}

## K8S集群 cni nsx-t 网络插件

完成集群标准部署后，部署完global和业务集群一下操作步骤相同，需要完成如下操作步骤:

1. 删除部署集群，默认安装的flannel cni插件，master-1节点，执行命令: kubectl delete ds kube-flannel -n kube-system
2. 清理旧的  cni 配置
3. 安装ovs nsx-cni 软件包
4. 初始化虚拟网卡配置
5. 将 nsx-ncp-rhel 镜像上传到init registry仓库
6. 创建NSX-T Manager证书
```
openssl genrsa -aes256 -out ca.key 2048
openssl req -new -key ca.key -out ca.csr
openssl rsa -in ca.key -out nsx-ncp.key
openssl x509 -req -days 36500 -in ca.csr -signkey nsx-ncp.key -out nsx-ncp.crt
```
7. 登录NSX-T Manager –> 系统 –> 证书 –> 导入: 将 的文件内容导入，并按照命名规范命名，例如:devcpaas-crt ：
名称：
```
证书 crt 内容 cat nsx-ncp.crt
私钥 key 内容 cat nsx-ncp.key
密码短语 无 
服务证书 否
```

8. 登录NSX-T Manager导入证书后执行脚本（以测试环境为例）
```
curl -k -X POST "https://10.213.114.14/api/v1/trust-management/principal-identities" -u "admin:cpaasCeb@1234" \
-H 'content-type: application/json' \
-d '{
"name": "cpaastest",
"node_id": "cpaas-test-test-gk8s",
"permission_group": "read_write_api_users",
"certificate_id": "7ccebf95-917b-4d0a-bb23-a5dee639221b"
}'
```

其中 node_id 为唯一标志ID，不能重复

9 创建K8S secret 执行命令 kubectl create secret tls nsx-auth --cert=nsx-ncp.crt --key=nsx-ncp.key
10 为所有命名空间添加annotation 执行命令 kubectl edit ns -n alauda-system
metadata: 
  annotations:
    ncp/no_snat: "true"

11 修改 NCP deployment的yaml 修改data.ncp.ini
```
cluster = <对应逻辑交换机端口打标签的集群名>
[k8s] apiserver_host_ip = <k8s_apiserver_lb_ip>
[nsx_v3] nsx_api_managers = <nsx_api_managers_ip>
nsx_api_cert_file = /etc/nsx-ujo/nsx-cert/tls.crt
nsx_api_private_key_file = /etc/nsx-ujo/nsx-cert/tls.key
top_tier_router = 类型为 tier-0 的逻辑路由器名称
overlay_tz = 覆盖网络类型的传输区域名称
subnet_prefix = 27 定义如何从 ipblock 在划分子网，
use_native_loadbalancer = True 开启 ingress和k8s原生 loadbalancer类型的服务
default_ingress_class_nsx = True 设置 NSX ingress 为默认 ingress
no_snat_ip_blocks = 对应创建集群工作 NSX创建的 ipblock ipam -> 里面的
external_ip_pools = 对应创建集群工作 NSX创建的 ippool
```

12 修改NCP 的deployment的yaml 修改 image 对应的nsx-ncp-rhel 镜像仓库地址
13 修改NSX-node-agent的ds的yaml
cluster = <对应逻辑交换机端口打标签的集群名>
[k8s] apiserver_host_ip = <k8s_apiserver_lb_ip>
修改NSX-node-agent的ds的yaml， 对应的nsx-ncp-rhel 镜像仓库地址

14  应用ncp nsx-agent ，执行命令  kubectl apply -f ncp.yml ; kubectl apply -f nsx-agent.yml 

15  重启集群中所有 pod  检查确认集群正常



## 回收

回收 IPAM cpaastest-ipblock01 10.213.23.0/24，操作步骤，从k8s集群全部 deploy ds cm .. 然后从nsx-t删除对应 IPAM即可
回收 负载平衡-L4LB 10.213.109.9 和 10.213.109.10
停掉集群节点 kubelet docker服务，
点击负载平衡→ 虚拟服务器→ 名称 load balancers 断开链接
