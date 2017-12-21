使用etcd,flannel,docker搭建一个跨物理机的容器集群
-------------------------------------------------

大致步骤是：

-   启动Etcd后台进程
-   在Etcd里添加Flannel的配置
-   启动Flanneld后台进程
-   配置Docker的启动参数
-   重启Docker后台进程

简单的说flannel做了三件事情：

1.  数据从源容器中发出后，经由所在主机的docker0虚拟网卡转发到flannel0虚拟网卡，这是个P2P的虚拟网卡，flanneld服务监听在网卡的另外一端。
    Flannel也是通过修改Node的路由表实现这个效果的。
2.  源主机的flanneld服务将原本的数据内容UDP封装后根据自己的路由表投递给目的节点的flanneld服务，数据到达以后被解包，然后直接进入目的节点的flannel0虚拟网卡，然后被转发到目的主机的docker0虚拟网卡，最后就像本机容器通信一样由docker0路由到达目标容器。
3.  使每个结点上的容器分配的地址不冲突。Flannel通过Etcd分配了每个节点可用的IP地址段后，再修改Docker的启动参数。“--bip=X.X.X.X/X”这个参数，它限制了所在节点容器获得的IP范围。

etcd 和flannel
--------------

    etcdctl -C http://10.1.11.168:2379 set /flannel/network/config '{"Network": "192.168.0.0/16"}'

docker 和 flannel
-----------------

- flanneld.service

    ExecStartPost=/usr/libexec/flanneld/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/docker.env

- docker.service

    [Service]
    EnvironmentFile=-/run/flannel/docker.env
