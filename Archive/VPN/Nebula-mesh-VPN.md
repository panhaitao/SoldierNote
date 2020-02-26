# Nebula 分布式VPN 

* 项目源码：https://github.com/slackhq/nebula
* 二进制包: https://github.com/slackhq/nebula/releases

## 简介

  分布式 VPN 网状网工具 Nebula，源代码发布在 GitHub 上，采用 MIT 许可证。对于 Nebula 的开发动机，工程师解释说，他们问了自己一个问题：有什么最简单的方法安全连接不同云服务商在全球数十个位置的数万台计算机？Nebula 就是他们自己给出的答案。它是一个可携式可伸缩的叠加网工具，支持 Linux、MacOS 和 Windows，未来将加入对移动平台的支持。Nebula 传输的数据使用 Noise 协议框架完整加密，该框架也被 Signal 和 WireGuard 等项目使用。Nebula 能自动动态的发现不同节点之间的可用路线，在任何两个节点之间以最高效的路径发送流量，不需要经过一个中心的分配点。举例来说，你在笔记本电脑、家用 PC 和一个云端节点都运行了 Nebula，当你在家里使用笔记本电脑时，它会通过家用主机以 LAN 的速度进行通信。

## Nebula mesh VPN init

1. 获取应用程序，二进制包下载地址: https://github.com/slackhq/nebula/releases
2. 创建证书:
```  
nebula-cert ca -name "Nebula Mesh Network"
nebula-cert sign -name "lighthouse"      -ip "192.168.98.1/24"
nebula-cert sign -name "laptop-macbook"  -ip "192.168.98.2/24"
nebula-cert sign -name "laptop-thinkpad" -ip "192.168.98.3/24"
nebula-cert sign -name "workstation-pc"  -ip "192.168.98.4/24"
```

3. 创建config.yml

```
pki:
  ca: /etc/nebula/ca.crt
  cert: /etc/nebula/host.crt
  key: /etc/nebula/host.key

static_host_map:
  "192.168.100.1": ["100.64.22.11:4242"]


lighthouse:
  am_lighthouse: false
  #serve_dns: false
  #dns:
    #host: 0.0.0.0
    #port: 53
  interval: 60
  hosts:
    - "192.168.100.1"

listen:
  host: 0.0.0.0
  port: 4242
  #batch: 64
  #read_buffer: 10485760
  #write_buffer: 10485760

punchy: true
#punch_back: true
#cipher: chachapoly
#local_range: "172.16.0.0/24"
#sshd:
  #enabled: true
  #listen: 127.0.0.1:2222
  #host_key: ./ssh_host_ed25519_key
  #authorized_users:
    #- user: steeeeve
      #keys:
        #- "ssh public key string"

tun:
  dev: nebula1
  drop_local_broadcast: false
  drop_multicast: false
  tx_queue: 500
  mtu: 1300
  routes:
    #- mtu: 8800
    #  route: 10.0.0.0/16
  unsafe_routes:
    #- route: 172.16.1.0/24
    #  via: 192.168.100.99
    #  mtu: 1300 #mtu will default to tun mtu if this option is not sepcified

logging:
  # panic, fatal, error, warning, info, or debug. Default is info
  level: info
  # json or text formats currently available. Default is text
  format: text

#stats:
  #type: graphite
  #prefix: nebula
  #protocol: tcp
  #host: 127.0.0.1:9999
  #interval: 10s

  #type: prometheus
  #listen: 127.0.0.1:8080
  #path: /metrics
  #namespace: prometheusns
  #subsystem: nebula
  #interval: 10s

# Handshake Manger Settings
#handshakes:
  # Total time to try a handshake = sequence of `try_interval * retries`
  # With 100ms interval and 20 retries it is 23.5 seconds
  #try_interval: 100ms
  #retries: 20
  # wait_rotation is the number of handshake attempts to do before starting to try non-local IP addresses
  #wait_rotation: 5

# Nebula security group configuration
firewall:
  conntrack:
    tcp_timeout: 120h
    udp_timeout: 3m
    default_timeout: 10m
    max_connections: 100000

  outbound:
    # Allow all outbound traffic from this node
    - port: any
      proto: any
      host: any

  inbound:
    # Allow icmp between any nebula hosts
    - port: any
      proto: any
      host: any

    # Allow tcp/443 from any host with BOTH laptop and home group
    - port: 443
      proto: tcp
      groups:
        - laptop
        - home
```


4. 最后每个节点：./nebula -config /path/to/config.yaml

## 参考

* https://github.com/slackhq/nebula/blob/master/examples/config.yml
* https://arstechnica.com/gadgets/2019/12/how-to-set-up-your-own-nebula-mesh-vpn-step-by-step/
