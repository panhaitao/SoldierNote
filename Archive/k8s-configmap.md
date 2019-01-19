---
title: 使用Configmap 管理服务配置文件
date: 2018/10/10
categories: 配置管理
---

## 创建配置

登录容器管理平台：打开　交付中心-> 容器-> 配置管理　创建一个配置

其中 key 为　配置文件名　 
　　 vaule为 配置文件名里对应的内容


## 引用配置文件

更新服务或者创建服务的时候，编辑对应的 yaml 配置文件，对应　containers　段添加如下参考配置，例如：

```
...
      containers:
      - env:
        name: logstash
        volumeMounts:
        - mountPath: /usr/share/logstash/config/
          name: logstash-config-volume
        - mountPath: /usr/share/logstash/pipeline/
          name: logstash-pipeline-volume
      volumes:
      - configMap:
          name: logstash-config
        name: logstash-config-volume
      - configMap:
          name: logstash-pipeline
        name: logstash-pipeline-volume
...
```

其中　 
* /etc/nginx/conf.d　为对应服务配置文件所在的目录 
* name: nginx　对应　交付中心-> 容器-> 配置管理　创建的配置名称　

## 参考
https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#use-configmap-defined-environment-variables-in-pod-commands
