k8s
---

-   master 端的公共配置 /etc/kubernetes/config

<!-- -->

    /etc/kubernetes/config 
    KUBE_MASTER="--master=https://10.1.10.232:6443"
    KUBE_CONFIG="--kubeconfig=/etc/kubernetes/kubeconfig"
    KUBE_COMMON_ARGS="--logtostderr=true --v=1" 

    #KUBE_COMMON_ARGS="--logtostderr=true --v=1 --allow-privileged=false"

/etc/kubernetes/config 配置记录的所有组件的公共配置

-   kube-apiserver.service
-   kube-controller-manager.service
-   kube-scheduler.service
-   kubelet.service
-   kube-proxy.service

k8s-api-server
--------------

-   /lib/systemd/system/kube-apiserver.service

<!-- -->

    [Unit]
    Description=Kubernetes API Server
    Documentation=https://github.com/GoogleCloudPlatform/kubernetes
    After=network.target
    After=etcd.service

    [Service]
    PermissionsStartOnly=true
    ExecStartPre=-/usr/bin/mkdir -pv /var/run/kubernetes
    #ExecStartPre=/usr/bin/chown -R kube:kube /var/run/kubernetes/
    EnvironmentFile=-/etc/kubernetes/config
    EnvironmentFile=-/etc/kubernetes/apiserver
    #User=kube
    ExecStart=/usr/bin/kube-apiserver   \
                $KUBE_ETCD_SERVERS      \
                $KUBE_ADMISSION_CONTROL \
            $KUBE_COMMON_ARGS       \
            $KUBE_API_ARGS
    Restart=on-failure
    Type=notify
    LimitNOFILE=65536

    [Install]
    WantedBy=multi-user.target

-   /etc/kubernetes/apiserver

<!-- -->

    KUBE_ETCD_SERVERS="--storage-backend=etcd3 --etcd-servers=http://10.1.10.232:2379"

    #KUBE_ADMISSION_CONTROL="--admission-control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota"
    KUBE_ADMISSION_CONTROL="--admission-control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ResourceQuota"

    KUBE_API_ARGS="--service-node-port-range=1-65535 --service-cluster-ip-range=10.254.0.0/16 --bind-address=0.0.0.0 --insecure-port=0 --secure-port=6443 --client-ca-file=/etc/kubernetes/ca/ca.crt --tls-cert-file=/etc/kubernetes/ca/server.crt --tls-private-key-file=/etc/kubernetes/ca/server.key"

-   这里监听SSL/TLS的端口是6443；若指定小于1024的端口，有可能会导致启动apiServer启动失败
-   在master机器上，默认开8080端口提供未加密的HTTP服务,可以通过--insecure-port=0
    参数来关闭

k8s-client
----------

### kube-controller-manager

-   /lib/systemd/system/kube-controller-manager.service

<!-- -->

     
    [Unit]
    Description=Kubernetes Controller Manager
    Documentation=https://github.com/GoogleCloudPlatform/kubernetes

    [Service]
    EnvironmentFile=-/etc/kubernetes/config
    EnvironmentFile=-/etc/kubernetes/controller-manager
    #User=kube
    ExecStart=/usr/bin/kube-controller-manager \
            $KUBE_MASTER                   \
            $KUBE_COMMON_ARGS              \
            $KUBE_CONTROLLER_MANAGER_ARGS
    Restart=on-failure
    LimitNOFILE=65536

    [Install]
    WantedBy=multi-user.target

-   /etc/kubernetes/controller-manager

<!-- -->

    KUBE_CONTROLLER_MANAGER_ARGS="--cluster-signing-cert-file=/etc/kubernetes/ca/server.crt --cluster-signing-key-file=/etc/kubernetes/ca/server.key --root-ca-file=/etc/kubernetes/ca/ca.crt --kubeconfig=/etc/kubernetes/kubeconfig"

### kube-scheduler

-   /lib/systemd/system/kube-scheduler.service

<!-- -->

    [Unit]
    Description=Kubernetes Scheduler Plugin
    Documentation=https://github.com/GoogleCloudPlatform/kubernetes

    [Service]
    EnvironmentFile=-/etc/kubernetes/config
    EnvironmentFile=-/etc/kubernetes/scheduler
    #User=kube
    ExecStart=/usr/bin/kube-scheduler   \
            $KUBE_MASTER            \
            $KUBE_COMMON_ARGS       \
            $KUBE_SCHEDULER_ARGS
    Restart=on-failure
    LimitNOFILE=65536

    [Install]
    WantedBy=multi-user.target

