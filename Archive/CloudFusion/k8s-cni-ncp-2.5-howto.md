#  K8S 集群 部署 ncp 2.5.1

## k8s 集群 部署ncp 2.5.1 准备工作
 
1. nsx-t-manager 中创建好 k8s_api_server_lb , cluster_ip_block 
2. 创建好k8s集群

为集群内节点所在的逻辑交换机端口打标签 sitet-compute-overlay-devcpaas-pod-ls 为集群内节点所在的逻辑交换机端口打标签，登录NSX-T Manager –> 高级网络和安全 –> 交换机 –> 选择目标交换机，如site-computeoverlay-devcpaas-pod-ls –> 勾选kubernetes集群对应节点的端口 –> 操作 –> 管理标记 –> +添加：

```
标记：{‘<node_name>’} 范围：{‘ncp/node_name’}
标记：{‘<cluster_name>’} 范围：{‘ncp/cluster’}
```

标记 <node_name> 替换为k8s集群node_name，
标记 <cluster_name> 替换为NCP配置中配置项 cluster 的集群名称保证一致，以上定义的原因是：NSX-T Container Plug-in (NCP) 必须知道用于每个节点中的容器流量的 vNIC 的 VIF ID。

## K8S集群  替换 ncp 2.5.1

将 nsx-container-2.5.1.15287458/Kubernetes/nsx-ncp-rhel-2.5.1.15287458.tar 镜像导入init registry仓库
创建NSX-T Manager证书

```
openssl genrsa -aes256 -out ca.key 2048
openssl req -new -key ca.key -out ca.csr
openssl rsa -in ca.key -out nsx-ncp.key
openssl x509 -req -days 36500 -in ca.csr -signkey nsx-ncp.key -out nsx-ncp.crt
```

登录NSX-T Manager –> 系统 –> 证书 –> 导入: 将 的文件内容导入，并按照命名规范命名，例如:devcpaas-crt ：

名称：

```
证书 crt 内容 cat nsx-ncp.crt
私钥 key 内容 cat nsx-ncp.key
密码短语 无 
服务证书 否
```

登录NSX-T Manager导入证书后执行脚本（以测试环境为例）

```
curl -k -X POST "https://<NSX-T_Manager_IP>/api/v1/trust-management/principal-identities" -u "admin:cpaasCeb@1234" \
-H 'content-type: application/json' \
-d '{
"name": "cpaastest",
"node_id": "cpaas-test-test-gk8s",
"permission_group": "read_write_api_users",
"certificate_id": "7ccebf95-917b-4d0a-bb23-a5dee639221b"
}'
```

其中

```
NSX-T_Manager_IP 替换为实际的IP
node_id 为唯一标志ID，不能重复
certificate_id 是导入的证书对应的 ID
```


为所有命名空间添加annotation 

```
metadata: 
  annotations:
    ncp/no_snat: "true"
```

修改 nsx-container-2.5.1.15287458/Kubernetes/ncp-rhel.yaml 修改如下配置项：

```
image                                 对应的nsx-ncp-rhel 镜像仓库地址
cluster                                对应逻辑交换机端口打标签的集群名，需要改两处
apiserver_host_ip              k8s_apiserver_lb_ip，需要改两处
apiserver_host_port          6443
insecure                             取消注释，改为true
nsx_api_managers             nsx_api_managers_ip   #填写三个ip，达到高可用的效果
nsx_api_cert_file                /etc/nsx-ujo/nsx-cert/tls.crt
nsx_api_private_key_file    /etc/nsx-ujo/nsx-cert/tls.key
top_tier_router                   类型为 tier-0 的逻辑路由器名称
overlay_tz                           覆盖网络类型的传输区域名称
subnet_prefix = 27             定义如何从 ipblock 在划分子网（参考值设置为 27）
use_native_loadbalancer = True     开启 ingress和k8s原生 loadbalancer类型的服务
default_ingress_class_nsx = True   设置 NSX ingress 为默认 ingress
no_snat_ip_blocks = 对应创建集群工作 NSX创建的 ipblock ipam -> 里面的 cluster_ip_block 
external_ip_pools = 对应创建集群工作 NSX创建的 ippool
ovs_uplink_port = ens256   ovs桥接的的网卡接口名称
找到 secret 配置 去掉这一段配置，name 重命名为 nsx-auth ，参考如下截图 
```

应用yaml , 执行命令: kubectl apply -f  nsx-container-2.5.1.15287458/Kubernetes/ncp-rhel.yaml
创建K8S secret，在证书文件目录，执行命令 kubectl create secret tls nsx-auth --cert=nsx-ncp.crt --key=nsx-ncp.key -n nsx-system
删除部署集群原有的网络配置, 登陆master节点，执行命令:  kubectl delete ds flannel galaxy-daemonset -n kube-system 
删除所有节点不需要的配置文件和可执行文件，执行命令：

```
ip link delete flannel.1
rm /etc/cni/net.d/00-galaxy.conf -f
rm /opt/cni/bin/galaxy-sdn -f
rm /opt/cni/bin/flannel -f
```
重启集群中所有 pod  执行命令: kubectl delete pods --all -A 等pod完成启动后，检查确认集群状态


