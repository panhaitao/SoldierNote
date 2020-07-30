# ubuntu LTS 升级

ubuntu16.04 Poc 环境集群已经搭建 ACP2.2.2 已知问题：

安装过程需要手动docker-ce-cli 18.xx版本，安装脚本会安装19.04高版本导致部署失败
安装后kafka/zk 因为容忍标签无法调度在三节点，日志功能可不用
预设应用：
* 应用 tomat+ mysql
* 流水线 无
* 告警 有
* 监控 有
* 用户 有
* 权限 有
* pv/pvc 有

## 升级操作系统

需要逐步升级 16.04 -> 18.04 -> 20.04

操作步骤，升级 16.04 -> 18.04：

检查 /etc/update-manager/release-upgrades 确认 Prompt=lts
执行命令 apt update && apt upgrade -y
编辑 /etc/apt/sources.list 新增加 18.04 仓库地址

```
deb http://mirrors.tencentyun.com/ubuntu/ bionic main restricted universe multiverse
deb http://mirrors.tencentyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb http://mirrors.tencentyun.com/ubuntu/ bionic-updates main restricted universe multiverse
 
apt update && apt dist-upgrade -y
do-release-upgrade
reboot
```

操作步骤，18.04 -> 20.04
检查 /etc/update-manager/release-upgrades 确认 Prompt=lts
执行命令 apt update && apt upgrade -y
编辑 /etc/apt/sources.list 新增加 20.04 仓库地址

```
deb http://mirrors.tencentyun.com/ubuntu/ focal main restricted universe multiverse
deb http://mirrors.tencentyun.com/ubuntu/ focal-security main restricted universe multiverse
deb http://mirrors.tencentyun.com/ubuntu/ focal-updates main restricted universe multiverse
apt update && apt dist-upgrade -y
do-release-upgrade
reboot
```

升级过程异常记录
现象:

plymouth-theme-ubuntu-text
plymouth-theme-ubuntu-text
 
Processing was halted because there were too many errors.
 
E: Sub-process /usr/bin/dpkg returned an error code (1)


解决办法：



编辑 /var/lib/dpkg/status
 
在该文件下面找到Package: plymouth-theme-ubuntu-text开头的整段内容，大概25行左右。删除，保存退出（25dd， :wq）
 
就是报错的包。
 
再执行apt-get -f install


测试验证
操作系统已经顺利从ubuhtu16.04 升级到20.04
docker kubelet 服务运行正常
acp 平台可以正常访问，平台页面基本功能正常
测试部署的tomat mysql 应用正常，历史项目未丢失，告警显示正常
平台接口功能功能未做测试
