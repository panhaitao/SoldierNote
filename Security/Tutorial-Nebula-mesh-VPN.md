# Nebula 分布式VPN 

* 项目源码：https://github.com/slackhq/nebula
* 二进制包: https://github.com/slackhq/nebula/releases

## 简介

  分布式 VPN 网状网工具 Nebula，源代码发布在 GitHub 上，采用 MIT 许可证。对于 Nebula 的开发动机，工程师解释说，他们问了自己一个问题：有什么最简单的方法安全连接不同云服务商在全球数十个位置的数万台计算机？Nebula 就是他们自己给出的答案。它是一个可携式可伸缩的叠加网工具，支持 Linux、MacOS 和 Windows，未来将加入对移动平台的支持。Nebula 传输的数据使用 Noise 协议框架完整加密，该框架也被 Signal 和 WireGuard 等项目使用。Nebula 能自动动态的发现不同节点之间的可用路线，在任何两个节点之间以最高效的路径发送流量，不需要经过一个中心的分配点。举例来说，你在笔记本电脑、家用 PC 和一个云端节点都运行了 Nebula，当你在家里使用笔记本电脑时，它会通过家用主机以 LAN 的速度进行通信。

## Nebula mesh VPN init

1. 获取应用程序，二进制包下载地址: https://github.com/slackhq/nebula/releases
2. 创建证书，每个节点证书对应一个ovelay ip
```  
nebula-cert ca -name "Nebula Mesh Network"
nebula-cert sign -name "lighthouse"      -ip "192.168.98.1/24"
nebula-cert sign -name "laptop-macbook"  -ip "192.168.98.2/24"
nebula-cert sign -name "laptop-thinkpad" -ip "192.168.98.3/24"
nebula-cert sign -name "workstation-pc"  -ip "192.168.98.4/24"
```

3. 创建config.yml

节点机分为灯塔机和节点两种类型，灯塔机(lighthouse)参考配置如下：

```
pki:
  ca: /etc/nebula/ca.crt
  cert: /etc/nebula/lighthouse.crt
  key: /etc/nebula/lighthouse.key

static_host_map:
  "192.168.168.1": ["45.76.101.137:4242"]

lighthouse:
  am_lighthouse: true
  #serve_dns: false
  #dns:
    #host: 0.0.0.0
    #port: 53
  interval: 60
  hosts:
    - "192.168.168.1"

listen:
  host: 0.0.0.0
  port: 4242

punchy: true
punch_back: true

tun:
  dev: nebula1
  drop_local_broadcast: false
  drop_multicast: false
  tx_queue: 500
  mtu: 1300

logging:
  level: info
  format: text

firewall:
  conntrack:
    tcp_timeout: 120h
    udp_timeout: 3m
    default_timeout: 10m
    max_connections: 100000

  outbound:
    - port: any
      proto: any
      host: any

  inbound:
    - port: any
      proto: any
      host: any
```

节点机参考配置如下, 和灯塔机的主要配置差异在

1. static_host_map 这需要记录灯塔机(lighthouse)的静态映射关系即可
2. lighthouse.am_lighthouse 这里关闭即可，节点不需要在充当照亮别人的灯塔机
3. lighthouse.hosts 但是需要指定灯塔机的对应的overlay_ip
4. punch_back 这里默认打开就好，目前大多数云主机或者个人电脑都NAT模式接入

```
pki:
  ca: /etc/nebula/ca.crt
  cert: /etc/nebula/node-x.crt
  key: /etc/nebula/node-x.key

static_host_map:
  "192.168.168.1": ["45.76.101.137:4242"]

lighthouse:
  am_lighthouse: false
  interval: 60
  hosts:
    - "192.168.168.1"

listen:
  host: 0.0.0.0
  port: 4242

punchy: true
punch_back: true

tun:
  dev: nebula1
  drop_local_broadcast: false
  drop_multicast: false
  tx_queue: 500
  mtu: 1300

logging:
  level: info
  format: text

firewall:
  conntrack:
    tcp_timeout: 120h
    udp_timeout: 3m
    default_timeout: 10m
    max_connections: 100000

  outbound:
    - port: any
      proto: any
      host: any

  inbound:
    - port: any
      proto: any
      host: any
```

4. 最后每个节点：./nebula -config /path/to/config.yaml

## 参考

* https://github.com/slackhq/nebula/blob/master/examples/config.yml
* https://arstechnica.com/gadgets/2019/12/how-to-set-up-your-own-nebula-mesh-vpn-step-by-step/
* https://arstechnica.com/gadgets/2019/12/nebula-vpn-routes-between-hosts-privately-flexibly-and-efficiently/
