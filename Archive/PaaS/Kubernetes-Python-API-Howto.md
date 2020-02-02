# Kubernetes Python API 快速入门

* 官方网站: https://github.com/kubernetes-client/python
* 主要的操作接口: https://github.com/kubernetes-client/python/blob/master/kubernetes/docs/CoreV1Api.md

## 安装

```
pip install git+https://github.com/kubernetes-client/python.git
或者：
pip install kubernetes

## 使用kubeconfig.yaml访问k8s api
 
from kubernetes import client, config
config.kube_config.load_kube_config(config_file="kubeconfig.yaml")

v1 = client.CoreV1Api()
print("Listing pods with their IPs:")
ret = v1.list_pod_for_all_namespaces(watch=False)
for i in ret.items:
  print("%s\t%s\t%s" % (i.status.pod_ip, i.metadata.namespace, i.metadata.name))

## 使用 token 访问k8s API

from kubernetes.client import Configuration, ApiClient, CoreV1Api

from kubernetes import client, config

# https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster/
ApiServer = 'https://10.110.16.14:6443'
Token     = "40bdab940b643a1e6958c39d44949dfb9cc6e610d26ea5172307112ecb64afdc"

# Create a configuration object
configuration = client.Configuration()
configuration.host = ApiServer
configuration.verify_ssl = False
configuration.api_key = {"authorization": "Bearer " + Token}

client.Configuration.set_default(configuration)

## 使用 token 访问k8s API
from kubernetes import client, config

 with open('token.txt', 'r') as file:
        Token = file.read().strip('\n')

    APISERVER = 'https://10.110.16.14:6443'

    # Create a configuration object
    configuration = client.Configuration()
    configuration.host = APISERVER
    configuration.verify_ssl=True
    configuration.api_key_prefix['authorization'] = 'Bearer'
   configuration.ssl_ca_cert = 'ca.crt'
    client.Configuration.set_default(configuration)


## 常用操作

1. 获得API的CoreV1Api版本对象：
v1 = client.CoreV1Api()
for ns in v1.list_namespace().items:
    print(ns.metadata.name)

2. 列出所有的services

v1 = client.CoreV1Api()
print("Listing All services with their info:\n")
ret = v1.list_service_for_all_namespaces(watch=False)
for i in ret.items:
    print("%s \t%s \t%s \t%s \t%s \n" % (i.kind, i.metadata.namespace, i.metadata.name, i.spec.cluster_ip, i.spec.ports ))

3. 列出所有的pods

v1 = client.CoreV1Api()
print("Listing pods with their IPs:")
ret = v1.list_pod_for_all_namespaces(watch=False)
for i in ret.items:
    print("%s\t%s\t%s" % (i.status.pod_ip, i.metadata.namespace, i.metadata.name))
