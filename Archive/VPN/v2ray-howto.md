# V2Ray 翻墙指南

## 安装V2Ray服务端

1. 准备一个国外的 centos7 vps
2. 执行命令: bash <(curl -L -s https://install.direct/go.sh)
3. 记下UUID和PORT 或者查看 /etc/v2ray/config.json
4. 启动V2Ray服务,执行命令: systemctl start v2ray && systemctl enable v2ray
5. 关闭防火墙: iptables -F; systemctl stop firewalld

## 客户端

1. macos客户端: https://github.com/Cenmrev/V2RayX/releases 配置略

 


