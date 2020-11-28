# Mysql 同步到 Kafka


## 前置工作

* 保证MySQL的binlog-format=ROW
* 为canal用户配置MySQL slave的权限
```
CREATE USER canal IDENTIFIED BY 'canal';  
GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'canal'@'%';
FLUSH PRIVILEGES;
```
## canal.properties设置

顺便还可以复习一下Kafka producer的一些配置参数含义。

# 默认值tcp，这里改为投递到Kafka
canal.serverMode = kafka
# Kafka bootstrap.servers，可以不用写上全部的brokers
canal.mq.servers = 10.10.99.132:9092,10.10.99.133:9092,10.10.99.134:9092,10.10.99.135:9092
# 投递失败的重试次数，默认0，改为2
canal.mq.retries = 2
# Kafka batch.size，即producer一个微批次的大小，默认16K，这里加倍
canal.mq.batchSize = 32768
# Kafka max.request.size，即一个请求的最大大小，默认1M，这里也加倍
canal.mq.maxRequestSize = 2097152
# Kafka linger.ms，即sender线程在检查微批次是否就绪时的超时，默认0ms，这里改为200ms
# 满足batch.size和linger.ms其中之一，就会发送消息
canal.mq.lingerMs = 200
# Kafka buffer.memory，缓存大小，默认32M
canal.mq.bufferMemory = 33554432
# 获取binlog数据的批次大小，默认50
canal.mq.canalBatchSize = 50
# 获取binlog数据的超时时间，默认200ms
canal.mq.canalGetTimeout = 200
# 是否将binlog转为JSON格式。如果为false，就是原生Protobuf格式
canal.mq.flatMessage = true
# 压缩类型，官方文档没有描述
canal.mq.compressionType = none
# Kafka acks，默认all，表示分区leader会等所有follower同步完才给producer发送ack
# 0表示不等待ack，1表示leader写入完毕之后直接ack
canal.mq.acks = all
# Kafka消息投递是否使用事务
# 主要针对flatMessage的异步发送和动态多topic消息投递进行事务控制来保持和Canal binlog位置的一致性
# flatMessage模式下建议开启
canal.mq.transaction = true
instance.properties设置
# 需要接入binlog的表名，支持正则，但这里手动指定了每张表，注意转义
canal.instance.filter.regex=mall\\.address,mall\\.orders,mall\\.order_product,mall\\.product,mall\\.mall_category,mall\\.mall_comment,mall\\.mall_goods_category,mall\\.mall_goods_info,mall\\.mall_goods_wish,mall\\.mall_new_tags_v2,mall\\.mall_topic,mall\\.mall_topic_goods,mall\\.mall_user_cart_info
# 黑名单
canal.instance.filter.black.regex=
# 消息队列对应topic名
canal.mq.topic=binlog_mall_1
# 发送到哪一个分区，由于下面用hash做分区，因此不设
#canal.mq.partition=0
# 根据正则表达式做动态topic，目前采用单topic，因此也不设
#canal.mq.dynamicTopic=mall\\..*
# 10个分区
canal.mq.partitionsNum=10
# 各个表的主键，依照主键来做hash分区
canal.mq.partitionHash=mall.address:address_id,mall.orders:order_id,mall.order_product:order_product_id,mall.product:product_id,mall.mall_category:category_id,mall.mall_comment:comment_id,mall.mall_goods_category:goods_category_id,mall.mall_goods_info:goods_id,mall.mall_goods_wish:id,mall.mall_new_tags_v2:tags_id,mall.mall_topic:topic_id,mall.mall_topic_goods:id,mall.mall_user_cart_info:id
