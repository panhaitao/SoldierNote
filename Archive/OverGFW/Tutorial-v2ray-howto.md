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


## MacOS 下终端中配置socks5代理

1. 安装privoxy, 执行命令: brew install privoxy
2. 修改privoxy配置 /usr/local/etc/privoxy/config,加入下面这两项配置项
```
listen-address 0.0.0.0:8118
forward-socks5 / localhost:1080 .
```
第一行设置privoxy监听任意IP地址的8118端口
第二行设置本地socks5代理客户端端口，注意不要忘了最后有一个空格和点号。

4. 启动privoxy
因为没有安装在系统目录内，所以启动的时候需要打全路径。
sudo /usr/local/sbin/privoxy /usr/local/etc/privoxy/config

5. 查看是否启动成功
netstat -na | grep 8118
看到有类似如下信息就表示启动成功了
tcp4       0      0  *.8118                 *.*                    LISTEN
如果没有，可以查看日志信息，判断哪里出了问题。打开配置文件找到 logdir 配置项，查看log文件。

6. privoxy使用
在命令行终端中输入如下命令后，该终端即可翻墙了。

export http_proxy='http://localhost:8118'
export https_proxy='http://localhost:8118'
他的原理是讲socks5代理转化成http代理给命令行终端使用。

如果不想用了取消即可

unset http_proxy
unset https_proxy
如果关闭终端窗口，功能就会失效，如果需要代理一直生效，则可以把上述两行代码添加到 ~/.bash_profile 文件最后。

vim ~/.bash_profile
-----------------------------------------------------
export http_proxy='http://localhost:8118'
export https_proxy='http://localhost:8118'
-----------------------------------------------------
使配置立即生效

source  ~/.bash_profile
还可以在 ~/.bash_profile 里加入开关函数，使用起来更方便

function proxy_off(){
    unset http_proxy
    unset https_proxy
    echo -e "已关闭代理"
}

function proxy_on() {
    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
    export http_proxy="http://127.0.0.1:8118"
    export https_proxy=$http_proxy
    echo -e "已开启代理"
}

## 参考文档

* https://github.com/v2fly/fhs-install-v2ray


