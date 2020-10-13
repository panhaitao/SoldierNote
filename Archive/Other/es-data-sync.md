# ES 数据同步


1. 方案一，双写
2. 方案二，第三方数据同步
例如使用mysql的主从同步功能，在不同数据中心之间，从本机房的mysql同步数据到ES，依托mysql数据一致性来保障ES数据一致。datax,StreamSet均提供了类似功能。
3. 方案三，基于ES translog同步
读取translog，同步并重放，类似于mysql binlog方式。看起来这种方式最干净利落，但涉及到ES底层代码修改，成本也较高，目前已有的实践
4. CCR 跨数据中心复制 
https://www.elastic.co/cn/blog/cross-datacenter-replication-with-elasticsearch-cross-cluster-replication

