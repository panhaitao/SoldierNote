# k8s Service Account

在运行基于 Kubernetes 的 CI/CD 过程中，经常有需求在容器中对 Kubernetes 的资源进行操作，其中隐藏的安全问题，目前推荐的最佳实践也就是使用 Service Account 了。而调试账号能力的最好方法，必须是 kubectl 了。下面就讲讲如何利用 kubectl 引用 Servie Account 凭据进行 Kubernetes 操作的方法。

这里用 default Service Account 为例

假设
目前已经能对目标集群进行操作，文中需要的权限主要就是读取命名空间中的 Secret 和 Service Account。

准备配置文件
新建一个 Yaml 文件，命名请随意，例如 kubectl.yaml。内容：

apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: {ca data}
    server: https://{server}
  name: awesome-cluster
users:
- user:
    token: {token}
  name: account
- context:
    cluster: awesome-cluster
    user: account
  name: sa
current-context: sa
其中的 {ca data} 可以从现有连接凭据中获取。

{server}：服务器地址

{token}：将在后面设置

获取数据
首先查看 Service Account 的 Token 在哪里：

kubectl get serviceaccount default -o yaml

返回内容如下：

apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: 2017-05-07T10:41:50Z
  name: default
  namespace: default
  resourceVersion: "26"
  selfLink: /api/v1/namespaces/default/serviceaccounts/default
  uid: c715217d-3311-11e7-a4ae-42010a8c0095
secrets:
- name: default-token-7h4bd
这里我们看到他包含了 secret: “default-token-7h4bd”，获取其中的内容：

kubectl get secret default-token-7h4bd -o yaml

apiVersion: v1
data:
  ca.crt: [ca data]   
  namespace: ZGVmYXVsdA==
  token: [token data]
  kind: Secret
metadata:
  annotations:
    kubernetes.io/service-account.name: default
    kubernetes.io/service-account.uid: c715217d-3311-11e7-a4ae-42010a8c0095
  creationTimestamp: 2017-05-07T10:41:50Z
  name: default-token-7h4bd
  namespace: default
  resourceVersion: "24"
  selfLink: /api/v1/namespaces/default/secrets/default-token-7h4bd
  uid: c71cc72d-3311-11e7-a4ae-42010a8c0095
type: kubernetes.io/service-account-token
上面 Token Data 内容就是我们需要的认证 Token 了

export my_token="[tokendata]"
kubectl --kubeconfig=kubectl.yaml \
config set-credentials account \
--token=`echo ${tokendata} | base64 -D`
这样就把 Service Account 的 Token 取出来，并保存在 kubectl.yaml 中。利用这一配置文件就可以凭 Service Account 的身份来执行 kubectl 指令了。
