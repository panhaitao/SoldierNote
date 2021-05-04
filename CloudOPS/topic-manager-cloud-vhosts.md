# 使用Ucloud云平台API管理云主机

# 背景

某p2p客户，需要在数天内天内在海外可用区创建数千台云主机用于测试，如果只是在一个数据中心可用区，只需要做资源报备，然后调用API批量创建即可，但是对于在存量资源不多，且分布在众多海外可用区，要保证海外可用去平稳运行，同时又要能交付数千台云主机，需要注意的事项还是很多，这里对实际交付过程做了一个总结记录。
前期工作

# 客户侧沟通记录
- 业务场景：P2P，主要对公网带宽依赖，节点数依赖，对主机CPU，内存，IO，网卡吞吐能力要求不高，PPS不高，不需要25G虚拟网卡
- 选用可用区：台北，东京，香港，曼谷，首尔
- 机型配置: 快杰机型  2核2G内存 60G存储，外网带宽3M 期望CPU主频 2.5GHz以上

## 云平台侧沟通

### 关注点 
1. 主机计算资源
2. 虚拟网卡
3. API超时问题,
4. 存储IO能力
5. 可用区剩余物理带宽
6. 可用EIP数量
7. IGW转发能力

### 确认事项
 
1. 需要提前咨询统计，计算资源是否充足
2. 需要考虑宿主机VF网卡耗尽的问题，如果vnet网卡满足，在创建云主机可以选择关闭网络增强来保障创建更多云主机
4. 通过SDK批量调用API创建云主机经常面临超时问题，调整API地址, 从公网入口 https://api.ucloud.cn 改为内网入口 http://api.service.ucloud.cn 
5. 由于部分海外可用区存储池比较小，在批量创建删除云主机,导致对存储IO冲击很大，建议控制每批任务50台-100台，或者控制创建主机时间间隔，设置为 3s 左右，可以保证持续创建几百台云主机，同时能避免对存储IO造成冲击
6. 海外可用区国际物理带宽和入向回国带宽，需要提前预估报备，及时和后端运营确认余量，如不足，及时评估扩容
7. 可用公网IP需要及时后端运营确认余量，如不足，及时扩容
8. 确认客户业务对网关的吞吐能力要求，如不足，及时扩容

## 交付过程

### 准备工作

在何客户沟通，和公司后端运营沟通，确认资源充足的情况后，做调用SDK进行批量创建主机的准备工作
1. 在选定的可用区
  a. 创建主机模版镜像，并记录镜像ID，建议分别在海外可用区分别创建一台云主机，制作系统模版镜像，如果镜像太大跨国同步镜像耗时比较长
  b. 创建防火墙规则，并记录防火墙ID
  c. 创建对应业务组，并记录业务组名称
2. 准备一台可以访问互联网的Linux主机，用来操作API，以centos7 为例，需要安装如下软件包：
 ```
yum install python3 -y
yum install python3-pip -y
pip3 install pyyaml -y
pip3 install ucloud-sdk-python3 如果pip安装失败 
git clone https://github.com/ucloud/ucloud-sdk-python3.git
cd ucloud-sdk-python3
python3 setup.py install
```

### 场景一： 批量创建云主机
1. 在这里使用已经调试好的API脚本来创建云主机，可以参考https://github.com/panhaitao/Playbooks/blob/main/scripts/create_uhost_Network_3M.py  批量创建可以使用如下参考执行方式：
```
python3 create_uhost_Network_3M.py --config hk-uhost-config.yaml
python3 create_uhost_Network_3M.py --config jpn-uhost-config.yaml
python3 create_uhost_Network_3M.py --config kr-uhost-config.yaml
```
其中 xx-uhost-config.yaml  参考说明
```
auth:
  public_key: 'public_key_token_xxx'        # ucloud api 公钥
  private_key: 'private_key_token_xxx'      # ucloud api 私钥
rz:
  region: hk              # 地域
  zone: hk-02             # 可用区 
  project_id: org-zpkrui  # 项目ID
  securitygroupid: firewall-ciislsow # 外网防火墙ID
os:
  hostname_pre: hk-uhost    #主机前缀名称 
  password: xxxxxxxx        #主机用户密码
  imageid: uimage-5x03ylry  #系统镜像ID
  type: O                   #Vhost主机类型，O 是快杰型，N 是通用型
  charge_type: Month        #按月付费
  cpu: 2                    #CPU核数
  mem: 2048                 #内存大小 
  net_capability: Normal    #虚拟网卡模式，Ultra 是25G模式，Normal 是10G模式
disk:
  - IsBoot: true            #true 是系统盘，false是数据盘
    type: CLOUD_RSSD        #CLOUD_RSSD 是高性能SSD云盘， CLOUD_SSD 是普通云盘 
    size: 60                #磁盘大小
tag: host-owner-hk          #业务组名称 
inventory:
  name: inventory
  maxhosts: 500             #创建主机数量
  group: host-owner-hk      #业务组名称
```
### 场景二: 批量变更主机配置

