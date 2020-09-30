# fd.io APP

## 安装

cat > /etc/apt/sources.list.d/99fd.io.list <<EOF
deb [trusted=yes] https://packagecloud.io/fdio/release/ubuntu bionic main
EOF
curl -L https://packagecloud.io/fdio/release/gpgkey | sudo apt-key add -
sudo apt-get update
sudo apt-get install vpp vpp-plugin-core vpp-plugin-dpdk -y


## 使用

### 运行 fd.io app

cat > startup1.conf << EOF
unix {nodaemon cli-listen /run/vpp/cli-vpp1.sock}
api-segment { prefix vpp1 }
plugins { plugin dpdk_plugin.so { disable } }
EOF
/usr/bin/vpp -c startup1.conf &> /dev/null &

登陆VPP shell 
vppctl -s /run/vpp/cli-vpp1.sock
vpp# 
ctrl-d 或者 q 退出 VPP shell.


### 绑定 DPDK 网卡

将要绑定的网卡停掉,获取 PCI 设备ID 
root@host#  ifconfig eth1 down
root@host#  lshw -class network -businfo 

修改 /etc/vpp/startup.conf 补全如下部分参考配置
```
dpdk {
 dev 0000:00:07.0
}
plugins {
        plugin dpdk_plugin.so { enable }
}
```
重启vpp服务，登陆vpp shell

vpp# show interface addr   
vpp# set interface state GigabitEthernet0/7/0 up
vpp# set interface ip address GigabitEthernet0/7/0 10.10.2.120/24  


### tap 

vpp# create tap id 0
host# ifconfig tap0 10.10.2.119/24
vpp# set interface l2 xconnect tap0 GigabitEthernet0/7/0
vpp# set interface l2 xconnect GigabitEthernet0/7/0 tap0
vpp# set interface state GigabitEthernet0/7/0 up                             
vpp# set interface state tap0 up

### 创建虚拟网络设备 veth-pair 

ip link add name vpp1out type veth peer name vpp1host
ip link set dev vpp1out up
ip link set dev vpp1host up
ip addr add 10.10.1.15/24 dev vpp1host

vppctl -s /run/vpp/cli-vpp1.sock
vpp# create host-interface name vpp1out
vpp# show hardware
vpp# set int state host-vpp1out up
vpp# show int
vpp# set int ip address host-vpp1out 10.10.1.16/24
vpp# show int addr
 

root@host# ping 10.10.1.16 -I vpp1out


** troubleshoot **
tcpdump -n -i vpp1host 

```
echo 1 > /proc/sys/net/ipv4/conf/vpp1host/accept_local
echo 1 > /proc/sys/net/ipv4/conf/vpp1out/accept_local
echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter
echo 0 > /proc/sys/net/ipv4/conf/vpp1host/rp_filter
echo 0 > /proc/sys/net/ipv4/conf/vpp1out/rp_filter
```

## 场景

1. 多云互联

## 参考

* https://fd.io/docs/vpp/master/gettingstarted/progressivevpp/interface.html
