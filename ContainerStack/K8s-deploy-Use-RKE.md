# 集群管理: 使用RKE部署k8s集群

CentOS Linux release 7.6.1810 (Core)

k8s 1.19

# 安装rke前准备

1.禁用所有 woker 节点上的交换功能（Swap）

2.检查下列模组是否存在-所有节点

```
for module in br_netfilter ip6_udp_tunnel ip_set ip_set_hash_ip ip_set_hash_net iptable_filter iptable_nat iptable_mangle iptable_raw nf_conntrack_netlink nf_conntrack nf_conntrack_ipv4   nf_defrag_ipv4 nf_nat nf_nat_ipv4 nf_nat_masquerade_ipv4 nfnetlink udp_tunnel veth vxlan x_tables xt_addrtype xt_conntrack xt_comment xt_mark xt_multiport xt_nat xt_recent xt_set  xt_statistic xt_tcpudp;
    do
      if ! lsmod | grep -q $module; then
        echo "module $module is not present";
      fi;
    done

```

3.修改sysctl配置-所有节点

```
vi /etc/sysctl.conf
## 加入如下
net.bridge.bridge-nf-call-iptables=1
## 重新加载配置
sysctl -p /etc/sysctl.conf

```

9.SSH server配置

```
vi /etc/ssh/sshd_config

## 允许TCP转发
AllowTcpForwarding yes

```

# 安装

1.  下载rke二进制包 [https://github.com/rancher/rke/releases](https://links.jianshu.com/go?to=https://github.com/rancher/rke/releases)

```
wget https://github.com/rancher/rke/releases/download/v1.2.4-rc9/rke_linux-amd64

```

2.  下载 kubectl 

```
curl -LO https://dl.k8s.io/release/v1.20.0/bin/linux/amd64/kubectl

```

3.  分到到集群maser节点

```
 export host_ip=106.75.97.225
 scp kubectl root@${host_ip}:/usr/bin/
 scp rke root@${host_ip}:/usr/bin/

```

3.  修改文件名并执行运行权限

```
chmod +x /usr/bin/rke  /usr/bin/kubectl

```

4.  创建用户-所有节点

```
useradd rke                       # 创建用户
usermod -aG docker rke            # 将rke用户加入docker组
echo "rke:rke_pw_xxx" | chpasswd  # 设置rke用户密码

```

登陆OPS节点

```
ssh-keygen
ssh-copy-id rke@rancher-1
ssh-copy-id rke@rancher-2
ssh-copy-id rke@rancher-3

```

检查版本

```
# rke --version
rke version v1.2.4-rc9

```

## 最小化安装k8s集群

使用RKE安装单节点K8S集群，创建cluster.yml文件

```
cat > cluster.yml << EOF
nodes:
  - address: 106.75.97.225
    internal_address: 10.9.67.121
    user: rke
    role:
      - controlplane
      - etcd
      - worker
    taints: []
  - address: 117.50.88.223
    internal_address: 10.9.169.80
    user: rke
    role:
      - controlplane
      - etcd
      - worker
    taints: []
  - address: 117.50.22.139
    internal_address: 10.9.177.187
    user: rke
    role:
      - controlplane
      - etcd
      - worker
    taints: []
network:
  plugin: flannel
EOF

```

RKE 节点通用选项说明

 | 选项 | 是否必选 | 描述 |
| address | 是 | 公共 DNS 或 IP 地址 |
| user | 是 | 可以执行 docker 命令的用户 |
| role | 是 | 给节点分配的 Kubernetes 角色列表 |
| internal_address | 否 | 给集群内部流量使用的私有 DNS 或者 IP 地址 |
| ssh_key_path | 否 | 用来登录节点的 SSH 私钥路径 ，默认值为 ~/.ssh/id_rsa |</byte-sheet-html-origin> 

可以通过向导方式创建RKE参考配置文件

```
rke config --name cluster-example.yml

```

执行安装

拉取镜像时间会比较长，可以后台执行:

```
nohup rke up --config cluster.yml &> /tmp/log &

```

安装成功后会生成相关文件

*   cluster.yml：RKE 集群的配置文件。
*   kube_config_cluster.yml：该集群的包含了获取该集群所有权限的认证凭据。
*   cluster.rkestate：Kubernetes 集群状态文件，包含了获取该集群所有权限的认证凭据，使用 RKE v0.2.0 时才会创建这个文件。

## 安装后

```
mkdir -pv ~/.kube
cp kube_config_cluster.yml ~/.kube/config

```

如果使用自签名证书, 需要在 pod 所在ns创建名为tls-ca 的secret，执行命令

## 验证安装

```
[root@mldong01 ]# kubectl get nodes
NAME       STATUS   ROLES                      AGE     VERSION
mldong01   Ready    controlplane,etcd,worker   3d16h   v1.19.6
[root@mldong01 ]# kubectl get cs

```