在这里使用已经调试好的API脚本来变更主机配置，可以参考https://github.com/panhaitao/Playbooks/blob/main/scripts/modify_uhost_config.py  参考执行方式如下：
```
python3 modify_uhost_config.py --config gd-modify-host.yaml
python3 modify_uhost_config.py --config hk-modify-host.yaml
python3 modify_uhost_config.py --config jpn-modify-host.yaml
```
其中 modify-host-example.yaml 参考配置说明
```
auth:
 public_key: 'public_key_token_xxx'       # ucloud api 公钥
 private_key: 'private_key_token_xxx'     # ucloud api 私钥 
rz:
 region: cn-gd                            # 地域
 zone: cn-gd-02                           # 可用区 
 project_id: org-5wakzh                   # 项目ID 
os:
 cpu: 2                                   # CPU核数
 mem: 8192                                # 内存大小 
exclude: 
  - uhost-ratiyrbc                        # 忽略的主机列表 
```
使用API可以做到更自定义的主机配置 CPU:MEM 组合： 2核4G , 2核6G，2核8G 

## 检查确认

创建完毕或者变更后的主机，需要对主机进行基本的登录检查确认，在这里使用ansible，和使用动态 Inventory来完成操作，可以复用之前安装 ucloud-sdk-python3的主机，需要额外安装 ansible 软件包，执行命令:  
` yum install ansible git -y `

动态 Inventory 需要 ansible.conf 定义的配置 inventory = inventory/ucloud.py, 当ansible 工作的时候，会自动引用inventory/ucloud.py --list的输出作为输入，就不必再手动生成Inventory主机列表文件，获取 Playbooks 配置库:
`git clone https://github.com/panhaitao/Playbooks.git 进入Playbooks 目录创建 inventory/ucloud.ini` 

参考如下
```
[ucloud]
public_key = public_key_token_xxx        ; ucloud api 公钥
private_key = private_key_token_xxx      ; ucloud api 私钥
base_url = http://api.ucloud.cn/      
region = th-bkk-02                       ; 可用区ID

[cache]
path = tmp/cache/ansible-ucloud.cache
max_age = 86400

;; General ssh options for all uhosts
[uhost]
group = all
tag = %(Tag)s
name = %(PublicIP)s
#name = %(InternationalIP)s
;; name = %(Name)s
;; Use domain
;  host = %(Name)s.example.com
;; Use Public IP
host = %(PublicIP)s                      ；通过公网IP 连接 
ssh_port = 22                            ；默认ssh 端口 
ssh_user = ubuntu                        ；默认ssh 登录用户名
ssh_password = host_passwd_xxx           ；默认ssh 登录的使用密码 
winrm_port = 5985                        ；windows 主机远程登录方式(可选)
winrm_user = Administrator               ；windows 主机远程登录默认用户(可选)
winrm_password = PWxxxxx                 ；windows 主机远程登录用户密码(可选)
```
主机基本状态检查，执行命令：
`cd Playbooks && rm -rvf tmp/ &&  python inventory/ucloud.py && ansible all -m shell -a "df -H" `
确认主机可以远程登录，主机磁盘大小正常，基础命令执行无异常，可以交付给客户使用。

## 其他记录

客户购买主机使用带宽付费模式，按照云平台规则，如果默认EIP 出向带宽小于50M，则入向带宽上限为50M，如果客户购买EIP数量比较多，比如在再一个可用区购买1000台，可能产生5T的峰值入向带宽，这将对可用区的物理带宽带来巨大冲击，遇到此类场景，需要和客户沟通解释，是够需要入向带宽50M：
- 如果需要，可以咨询网络运营同事，咨询可用物理带宽为多少，按照50M带宽上限来规划新建主机数量
- 如果不需要，可以向网络同事提交非标申请，限制 出向/入向 带宽比，避免耗尽可用区物理带宽资源

## 参考说明

- ucloud api 公钥/私钥可从这里查看: https://console.ucloud.cn/uapi/apikey
- 如何生成创建云主机的代码可参考: https://console.ucloud.cn/uapi/ucloudapi，
- 关于地域和可用区列表可以可参考: https://docs.ucloud.cn/api/summary/regionlist
