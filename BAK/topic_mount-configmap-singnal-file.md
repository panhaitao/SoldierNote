# k8s configmap 挂载单个文件

1. kubectl cp -n kube-system pod_name:/etc/resolv.conf ./
2. kubectl create configmap -n kube-system configmap_name --from-file=etc-resolv=./resolv.conf
3. kubectl edit deploy -n kube-system <deploy_name>

```
      volumeMounts:
      - mountPath: /etc/resolv.conf
        name: config-volume
        subPath: resolv.conf
  volumes:
    - name: config-volume
      configMap:
        name: test-config
        items:
        - key: test-file
          path: resolv.conf
        - key: cache_host
          path: path/to/special-key-cache #path中的最后一级“special-key-cache”为文件名
```


* 首先创建一个指定的keys创建一个名为configmap_name key为etc-resolv的configmap
* 定义卷的时候引用configMap，需要指定：
1. key
2. path
* 然后挂载的时候需要指定:
1. mountPath
2. subPath

## 参考

* http://docs.kubernetes.org.cn/533.html
* https://www.cnblogs.com/pu20065226/p/10690628.html

