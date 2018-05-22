# onebox prep  

1. install soft:   
* centos7    
```
yum install curl tar iproute openssh net-tools wget lsof ntpdate nc iotop sysstat procps-ng bridge-utils lvm2 glusterfs*
sestatus
swapoff -a
systemctl enable rc-local 
systemctl stop firewalld
systemctl disable firewalld
systemctl disable chronyd
modprobe br_netfilter
modprobe nf_conntrack 
cat > /etc/modprobe.d/alauda-km.conf << EOF
br_netfilter
nf_conntrack 
EOF 
```