-   /etc/kubernetes/scheduler

<!-- -->

    KUBE_SCHEDULER_ARGS="--kubeconfig=/etc/kubernetes/kubeconfig"

k8s-nodes
---------

-   docker OPTIONS for kubelet

<!-- -->

    OPTIONS='--selinux-enabled --log-driver=journald --signature-verification=false --exec-opt native.cgroupdriver=systemd -H unix:///var/run/docker.sock --insecure-registry=registry.deepin.com'

### kubelet.service

-   /lib/systemd/system/kubelet.service

<!-- -->

    [Unit]
    Description=Kubernetes Kubelet Server
    Documentation=https://github.com/GoogleCloudPlatform/kubernetes
    After=docker.service
    Requires=docker.service

    [Service]
    WorkingDirectory=/var/lib/kubelet
    EnvironmentFile=-/etc/kubernetes/config
    EnvironmentFile=-/etc/kubernetes/kubelet
    ExecStart=/usr/bin/kubelet \
            $KUBELET_ADDRESS \
            $KUBELET_HOSTNAME \
            $KUBELET_POD_INFRA_CONTAINER \
            $KUBE_COMMON_ARGS            \
            $KUBELET_ARGS
    Restart=on-failure

    [Install]
    WantedBy=multi-user.targe

-   /etc/kubernetes/kubelet

<!-- -->

    KUBELET_ADDRESS="--address=0.0.0.0"
    KUBELET_HOSTNAME="--hostname-override=k8s-node1"
    KUBELET_POD_INFRA_CONTAINER="--pod-infra-container-image=registry.deepin.com/library/pod-infrastructure"
    KUBELET_ARGS="--kubeconfig=/etc/kubernetes/kubeconfig --cgroup-driver=systemd --fail-swap-on=false --runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice"

### kube-proxy

-   /lib/systemd/system/kube-proxy.service

<!-- -->

    [Unit]
    Description=Kubernetes Kube-Proxy Server
    Documentation=https://github.com/GoogleCloudPlatform/kubernetes
    After=network.target

    [Service]
    EnvironmentFile=-/etc/kubernetes/config
    EnvironmentFile=-/etc/kubernetes/proxy
    ExecStart=/usr/bin/kube-proxy \
            $KUBE_LOGTOSTDERR \
            $KUBE_LOG_LEVEL \
            $KUBE_MASTER \
            $KUBE_COMMON_ARGS       \
            $KUBE_PROXY_ARGS
    Restart=on-failure
    LimitNOFILE=65536

    [Install]
    WantedBy=multi-user.target

-   /etc/kubernetes/proxy

<!-- -->

    KUBE_PROXY_ARG="--kubeconfig=/etc/kubernetes/kubeconfig"

kubectl
-------

查看pod

    kubectl --kubeconfig=/etc/kubernetes/kubeconfig get nodes
    kubectl --kubeconfig=/etc/kubernetes/kubeconfig get deployments --all-namespaces
    kubectl --kubeconfig=/etc/kubernetes/kubeconfig get ReplicationController  --all-namespaces
    kubectl --kubeconfig=/etc/kubernetes/kubeconfig get DaemonSets  --all-namespaces
    kubectl --kubeconfig=/etc/kubernetes/kubeconfig get ReplicaSets --all-namespaces
    kubectl --kubeconfig=/etc/kubernetes/kubeconfig get pods --all-namespaces

查看endpoint

    kubectl get services  --all-namespaces
    kubectl get endpoints  --all-namespaces

参考
----

- kubeconfig yaml格式参考：
<https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/>

记录
----

### 问题一

    tail -f /var/log/message
    Nov 14 07:12:51 image kubelet: E1114 07:12:51.627782    3007 summary.go:92] Failed to get system container stats for "/system.slice/kubelet.service": failed to get cgroup 
    stats for "/system.slice/kubelet.service": failed to get container info for "/system.slice/kubelet.service": unknown container "/system.slice/kubelet.service"
    Nov 14 07:12:51 image kubelet: E1114 07:12:51.627824    3007 summary.go:92] Failed to get system container stats for "/system.slice/docker.service": failed to get cgroup s
    tats for "/system.slice/docker.service": failed to get container info for "/system.slice/docker.service": unknown container "/system.slice/docker.service"

    * 处理办法：

    Append configuration in Kubelet
    --runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice
