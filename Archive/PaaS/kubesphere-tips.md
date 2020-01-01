# Paas 部署问题

# k8s 问题

```
error execution phase control-plane-prepare/certs: error creating PKI assets: failed to write or validate certificate "apiserver": certificate apiserver is invalid: x509: certificate is valid for master-1, kubernetes, kubernetes.default, kubernetes.default.svc, kubernetes.default.svc.cluster.local, not master-2
```

解决办法
```
apiServer:
  timeoutForControlPlane: 4m0s
  certSANs:
  - 10.4.73.110
  - 10.4.68.77
  - 10.4.83.248
  - master-1
  - master-2
  - master-3
  - 127.0.0.1
  - localhost
```

## helm 问题

现象
```
helm list
Error: configmaps is forbidden: User "system:serviceaccount:kube-system:default" cannot list configmaps in the namespace "kube-system"
```

解决办法
```
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'      
helm init --service-account tiller --upgrade
```

## StorageClass 

现象
```
TASK [preinstall : Stop if defaultStorageClass was not found] ******************
fatal: [localhost]: FAILED! => {
    "assertion": "\"(default)\" in default_storage_class_check.stdout",
    "changed": false,
    "evaluated_to": false,
    "msg": "Default StorageClass was not found !"
}
```

解决办法
```
cat <<EOF > sc.yml
apiVersion: v1
items:
- apiVersion: storage.k8s.io/v1
  kind: StorageClass
  metadata:
    annotations:
      storageclass.kubernetes.io/is-default-class: "true"
    name: hostpath
    namespace: ""
  provisioner: docker.io/hostpath
  reclaimPolicy: Delete
  volumeBindingMode: Immediate
kind: List
metadata:
  resourceVersion: ""
  selfLink: ""
EOF
kubectl apply -f sc.yml
```


