# k8s创建集群只读service account 

k8s 集群上给比如开发人员创建一个只读的service account，在这里记录一下创建方法, viewonly.yaml

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: oms-viewonly
rules:
- apiGroups:
  - ""
  resources:
  - configmaps
  - endpoints
  - persistentvolumeclaims
  - pods
  - replicationcontrollers
  - replicationcontrollers/scale
  - serviceaccounts
  - services
  - nodes
  - persistentvolumeclaims
  - persistentvolumes
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - bindings
  - events
  - limitranges
  - namespaces/status
  - pods/log
  - pods/status
  - replicationcontrollers/status
  - resourcequotas
  - resourcequotas/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - namespaces
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - apps
  resources:
  - daemonsets
  - deployments
  - deployments/scale
  - replicasets
  - replicasets/scale
  - statefulsets
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - autoscaling
  resources:
  - horizontalpodautoscalers
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - batch
  resources:
  - cronjobs
  - jobs
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - extensions
  resources:
  - daemonsets
  - deployments
  - deployments/scale
  - ingresses
  - networkpolicies
  - replicasets
  - replicasets/scale
  - replicationcontrollers/scale
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - policy
  resources:
  - poddisruptionbudgets
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - networkpolicies
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - storage.k8s.io
  resources:
  - storageclasses
  - volumeattachments
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - rbac.authorization.k8s.io
  resources:
  - clusterrolebindings
  - clusterroles
  - roles
  - rolebindings
  verbs:
  - get
  - list
  - watch

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: oms-read 
  namespace: kube-system

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: oms-read
  labels: 
    k8s-app: oms-read
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: oms-viewonly
subjects:
- kind: ServiceAccount
  name: oms-read
  namespace: kube-system
```

然后创建：
kubectl apply -f oms-viewonly.yaml

最后就可以使用以下命令查找刚刚创建SA的token:
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep oms-read | awk '{print $1}')

复制一个 ~/.kube/config 文件的副本，使用新生成的token 替换 kube-view.config 的最后一段

  user:
    token: eyJhbGciOiJSUzI1NiIsImtpZCI6ImNETzRHYzY0Mkt3R3FPSWhJSDdLWGV0cElHamtxWWd1aWdvTXVQZ2VPb0UifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJvbXMtcmVhZC10b2tlbi1kZGRjcSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJvbXMtcmVhZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjNhNDgzZjQ3LTViZWItNDhkYi1hYTRmLTA4N2VlMDlhZTFmNyIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTpvbXMtcmVhZCJ9.GMoyunXW1o4_xQXiJEjz1Z9yPBEjgAjv-eDs9vU3IevAajh8Zy4797wstLeFfCr21AxECyOfccIRtqr5i-UYk9-qTJ15m2rg_8RLV8Ovrc5zBrL9jrvdMwl0NeWG7XpvW8RoLgAXFFY6bXrwH2NpJaBGEPz76HdiEyS_r50ZPeUG_arFfKA7FeCiRW-dzd__YM4GdFcs5BEVPMWj4qDmDC3EAML6juXJ8XhDoyq-X-OOA1bceco7zc-ZLmxhCMZPAMxR-SLuMNo_KbuY-eFUGiWDEMLo8e860-hSYITGjiKXV04Ke-cG9B7VcHwCo3nVB2y7WBhH_zFM6A2IEj_SEg


## 验证权限

kubectl  --kubeconfig=/root/kube-view.config get ns
kubectl  --kubeconfig=/root/kube-view.config delete ns kube-node-lease
