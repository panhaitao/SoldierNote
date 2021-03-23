# openstack 镜像仓库列表

```

kolla-ansible pull && docker images | grep kolla > list || cat >> list <<EOF
kolla/centos-source-neutron-server
kolla/centos-source-neutron-l3-agent
kolla/centos-source-neutron-dhcp-agent
kolla/centos-source-neutron-metadata-agent
kolla/centos-source-neutron-openvswitch-agent
kolla/centos-source-heat-api
kolla/centos-source-heat-engine
kolla/centos-source-heat-api-cfn
kolla/centos-source-nova-compute
kolla/centos-source-keystone-ssh
kolla/centos-source-keystone
kolla/centos-source-keystone-fernet
kolla/centos-source-cinder-volume
kolla/centos-source-magnum-api
kolla/centos-source-magnum-conductor
kolla/centos-source-glance-api
kolla/centos-source-horizon
kolla/centos-source-nova-api
kolla/centos-source-nova-novncproxy
kolla/centos-source-nova-ssh
kolla/centos-source-nova-conductor
kolla/centos-source-nova-scheduler
kolla/centos-source-cinder-backup
kolla/centos-source-placement-api
kolla/centos-source-cinder-api
kolla/centos-source-cinder-scheduler
kolla/centos-source-openvswitch-db-server
kolla/centos-source-openvswitch-vswitchd
kolla/centos-source-mariadb
kolla/centos-source-kolla-toolbox
kolla/centos-source-chrony
kolla/centos-source-nova-libvirt
kolla/centos-source-tgtd
kolla/centos-source-fluentd
kolla/centos-source-keepalived
kolla/centos-source-memcached
kolla/centos-source-cron
kolla/centos-source-rabbitmq
kolla/centos-source-haproxy
kolla/centos-source-iscsid
kolla/centos-source-cinder-backup
kolla/centos-source-cinder-api
kolla/centos-source-cinder-scheduler
kolla/centos-source-glance-api
kolla/centos-source-keystone-ssh
kolla/centos-source-keystone
kolla/centos-source-keystone-fernet
kolla/centos-source-kolla-toolbox
kolla/centos-source-mariadb
kolla/centos-source-haproxy
kolla/centos-source-rabbitmq
kolla/centos-source-fluentd
kolla/centos-source-iscsid
kolla/centos-source-keepalived
kolla/centos-source-memcached
kolla/centos-source-cron
kolla/centos-source-chrony
kolla/centos-source-tgtd
EOF

for img in `cat list`
do
  old=${img}:master
  name=`echo $img | awk -F/ '{print $2}'`
  new=registry.cn-beijing.aliyuncs.com/openstack_release/${name}:master
  docker tag $old $new
  docker push $new
done
``` 


