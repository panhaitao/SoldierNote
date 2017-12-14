k8s-master
----------

### 

k8s-nodes
---------

### kubelet

    kubectl config set-credentials k8s-custer --username=admin --password=admin
    kubectl config set-cluster k8s-server --server=https://10.1.10.238:6443
    kubectl config set-context default-context --cluster=k8s-server --user=k8s-custer
    kubectl config use-context default-context
    kubectl config set contexts.default-context.namespace the-right-prefix
    kubectl config view

/etc/kubernetes/kubeconfig

    apiVersion: v1
    clusters:
    - cluster:
        server: https://10.1.10.238:443
      name: k8s-server
    contexts:
    - context:
        cluster: k8s-server
        namespace: the-right-prefix
        user: k8s-custer
      name: default-context
    current-context: default-context
    kind: Config
    preferences: {}
    users:
    - name: k8s-custer
      user:
        password: admin
        username: admin

`   kubelet --kubeconfig=/etc/kubernetes/kubeconfig --cgroup-driver=systemd --fail-swap-on=false`

### kube-proxy

参考
----

- kubeconfig yaml格式参考：
<https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/>
