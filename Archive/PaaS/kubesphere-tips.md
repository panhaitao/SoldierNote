#

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


