# 添加dockerd和kubelet 对私有registry仓库的认证

添加新的k8s的节点，需要完成一系列对私有registry仓库的认证的，才能保证节点正常使用私有仓库拉取镜像

## 操作

1. /etc/docker/daemon.json 添加 insecure-registries 配置加入仓库
2. systemctl restart docker
3. docker login registry_ip:port -u user_name -p password
4. unalias cp; cp $HOME/.docker/config.json /var/lib/kubelet -f
5. systemctl daemon-reload
6. systemctl restart kubelet

## 说明
1. 修改dockerd配置，添加信任仓库，重启服务生效
2. 执行docker login 完成对私有registry仓库的认证
3. 将docker的认证拷贝到/var/lib/kubelet，完成对私有registry仓库的认证，重启服务生效



