# Prometheus 架构与原理

## Prometheus 应用架构


## Operator 部署架构



* Operator： Operator 资源会根据自定义资源（Custom Resource Definition / CRDs）来部署和管理 Prometheus Server，同时监控这些自定义资源事件的变化来做相应的处理，是整个系统的控制中心。
* Prometheus Server： Operator 根据自定义资源 Prometheus 类型中定义的内容而部署的 Prometheus Server 集群，这些自定义资源可以看作是用来管理 Prometheus Server 集群的 StatefulSets 资源。
* Service： Service 资源主要用来对应 Kubernetes 集群中的 Metrics Server Pod，来提供给 ServiceMonitor 选取让 Prometheus Server 来获取信息。简单的说就是 Prometheus 监控的对象，例如 Node Exporter Service、Mysql Exporter Service 等等。


Operatored 的四个CRD:

* Prometheus:      Prometheus 资源是声明性地描述 Prometheus 部署的期望状态。
* ServiceMonitor:  描述了一组被 Prometheus 监控的 targets 列表。该资源通过 Labels 来选取对应的 Service Endpoint，让 Prometheus Server 通过选取的 Service 来获取 Metrics 信息。
* PrometheusRule : 描述Prometheus实例使用的告警规则文件的抽象
* Alertmanager:    由 Operator 根据资源描述内容来部署 Alertmanager 集群。
