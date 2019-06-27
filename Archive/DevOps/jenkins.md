# jenkins


## 架构

1. master 和 jenkins插件
2. slave(也叫agent 或 node)

## 启动 master

使用Jenkins的Web应用程序ARchive（WAR）文件版本启动master, 执行命令: `java -jar jenkins.war` 启动后,可以访问ip:8080按照向导完成初始化设置.

* 更改master管理页面端口可以使用参数,`--httpPort=9090`
* 默认还有一个 5000 端口是用来供slave节点连接到master端的,可以更改默认端口，登录管理页面 ip:8080-> jenkins系统管理–>全局安全配置–>代理 jnlp-slave链接master使用的端口

## 启动slave

* 通过ssh连接node
* 通过JNLP连接node
