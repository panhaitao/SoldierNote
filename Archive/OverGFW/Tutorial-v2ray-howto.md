# V2Ray 部署指南

## 安装V2Ray服务端

* 准备一个国外的 centos7 vps
* 关闭防火墙: iptables -F; systemctl stop firewalld
* 安装配置服务端: ` bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) `
* 创建服务端配置文件 /usr/local/etc/v2ray/config.json ( inbounds.settings.clients.id 可以使用uuidgen生成 )
```
{
    "log": {
        "loglevel": "warning"
    },
    "routing": {
        "domainStrategy": "AsIs",
        "rules": [
            {
                "ip": [
                    "geoip:private"
                ],
                "outboundTag": "blocked",
                "type": "field"
            }
        ]
    },
    "inbounds": [
        {
            "port": 10099,
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "88186910-3cf3-4c9c-b17e-46d0f69b9275",
                        "alterId": 4
                    }
                ]
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        },
        {
            "protocol": "blackhole",
            "tag": "blocked"
        }
    ]
}
```
* 启动V2Ray服务,执行命令: systemctl start v2ray && systemctl enable v2ray
* 查看/usr/local/etc/v2ray/config.json 记下 inbounds.settings.clients.id , inbounds.port 和 v2rayServer IP 配置客户端需要的字段

## 客户端

1. 获取对应系统版本的压缩包: https://github.com/v2ray/v2ray-core/releases/tag/v4.28.2
2. 创建客户端配置, 例如 hk-vpn-config.json 使用服务端配置v2rayServer端记下的信息替换
v2rayServer inbounds.settings.clients.id  -> outbounds.settings.vnext.users [{"id": "xxxxx-xxx-xxx-xxx-xxx"}]
v2rayServer inbounds.port                 -> outbounds.settings.vnext.port 
v2rayServer IP                            -> outbounds.settings.vnext.address
```
{
  "inbounds": [{
    "port": 1080,  // Port of socks5 proxy. Point your browser to use this port.
    "listen": "127.0.0.1",
    "protocol": "socks",
    "settings": {
      "udp": true
    }
  }],
  "outbounds": [{
    "protocol": "vmess",
    "settings": {
      "vnext": [{
        "address": "x.x.x.x",
        "port": 10099,
        "users": [{ "id": "88186910-3cf3-4c9c-b17e-46d0f69b9275" }]
      }]
    }
  },{
    "protocol": "freedom",
    "tag": "direct",
    "settings": {}
  }],
  "routing": {
    "domainStrategy": "IPOnDemand",
    "rules": [{
      "type": "field",
      "ip": ["geoip:private"],
      "outboundTag": "direct"
    }]
  }
}
```
3. 在v2ray压缩包解压后的目录执行: nohup ./v2ray -config v2ray-client-config.json &> /tmp/v2ray-client.log &
4. 配置系统网络代理或者浏览器代理,socks代理: 127.0.0.1:1080 ,然后开启你的OverGFW之路.

## 参考文档

* https://github.com/v2fly/fhs-install-v2ray
