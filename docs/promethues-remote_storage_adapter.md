## promethus 持久存储

准备remote_storage_adapter
在github上准备一个remote_storage_adapter的可执行文件，然后启动它，如果想获取相应的帮助可以使用:./remote_storage_adapter -h来获取相应帮助(修改绑定的端口，influxdb的设置等..)，现在我们启动一个remote_storage_adapter来对接influxdb和prometheus：
./remote_storage_adapter -influxdb-url=http://localhost:8086/ -influxdb.database=prometheus -influxdb.retention-policy=autogen，influxdb默认绑定的端口为9201

修改 prometheus.yml 配置对接adapter
前面的准备操作完了之后，就可以对prometheus进行配置了。修改prometheus.yml文件，在文件末尾增加：

remote_write:
  - url: "http://localhost:9201/write"

remote_read:
  - url: "http://localhost:9201/read"
之后我们启动prometheus就可以看到influxdb中会有相应的数据了。如果验证我们采集的metrics数据被存储起来了呢？我们选取一个metric，过几分钟然后将prometheus停止，并且将data目录删除，重启prometheus，然后我们再查询这个metric，可以看到之前几分钟的数据还在那里。


https://github.com/prometheus/prometheus/tree/master/documentation/examples/remote_storage/remote_storage_adapter



