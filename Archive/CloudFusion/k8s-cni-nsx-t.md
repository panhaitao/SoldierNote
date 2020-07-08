# K8S CNI NSX-T




手动维护 NSX-T L4LB (ippool)
登陆 NSX-T 管理页面
选择 高级网络和安全  
 左侧：清单 -> 组 
 右侧：IP池 -> 添加 一个新的LB ，命名规则 类型-集群名-ipv4后两位字段-ippool IP地址是依次递增，子网范围是一个ip，网关 CIDR 查询客户的规划表格   
创建完毕后，选中当前新建的 ippool  操作->管理标记  ，设置如下配置项：标记cluster：集群名（例如 devk8s-td） 范围 ncp/owner
创建完 ippool 后，需要将ippool 名称提供给业务项目组人员
创建 K8s services 确认 spec.LoadBalancerIP: ippool-name 配置存在
创建 Server Pools
登陆 NSX-T 管理页面，创建 Server Pools 选择 高级网络和安全

左侧：网络 -> 负载平衡器
右侧：Server Pools -> 选择 +ADD 添加新的服务池 命名规则： 集群名-端口组件名-serverpool
常规属性：名称 -> cpaas-ace-api-serverpool 自定义名称,其他默认
SNAT转换：转换模式 -> 自动映射
池成员: 静态成员资格 -> +ADD 根据需要添加 对应 name ip 端口，其他默认
运行状况监控器： 配置主动运行状况监控器: 选择 nsx-default-tcp-monitor 其他默认
创建虚拟服务器
登陆 NSX-T 管理页面，创建 虚拟服务器(VIP) 选择 高级网络和安全
左侧：网络 -> 负载平衡器
右侧：虚拟服务器 -> 选择 +ADD 添加一个新的虚拟服务器，名规则： 集群名-端口组件名-vs 例如（cpaastest-6443api-vs）
常规属性：
名称：cpaastest-6443api-vs 自定义名称
应用程序类型：Layer4 TCP 默认即可
应用程序配置文件：default-tcp-lb-app-profile 默认即可
Access Log Disabled 默认即可
虚拟服务标志符:
IP地址：10.213.109.9
端口： 6443 
其他默认
服务器池：选择上一步创建的，cpaastest-6443api-serverpool 如果没有，需要创建一个新的
负载平衡配置文件：默认为空
最后一步，选中刚才创建的虚拟服务器，点击协议上方的设置按钮ACTIONS，然后选择 attch to a load balancer 选择 gk8s-mgmt-manul-lb 
其他lb创建方法类同，只是端口不同


重新部署集群，删除 nsx-t 旧资源

需要删除，负载平衡器，虚拟服务器，server pool 里的资源，路由，交换 IPAM -> ipblock 删除子网

```

#lb 删除负载平衡器

curl -k -X DELETE -H "X-Allow-Overwrite: true" -u "admin:cpaasCeb@1234" "https://10.213.114.14/api/v1/loadbalancer/services/c900c68b-c244-4890-b236-90388f199bd1"

#vs 删除虚拟服务器

curl -k -X DELETE -H "X-Allow-Overwrite: true" -u "admin:cpaasCeb@1234" "https://10.213.114.14/api/v1/loadbalancer/virtual-servers/c406d309-58ab-4ddf-bba4-62bebcaae1d4"

curl -k -X DELETE -H "X-Allow-Overwrite: true" -u "admin:cpaasCeb@1234" "https://10.213.114.14/api/v1/loadbalancer/virtual-servers/e1cffbea-47d0-495b-b8b4-6c52cc1bd70b";

curl -k -X DELETE -H "X-Allow-Overwrite: true" -u "admin:cpaasCeb@1234" "https://10.213.114.14/api/v1/loadbalancer/virtual-servers/8a56db6e-bfb1-4e17-8df0-19155cc5a437"

curl -k -X DELETE -H "X-Allow-Overwrite: true" -u "admin:cpaasCeb@1234" "https://10.213.114.14/api/v1/loadbalancer/pools/20cfaab8-abe1-48a8-84d2-38326fe327b3"

#ippool

curl -k -X DELETE -H "X-Allow-Overwrite: true" -u "admin:cpaasCeb@1234" "https://10.213.114.14/api/v1/pools/ip-pools/612fc23f-ebb8-4933-8b33-83cb9cb169a0?force=true"

#subnets

curl -k -X DELETE -H "X-Allow-Overwrite: true" -u "admin:cpaasCeb@1234" "https://10.213.114.14/api/v1/pools/ip-subnets/107583df-437b-4f9d-8cc0-247088f7c412"

#ipblocks

curl -k -X DELETE -H "X-Allow-Overwrite: true" -u "admin:cpaasCeb@1234" "https://10.213.114.14/api/v1/pools/ip-blocks/ecbfffcd-6bab-4b88-9f65-e1f8ae749e76"

#lr 路由

curl -k -X DELETE -H "X-Allow-Overwrite: true" -u "admin:cpaasCeb@1234" "https://10.213.114.14/api/v1/logical-routers/8fca6596-d932-4870-b3b0-e97ad376cde1?force=true"



#ls 交换

curl -k -X DELETE -H "X-Allow-Overwrite: true" -u "admin:cpaasCeb@1234" "https://10.213.114.14/api/v1/logical-switches/adc41f1-983e-4d22-8139-242f95a1894f?cascade=true&detach=true"

#ls_config

curl -k -X DELETE -H "X-Allow-Overwrite: true" -u "admin:cpaasCeb@1234" "https://10.213.114.14/api/v1/switching-profiles/"

```

# delete cert

curl -k -X GET "https://10.213.114.14/api/v1/trust-management/principal-identities" -u "admin:cpaasCeb@1234" 

curl -k -X DELETE -H "X-Allow-Overwrite: true" -u "admin:cpaasCeb@1234" "https://10.213.114.14/api/v1/trust-management/principal-identities/$1"

curl -k -X DELETE -H "X-Allow-Overwrite: true" -u "admin:cpaasCeb@1234" "https://10.213.114.14/api/v1/trust-management/certificates/$1"








