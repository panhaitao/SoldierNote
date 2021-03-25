# 同城容器集群多活及弹性扩容方案

# 部署模式

相同业务容器集群，按照1:1资源配比,创建两个k8s集群，分别部署在同地域不同可用区，两个容器集群，共用一套数据库

# 部署说明

1.  按照1:1资源配比在不同可用区分别创建k8s集群
2. redis/kafka 在不同可用区分别创建一套实例
3.  Mysql数据实例，可采用高可用版本,跨可用区部署 
4. 流量入口，推荐使用阿里云GTM做多活容灾和流量调度

# 方案图示

![流程图.jpg](https://upload-images.jianshu.io/upload_images/5592768-a917ed198e776967.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

 
# 弹性扩容

首先将应用转变容器应用，然后部署在k8s集群中，可以充分k8s集群的能力，实现自动扩缩容：

1.  集群节点的自动扩容
2.  应用资源配额的横向/纵向扩容
3.  通过配置uk8s的集群伸缩，可以实现集群node节点扩容/缩容(Cluster Autoscaler) 

![image](https://upload-images.jianshu.io/upload_images/5592768-ee39fef33d069823?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2.  Metrics-server 已经内置，Pod个数自动扩/缩容(HPA)，只需要对应用配置 HPA 即可，示例如下:

创建一个nginx服务，ULB 由 cloudprovider-ucloud 自动创建，和公有云相关配置在名为uk8sconfig的configmap中,创建 test-nginx.yaml

```
apiVersion: v1
kind: Service
metadata:
  name: ucloud-nginx
  labels:
    app: ucloud-nginx
spec:
  type: LoadBalancer
  ports:
    - protocol: TCP
      port: 80
  selector:
    app: ucloud-nginx
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ucloud-nginx
spec:
  selector:
    matchLabels:
      app: ucloud-nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: ucloud-nginx
    spec:
      containers:
      - name: ucloud-nginx
        image: uhub.service.ucloud.cn/ucloud/nginx:1.9.2
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 80

```

执行命令: kubectl apply -f test-nginx.yaml 创建资源，

执行命令: kubectl get services 可以查询到 EXTERNAL-IP 即创建服务生成ULB外网IP

创建HPA配置，参考如下：

```
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: ucloud-nginx
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ucloud-nginx
  minReplicas: 1
  maxReplicas: 1000
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 2
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 500
        periodSeconds: 15
      - type: Pods
        value: 10
        periodSeconds: 15
      selectPolicy: Max
    scaleDown:
      stabilizationWindowSeconds: 10
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15

```

1.  缩容策略: 稳定窗口的时间为 *300* 秒，允许 100% 删除当前运行的副本，
2.  扩缩策略: 立即扩容，每 15 秒添加 4 个 Pod 或 100% 当前运行的副本数，直到 HPA 达到稳定状态。
3.  https://kubernetes.io/zh/docs/tasks/run-application/horizontal-pod-autoscale/

使用AB压测验证:

操作压测集群节点执行命令: ab -n 100000 -c 300 http://nginx_server_ip/

集群初始状态:

![image](https://upload-images.jianshu.io/upload_images/5592768-f34e7a89937af74e?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

压测过程中，随着请求带来对pod带来的压力，会触发Pod快速扩容个数，同时集群node节点的请求值达到扩容阈值的时候，会自动新增node节点

![image](https://upload-images.jianshu.io/upload_images/5592768-a5d874cf39943b1a?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

在压测结束后，稳定窗口时间结束后，集群内pod数量，node节点数会恢复到初始状态

3.  Pod配置自动扩/缩容(VPA) 需要部署**vertical-pod-autoscaler控制器 参考**https://github.com/kubernetes/autoscaler VPA示例以及VPA使用限制

```
apiVersion: autoscaling.k8s.io/v1beta2
kind: VerticalPodAutoscaler
metadata:
  name: nginx-vpa
  namespace: vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: nginx
  updatePolicy:
    updateMode: "Off"
  resourcePolicy:
    containerPolicies:
    - containerName: "nginx"
      minAllowed:
        cpu: "250m"
        memory: "100Mi"
      maxAllowed:
        cpu: "2000m"
        memory: "2048Mi"

```

1.  不能与HPA（Horizontal Pod Autoscaler ）一起使用
2.  Pod比如使用副本控制器，例如属于Deployment或者StatefulSet

