# iscsi adm

* yum install iscsi-initiator-utils -y
* iscsiadm -m discovery -t sendtargets -p 172.16.1.191:3260
* iscsiadm -m node –T iqn.2019-07.com.aisino:91577924332b  172.16.1.191:3260 -l

发现设备后检查 /proc/scsi/scsi 


* iscsiadm -m node --logoutall=all

https://www.cnblogs.com/sting2me/p/6937578.html


## k8s yaml

```
public-registry.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: public-registry
  namespace: global--global
spec:
  capacity:
    storage: 90Gi
  accessModes:
    - ReadWriteOnce
  iscsi:
     targetPortal: 172.16.1.191:3260
     iqn: iqn.2019-07.com.aisino:91577924332b
     lun: 0
     fsType: 'ext4'
     readOnly: false
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: public-registry
  namespace: global--global
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 90Gi
```
